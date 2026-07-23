library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_filter_avalon is
    port (
        clk           : in  std_logic;
        reset         : in  std_logic;

        -- Avalon-MM Slave Interface
        avs_address   : in  std_logic_vector(0 downto 0); -- 2 registers
        avs_write     : in  std_logic;
        avs_writedata : in  std_logic_vector(31 downto 0);
        avs_read      : in  std_logic;
        avs_readdata  : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of fir_filter_avalon is

    -- Core internal signals
    signal filter_in  : std_logic_vector(7 downto 0) :=
        (others => '0');

    signal filter_out : std_logic_vector(7 downto 0);

    -- NEW: one-clock pulse for each Avalon input write
    signal sample_valid : std_logic :=
        '0';

    -- Memory-mapped registers
    -- Address 0: Control/Data Input Register
    -- Address 1: Status/Data Output Register
    signal reg_data_in : std_logic_vector(31 downto 0) :=
        (others => '0');

    signal reg_data_out : std_logic_vector(31 downto 0) :=
        (others => '0');

begin

    -- Instantiate the DSP core verified in simulation
    dsp_core : entity work.fir_filter
        port map (
            clk          => clk,
            rst          => reset,
            sample_valid => sample_valid,
            data_in      => filter_in,
            data_out     => filter_out
        );

    -- Map register bits to filter ports
    filter_in <= reg_data_in(7 downto 0);

    reg_data_out(7 downto 0)  <= filter_out;
    reg_data_out(31 downto 8) <= (others => '0');


    -- Sequential Avalon-MM write
    process(clk)
    begin
        if rising_edge(clk) then

            if reset = '1' then
                reg_data_in  <= (others => '0');
                sample_valid <= '0';

            else
                -- Default makes sample_valid a one-clock pulse
                sample_valid <= '0';

                if avs_write = '1' and avs_address = "0" then
                    reg_data_in  <= avs_writedata;
                    sample_valid <= '1';
                end if;

            end if;
        end if;
    end process;


    -- Combinational Avalon-MM read
    process(avs_read, avs_address, reg_data_out, reg_data_in)
    begin
        avs_readdata <= (others => '0');

        if avs_read = '1' then
            case avs_address is

                when "0" =>
                    avs_readdata <= reg_data_in;

                when "1" =>
                    avs_readdata <= reg_data_out;

                when others =>
                    avs_readdata <= (others => '0');

            end case;
        end if;
    end process;

end architecture;