library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity de10_top is
    port (
        MAX10_CLK1_50 : in std_logic;
        KEY           : in std_logic_vector(0 downto 0)
    );
end entity;

architecture rtl of de10_top is
    -- Component declaration matching your Platform Designer template
    component nios_system is
        port (
            clk_clk       : in std_logic := 'X'; 
            reset_reset_n : in std_logic := 'X'  
        );
    end component nios_system;

    signal sys_reset_n : std_logic;
begin

    sys_reset_n <= KEY(0);

    -- Component Instantiation matching your template
    u0 : component nios_system
        port map (
            clk_clk       => MAX10_CLK1_50,
            reset_reset_n => sys_reset_n
        );

end architecture;
