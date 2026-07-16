library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_filter_avalon is
    port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        
        -- Avalon-MM Slave Interface
        avs_address   : in  std_logic_vector(0 downto 0); -- 2 registers
        avs_write     : in  std_logic;
        avs_writedata : in  std_logic_vector(31 downto 0);
        avs_read      : in  std_logic;
        avs_readdata  : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of fir_filter_avalon is
    -- Core Internal Signals
    signal filter_in  : std_logic_vector(7 downto 0) := (others => '0');
    signal filter_out : std_logic_vector(7 downto 0);
    
    -- Memory Mapped Registers
    -- Address 0: Control/Data Input Register (Write-only for raw data)
    -- Address 1: Status/Data Output Register (Read-only for filtered data)
    signal reg_data_in  : std_logic_vector(31 downto 0) := (others => '0');
    signal reg_data_out : std_logic_vector(31 downto 0) := (others => '0');
begin

    -- Instantiate the DSP Core verified in simulation
    dsp_core : entity work.fir_filter
        port map (
            clk      => clk,
            rst      => reset,
            data_in  => filter_in,
            data_out => filter_out
        );

    -- Map register bits to filter ports
    filter_in <= reg_data_in(7 downto 0);
    reg_data_out(7 downto 0) <= filter_out;
    reg_data_out(31 downto 8) <= (others => '0'); -- Pad with zeros

    -- Avalon-MM Slave Write/Read Logic
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                reg_data_in <= (others => '0');
                avs_readdata <= (others => '0');
            else
                -- Host CPU Writing to the Peripheral
                if avs_write = '1' then
                    if avs_address = "0" then
                        reg_data_in <= avs_writedata;
                    end if;
                end if;
                
                -- Host CPU Reading from the Peripheral
                if avs_read = '1' then
                    if avs_address = "1" then
                        avs_readdata <= reg_data_out;
                    else
                        avs_readdata <= (others => '0');
                    end if;
                else
                    avs_readdata <= (others => '0');
                end if;
            end if;
        end if;
    end process;

end architecture;
