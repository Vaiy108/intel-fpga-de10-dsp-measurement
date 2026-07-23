# Intel FPGA DE10 Embedded DSP & Measurement System

An end-to-end FPGA embedded system demonstrating FPGA Hardware/Software Co-Design using Intel Quartus Prime, Platform Designer (Qsys), Nios II, custom VHDL IP, MATLAB modelling and ModelSim verification.

The project implements a hardware-accelerated FIR filter connected to a Nios II soft processor through an Avalon Memory-Mapped (Avalon-MM) interface, representative of FPGA-based embedded architectures used in measurement, instrumentation, avionics, and real-time signal processing applications.



**Highlights**

 - Custom Avalon-MM FPGA peripheral
 - Nios II embedded processor integration
 - 4-tap FIR hardware accelerator
 - MATLAB → VHDL → ModelSim → FPGA validation flow
 - Successfully deployed on Terasic DE10-Lite (Intel MAX 10)

 ---

## Key Skills Demonstrated

- FPGA RTL Design (VHDL)
- Intel Platform Designer (Qsys)
- Avalon-MM Custom Peripheral Development
- Embedded Software Development (Nios II)
- FPGA Hardware/Software Co-Design
- MATLAB DSP Modelling
- ModelSim Functional Verification
- Quartus Prime Synthesis & Timing Closure
- Memory-Mapped Embedded Systems
- Digital Signal Processing

---


# Project Highlights

✔ Custom VHDL FIR hardware accelerator

✔ Avalon-MM peripheral integration

✔ Intel Platform Designer (Qsys)

✔ Nios II Embedded Processor

✔ Embedded C firmware

✔ MATLAB DSP modelling

✔ ModelSim functional verification

✔ Quartus Prime synthesis, fitting and timing closure

✔ FPGA Hardware/Software Co-Design

---

# Hardware Platform

**FPGA Board**

- Terasic DE10-Lite
- Intel MAX 10 FPGA (10M50DAF484C7G)
![Terasic DE10-Lite FPGA board](hardware/de10_fpga_hardware.jpg)


**Development Tools**

- Intel Quartus Prime Lite 18.1
- Platform Designer (Qsys)
- Nios II SBT for Eclipse
- ModelSim Intel FPGA Edition
- MATLAB / GNU Octave

---

# System Architecture

The design combines a Nios II soft processor, on-chip program memory, standard communication peripherals and a custom VHDL FIR accelerator inside one Platform Designer subsystem.

The Nios II processor controls the measurement flow through the Avalon-MM interconnect. Raw samples are written to the custom FIR peripheral, processed in FPGA logic and read back by the embedded C application. Results are then sent to the host computer through the JTAG UART.

```mermaid
flowchart LR
    HOST["Host PC<br/>Nios II SBT / JTAG Terminal"]

    subgraph BOARD["Terasic DE10-Lite — Intel MAX 10 FPGA"]
        CLK["50 MHz Board Clock<br/>MAX10_CLK1_50"]
        RESET["Active-Low Reset<br/>KEY(0)"]

        subgraph QSYS["Platform Designer / Qsys System"]
            CPU["Nios II/e<br/>Soft Processor"]
            BUS["Avalon-MM<br/>Interconnect Fabric"]
            MEM["128 KB<br/>On-Chip Memory"]
            JTAG["JTAG UART"]
            SPI["SPI Master"]
            I2C["I²C Master"]
            FIR["Custom FIR Accelerator<br/>Avalon-MM Slave"]
        end

        TOP["Top-Level Wrapper<br/>de10_top.vhd"]
    end

    SENSOR_SPI["External SPI Sensor<br/>(Future Hardware Interface)"]
    SENSOR_I2C["External I²C Sensor<br/>(Future Hardware Interface)"]

    CLK --> TOP
    RESET --> TOP
    TOP --> CPU

    CPU -->|Instruction and data access| BUS
    BUS <--> MEM
    BUS <--> JTAG
    BUS <--> SPI
    BUS <--> I2C
    BUS <--> FIR

    SPI -.-> SENSOR_SPI
    I2C -.-> SENSOR_I2C

    JTAG <--> HOST
```



---

![Platform Designer System Interconnect Layout](hardware/platform_designer_final_memory_map.png)

---

# Repository Structure

```
intel-fpga-de10-dsp-measurement

├── hardware/
│   ├── de10_top.vhd
│   ├── de10_top.qpf
│   ├── de10_top.qsf
│   ├── nios_system.qsys
│   ├── software/
│   └── ...
│
├── rtl/
│   ├── fir_filter.vhd
│   └── fir_filter_avalon.vhd
│
├── sim/
│   ├── fir_filter_tb.vhd
│   ├── compile.do
│   └── modelsim_waveform.png
│
├── mat/
│   ├── input_signal.txt
│   └── MATLAB scripts
│
└── README.md
```

---

# Project Workflow

