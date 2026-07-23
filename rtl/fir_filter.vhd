library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_filter is
    port (
        clk          : in  std_logic;
        rst          : in  std_logic;
        sample_valid : in  std_logic;  -- NEW: pulse for each new input sample
        data_in      : in  std_logic_vector(7 downto 0);  -- 8-bit signed input
        data_out     : out std_logic_vector(7 downto 0)   -- 8-bit filtered output
    );
end entity;

architecture rtl of fir_filter is

    type pipe_type is array (0 to 3) of signed(7 downto 0);

    signal pipe : pipe_type :=
        (others => (others => '0'));

    signal sum : signed(9 downto 0) :=
        (others => '0');  -- Extra bits to prevent overflow

begin

    process(clk)
    begin
        if rising_edge(clk) then

            if rst = '1' then
                pipe     <= (others => (others => '0'));
                sum      <= (others => '0');
                data_out <= (others => '0');

            elsif sample_valid = '1' then

                -- Shift register only when a new sample is written
                pipe(0) <= signed(data_in);
                pipe(1) <= pipe(0);
                pipe(2) <= pipe(1);
                pipe(3) <= pipe(2);

                -- Sum the four FIR taps
                sum <= resize(pipe(0), 10)
                     + resize(pipe(1), 10)
                     + resize(pipe(2), 10)
                     + resize(pipe(3), 10);

                -- Divide by 4 using arithmetic right shift by 2 bits
                data_out <= std_logic_vector(
                    resize(shift_right(sum, 2), 8)
                );

            end if;
        end if;
    end process;

end architecture;