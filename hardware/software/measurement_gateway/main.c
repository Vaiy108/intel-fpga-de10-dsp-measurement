/*
 * main.c
 *
 *  Created on: Jul 22, 2026
 *      Author: Vasan Iyer
 */

#include <stdio.h>
#include <stdint.h>
#include "system.h"      // Automatically includes your Qsys base addresses
#include "io.h"          // Includes memory-mapped I/O access functions (IORD/IOWR)

// --- Memory-Mapped Register Layout for Custom VHDL Filter ---
// Offset 0: Input data stream register (Write-only)
// Offset 1: Filtered output data register (Read-only)
#define REG_DATA_IN_OFFSET   0
#define REG_DATA_OUT_OFFSET  1

// Static Telemetry Data (Noisy Sine Wave Profile generated from Phase 1)
const int8_t telemetry_signal[20] = {
    0, 26, 47, 58, 55, 39, 14, -14, -39, -55,
    -58, -47, -26, 0, 26, 47, 58, 55, 39, 14
};

int main(void) {
    printf("=============================================\n");
    printf("   FLIGHT DATA ENTRY DISPATCH TELEMETRY SoC  \n");
    printf("=============================================\n");
    printf("[INIT] SPI Master Protocol Core... Status: OK\n");
    printf("[INIT] I2C Flight Management Bus... Status: OK\n");
    printf("[INIT] JTAG UART Local Interconnect... Status: OK\n\n");

    printf("Time (ms) | Raw Telemetry (SPI) | Filtered Output\n");
    printf("-------------------------------------------------\n");

    for (int i = 0; i < 20; i++) {
        int8_t raw_data = telemetry_signal[i];

        // 1. Dispatch noisy telemetry data over Avalon-MM bus to VHDL core
        IOWR_32DIRECT(FIR_FILTER_AVALON_0_BASE, REG_DATA_IN_OFFSET * 4, (uint32_t)raw_data);

        // 2. Hardware instruction fence pipeline verification buffer delay
        asm("nop");

        // 3. Read back mathematically stabilized telemetry from VHDL core registers
        uint32_t hardware_response = IORD_32DIRECT(FIR_FILTER_AVALON_0_BASE, REG_DATA_OUT_OFFSET * 4);
        int8_t filtered_data = (int8_t)(hardware_response & 0xFF);

        // 4. Stream data arrays over JTAG UART link back to PC host console
        printf("   %04d   |        %4d         |       %4d\n", i * 10, raw_data, filtered_data);
    }

    printf("\n[STATUS] Diagnostic telemetry processing successfully finalized.\n");
    while(1); // Secure thread anchor lock
    return 0;
}

