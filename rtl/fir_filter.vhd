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
        variable current_sum : signed(9 downto 0);
    begin
        if rising_edge(clk) then

            if rst = '1' then
                pipe     <= (others => (others => '0'));
                sum      <= (others => '0');
                data_out <= (others => '0');

            elsif sample_valid = '1' then

                -- Current input plus the previous three samples
                current_sum :=
                      resize(signed(data_in), 10)
                    + resize(pipe(0), 10)
                    + resize(pipe(1), 10)
                    + resize(pipe(2), 10);

                -- Keep registered sum for visibility/debugging
                sum <= current_sum;

                -- Output the corresponding 4-sample average immediately
                data_out <= std_logic_vector(
                    resize(shift_right(current_sum, 2), 8)
                );

                -- Shift sample history
                pipe(3) <= pipe(2);
                pipe(2) <= pipe(1);
                pipe(1) <= pipe(0);
                pipe(0) <= signed(data_in);

            end if;
        end if;
    end process;

end architecture;