## Phase 1 – DSP Algorithm Development
A 4-tap Moving Average (Low-Pass) filter was chosen to clean a noisy low-frequency raw measurement telemetry data feed. 
*   The raw test wave signal was structured to integrate a continuous clean wave combined with highly volatile high-frequency signal interference.
*   Values were fully quantized into signed 8-bit fixed-point vectors (`-128` to `127`) to mirror identical physical constraints inside the digital logic fabric.
*   Test parameters were subsequently serialized into `mat/input_signal.txt` for integration into testbench environments.

A 4-tap moving-average FIR filter was first designed and verified in MATLAB using fixed-point arithmetic.

The generated input vectors are exported for HDL simulation to guarantee identical test conditions between software and hardware.

---

## Phase 2 – RTL Design

The FIR filter was implemented in synthesizable VHDL.

Features:

- Fully synchronous design
- Shift-register pipeline
- Signed arithmetic
- Fixed-point implementation
- Vendor-independent RTL core

---

## Phase 3 – Functional Verification

The RTL was verified using ModelSim.

Verification includes:

- File-based stimulus
- 50 MHz clock
- Waveform inspection
- MATLAB comparison

The output waveform demonstrates successful suppression of high-frequency noise while preserving the desired low-frequency signal.


![ModelSim Analog Waveform Verification](sim/modelsim_waveform.png)

**Waveform Analysis:**
*   **`data_in` (Cyan Input):** Visualizes the highly distorted, jagged signal containing raw high-frequency fluctuations generated via MATLAB modeling.
*   **`data_out` (Green Output):** Displays a highly stable, uniform filtered sine wave. This demonstrates that the high-frequency variations have been successfully eliminated by the VHDL hardware block in real time.

---

---

## Phase 4 – FPGA Embedded System Integration

The FIR core is wrapped as a custom Avalon-MM peripheral and integrated into a complete Nios II embedded system using Intel Platform Designer.

System components include:

- Nios II/e processor
- 128 KB On-Chip RAM
- SPI Master
- I²C Master
- JTAG UART
- Custom FIR Hardware Accelerator

The embedded processor accesses the FIR through memory-mapped registers over the Avalon bus.


### Platform Designer Integration

The embedded subsystem was assembled using Intel Platform Designer (Qsys). During development, the complete hardware platform was validated through successful:

- Custom Avalon-MM IP packaging
- Address-space allocation
- Interrupt routing
- BSP generation
- Embedded software integration

The final design successfully generates the Platform Designer hardware description (`.sopcinfo`), enabling automatic Board Support Package (BSP) creation for the Nios II software environment.


---

# Embedded Software

A bare-metal Embedded C application performs:

1. Sensor data acquisition (simulated)
2. Writing samples to the FIR hardware accelerator
3. Reading filtered output
4. Sending results through JTAG UART

The software communicates with the hardware accelerator using standard Avalon memory-mapped register access:

- `IOWR_32DIRECT`
- `IORD_32DIRECT`

---

## Phase 5 – FPGA Implementation & Top-Level Integration

The complete Platform Designer system was integrated into the top-level FPGA design (`de10_top.vhd`), connecting the embedded processor subsystem with the physical resources of the DE10-Lite development board.

### Top-Level Hardware Connections

The design exposes the Nios II system to the FPGA pins through the top-level structural wrapper:

| FPGA Resource | Connected Signal |
|--------------|------------------|
| `MAX10_CLK1_50` | System clock (`clk_clk`) |
| `KEY(0)` | Active-low system reset (`reset_reset_n`) |

The Quartus Prime project was successfully synthesized, placed and routed without timing violations, generating the final FPGA configuration bitstream (`de10_top.sof`) for hardware deployment.

## Hardware Bring-Up

The complete FPGA system was synthesized and deployed on the Intel
DE10-Lite MAX 10 development board.

The Nios II application was downloaded through the USB-Blaster interface
and executed from on-chip memory. The hardware test successfully verified:

- Nios II processor execution
- JTAG UART communication
- SPI master initialization
- I²C controller initialization
- Avalon-MM FIR accelerator access
- Telemetry data processing and console output

### Pin Planner
The custom Nios II SoC was synthesized for the Intel MAX10 (10M50DAF484C7G) FPGA on the DE10-Lite development board. Quartus Pin Planner was used to verify the board pin assignments, including the 50 MHz system clock (MAX10_CLK1_50) and the reset push-button (KEY[0]), before hardware programming.

![Pin Planner](hardware/de10_pin_planner.png)

### Quartus Prime Compilation

- RTL Analysis & Synthesis ✔
- Fitter ✔
- Timing Analysis ✔
- Assembler ✔
- Programming File Generation (`de10_top.sof`) ✔

![Quartus Prime Compilation](hardware/qp_compilation.png)

This confirms that the complete hardware platform—including the Nios II processor, Platform Designer subsystem, custom Avalon-MM FIR accelerator and peripheral interfaces—was successfully implemented on the Intel MAX 10 FPGA.


### FPGA Programming

The generated FPGA configuration bitstream (`de10_top.sof`) was successfully programmed onto the Terasic DE10-Lite development board using the Intel USB-Blaster interface.

