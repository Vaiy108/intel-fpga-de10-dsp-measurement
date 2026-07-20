library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity de10_top is
    port (
        -- Physical 50 MHz Clock Pin from your DE10 board
        MAX10_CLK1_50 : in std_logic;
        
        -- Global Reset (Using a physical Push Button on your board)
        KEY           : in std_logic_vector(0 downto 0)
    );
end entity;

architecture rtl of de10_top is
    -- Component declaration for our generated Qsys system
    component nios_system is
        port (
            clk_clk       : in std_logic := 'X'; -- clk
            reset_reset_n : in std_logic := 'X'  -- reset_n
        );
    end component nios_system;

    signal sys_reset_n : std_logic;
begin

    -- DE10 board push buttons are active-low (0 when pressed, 1 when open).
    -- Qsys clock resets are typically active-low (reset_n).
    sys_reset_n <= KEY(0);

    -- Instantiate the generated System-on-Chip
    u0 : component nios_system
        port map (
            clk_clk       => MAX10_CLK1_50, -- Map physical board clock
            reset_reset_n => sys_reset_n    -- Map physical push button reset
        );

end architecture;
