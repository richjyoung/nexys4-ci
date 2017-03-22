library DESIGN, IEEE, LFSR;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use LFSR.lfsr.all;
use DESIGN.records.all;
-------------------------------------------------------------------------------
entity uart_rx_if is
    generic (
        freq_g          : integer       := 100e6;
        baud_rate_g     : integer       := 115200;
        parity_g        : boolean       := false;
        data_bits_g     : integer       := 8
    );
    port (
        clk             : in  std_logic;
        reset           : in  std_logic;
        uart_in         : in  uart_in_t;
        data            : out std_logic_vector(data_bits_g-1 downto 0);
        data_valid      : out std_logic
    );
end uart_rx_if;
-------------------------------------------------------------------------------
architecture rtl of uart_rx_if is
    -- http://www.gaisler.com/doc/vhdl2proc.pdf

    constant baud_clks_c    : integer := integer(real(freq_g) / real(baud_rate_g));
    constant lfsr_width_c   : integer := integer(ceil(log2(real(baud_clks_c))));

    subtype lfsr_t is std_logic_vector(lfsr_width_c-1 downto 0);
    signal lfsr             : lfsr_t;
    constant lfsr_max_c     : lfsr_t := lfsr_evaluate(lfsr, baud_clks_c);
    constant lfsr_half_c    : lfsr_t := lfsr_evaluate(lfsr, baud_clks_c/2);

    signal baud_pulse       : std_logic;
    signal sample_pulse     : std_logic;

    signal data_int         : std_logic_vector(data'range);
    signal data_int_valid   : std_logic_vector(data'range);

    type rx_state_t is (
        idle,
        start_bit,
        data_bits,
        stop_bit
    );
    signal rx_state         : rx_state_t;

begin

    baud_pulse              <= '1' when lfsr = lfsr_max_c else '0';
    sample_pulse            <= '1' when lfsr = lfsr_half_c else '0';

    sequential_logic: process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                lfsr                    <= (others => '0');
                rx_state                <= idle;
                data_int_valid          <= (others => '0');
                data_valid              <= '0';

            else

                lfsr_advance(lfsr, lfsr_max_c);
                data_valid              <= '0';

                case rx_state is
                    when idle =>
                        if uart_in.rxd = '0' then
                            rx_state        <= start_bit;
                            lfsr            <= (others => '0');
                        end if;

                    when start_bit =>
                        if baud_pulse = '1' then
                            rx_state        <= data_bits;
                        end if;

                    when data_bits =>
                        if sample_pulse = '1' then
                            data_int        <= data_int(data_int'high-1 downto 0)
                                                & uart_in.rxd;
                            data_int_valid  <= data_int_valid(data_int_valid'high-1 downto 0)
                                                & '1';
                        end if;
                        if baud_pulse = '1' then
                            if data_int_valid = (data_int_valid'range => '1') then
                                rx_state    <= stop_bit;
                            end if;
                        end if;

                    when stop_bit =>
                        data_int_valid      <= (others => '0');
                        if sample_pulse = '1' then
                            rx_state        <= idle;
                            data            <= data_int;
                            data_valid      <= '1';
                        end if;

                end case;
            end if;
        end if;
    end process sequential_logic;

end rtl;