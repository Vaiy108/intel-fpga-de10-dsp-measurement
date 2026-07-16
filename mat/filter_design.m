% filter_design.m - DSP Modeling for Flight Measurement
clear; clk = 1:100;

% Create a clean low-frequency signal + high-frequency noise
pure_signal = sin(2*pi*0.05*clk);
noise = 0.3 * sin(2*pi*0.4*clk);
noisy_signal = pure_signal + noise;

% Quantize to 8-bit Signed Integers for VHDL (Fixed-Point)
% Scaled so it fits within -128 to 127
quantized_input = round(noisy_signal * 90); 

% 4-Tap Moving Average Filter Coefficients (Each coefficient = 0.25)
% In fixed-point, 0.25 is exactly 1/4 (can be done with a bit-shift in VHDL!)
b = [0.25, 0.25, 0.25, 0.25];
matlab_output = filter(b, 1, quantized_input);

% Export the quantized input to a text file for the ModelSim Testbench
fid = fopen('input_signal.txt', 'w');
for i = 1:length(quantized_input)
    fprintf(fid, '%d\n', quantized_input(i));
end
fclose(fid);

disp('MATLAB: Test vectors generated successfully in input_signal.txt');
