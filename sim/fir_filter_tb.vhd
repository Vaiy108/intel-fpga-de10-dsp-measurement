library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity fir_filter_tb is
end entity;

architecture sim of fir_filter_tb is
    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal data_in  : std_logic_vector(7 downto 0) := (others => '0');
    signal data_out : std_logic_vector(7 downto 0);
    
    constant CLK_PERIOD : time := 20 ns; -- 50 MHz clock
begin

    -- UUT Instantiation
    uut: entity work.fir_filter
        port map (
            clk      => clk,
            rst      => rst,
            data_in  => data_in,
            data_out => data_out
        );

    -- Clock Generation
    clk <= not clk after CLK_PERIOD / 2;

    -- Stimulus Process (Reading the File)
    process
        file file_pointer : text;
        variable file_line : line;
        variable int_val   : integer;
    begin
        file_open(file_pointer, "../mat/input_signal.txt", read_mode);
        
        rst <= '1';
        wait for CLK_PERIOD * 5;
        rst <= '0';
        
        while not endfile(file_pointer) loop
            readline(file_pointer, file_line);
            read(file_line, int_val);
            
            data_in <= std_logic_vector(to_signed(int_val, 8));
            wait for CLK_PERIOD;
        end loop;
        
        file_close(file_pointer);
        wait for CLK_PERIOD * 10;
        assert false report "Simulation Finished successfully!" severity failure;
        wait;
    end process;

end architecture;
