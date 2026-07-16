# Close any active simulation
quit -sim

# Create and map the work library
vlib work
vmap work work

# Compile VHDL components (relative paths from the sim/ directory)
vcom -2008 ../rtl/fir_filter.vhd
vcom -2008 ../sim/fir_filter_tb.vhd

# Load the simulation
vsim -voptargs="+acc" work.fir_filter_tb

# Configure the Wave Window
add wave -divider "System Signals"
add wave -noupdate -color "Yellow" /fir_filter_tb/clk
add wave -noupdate -color "Red"    /fir_filter_tb/rst

add wave -divider "DSP Interface"
# Format input data as Signed Analog to visually see the noise
add wave -noupdate -color "Cyan" -format Analog-Interpolated -height 80 -max 130 -min -130 -radix decimal /fir_filter_tb/data_in

# Format output data as Signed Analog to visually see the clean wave
add wave -noupdate -color "Green" -format Analog-Interpolated -height 80 -max 130 -min -130 -radix decimal /fir_filter_tb/data_out

# Run the simulation until the testbench finishes
run -all

# Zoom to fit the entire waveform display
wave zoom full