![FPGA Programming Successful](hardware/fpga_programming_success.png)

---

## Hardware Validation and FIR Debugging - Nios II Hardware Execution

The complete telemetry-processing pipeline was validated on the DE10-Lite FPGA using a Nios II processor, a custom Avalon-MM FIR peripheral, and the JTAG UART console.

### Stage 1 – Initial Hardware Integration

#### Problem

The filtered output was identical to the raw telemetry.

#### Root Cause

The FIR filter shifted at the 50 MHz FPGA clock, while new telemetry samples arrived only every 10 ms from the Nios II processor. Between two software writes, the same sample propagated through every tap, causing the moving average to converge to the current sample.

#### Hardware Result

During the first hardware test, the reported filtered output closely followed the raw telemetry input.

![Initial FIR hardware output](hardware/nios2_hardware_execution1.png)

As a result, the same input value was shifted repeatedly through all FIR taps before the next software sample arrived. Once all taps contained the same value, the moving-average output became approximately equal to the raw input.

### Stage 2 – Avalon-Controlled Sampling

A sample_valid signal was introduced (in Avalon wrapper) so the FIR shifted only when the Avalon-MM interface received a new telemetry sample.

The FIR shift register and accumulation logic were then enabled only when `sample_valid = '1'`.

This synchronized the FIR update rate with the software sampling rate.

The moving average became mathematically correct, although the output still showed a small pipeline delay because only the previous register contents were used in the accumulation.

![FIR output after sample-valid correction](hardware/nios2_hardware_execution2.png)

The result confirms that:

- Nios II successfully writes telemetry through Avalon-MM.
- The custom FIR peripheral receives one valid update per software sample.
- The filter smooths rapid changes in the input signal.
- The output retains the expected memory of previous samples.
- The complete software-to-hardware telemetry path operates successfully on the FPGA.

### Stage 3 – Pipeline Latency Refinement

The FIR datapath was refined so that each output sample is computed from the current input together with the previous three stored samples, eliminating an unnecessary one-sample pipeline delay while preserving the 4-tap moving-average architecture.

```
Current sample + Previous 3 samples
```
instead of waiting for the current sample to propagate through the register pipeline.

This removed the unnecessary one-sample computation delay while preserving the synchronous FPGA implementation and the 4-tap FIR architecture.

The resulting hardware output responds immediately to new telemetry while maintaining the expected smoothing behaviour.

![FIR output after pipeline-latency refinement](hardware/nios2_hardware_execution3.png)

### What this project demonstrates
- Custom Avalon-MM peripheral development
- Intel Platform Designer (Qsys) IP integration
- Nios II FPGA Hardware/Software Co-Design
- RTL implementation of a synchronous 4-tap FIR filter
- FPGA timing-aware debugging
- Hardware validation on the DE10-Lite platform
- Incremental debugging from initial implementation to optimized hardware

### Hardware Bring-Up Note

During initial hardware testing, the Nios II processor could be detected
through JTAG but did not respond to ELF downloads. The issue was traced to
missing top-level FPGA pin assignments for the 50 MHz board clock and reset
pushbutton.

The final assignments were:

- `MAX10_CLK1_50` → `PIN_P11`
- `KEY[0]` → `PIN_B8`

After recompilation and reprogramming, the Nios II application executed
successfully on hardware.

# Verification Status

| Item | Status |
|-------|--------|
| MATLAB Model | ✅ |
| VHDL RTL | ✅ |
| ModelSim Simulation | ✅ |
| Avalon-MM Wrapper | ✅ |
| Platform Designer Integration | ✅ |
| BSP Generation | ✅ |
| Embedded C Build | ✅ |
| Quartus Compilation | ✅ |
| FPGA Programming | ✅ |
| Hardware Validation | ✅ |

---

# Build Instructions

## RTL Simulation

```
cd sim
do compile.do
```

---

## FPGA Compilation

Open

```
hardware/de10_top.qpf
```

Compile using Quartus Prime.

---

## Embedded Software

1. Generate BSP
2. Build firmware
3. Download `.elf`
4. Execute through JTAG UART

---

# Future Improvements

- Real SPI sensor interface
- I²C sensor integration
- Interrupt-driven firmware
- DMA support
- Performance benchmarking
- Fixed-point coefficient optimization
- AXI4-Lite wrapper for Xilinx portability

---

# Engineering Skills Demonstrated

- FPGA Design (VHDL)
- Embedded Systems
- FPGA Hardware/Software Co-Design
- Digital Signal Processing
- Avalon-MM Bus Integration
- Intel Platform Designer
- Nios II Embedded Development
- MATLAB Verification
- ModelSim Verification
- Quartus Prime FPGA Development

---

# License

MIT License


## Author
**Vasan Iyer**  
Embedded avionics engineer
Focus: VHDL, FPGA Digital Design, Xilinx ISE, Signal Processing  
GitHub: https://github.com/Vaiy108