library DESIGN, IEEE, LFSR;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use LFSR.lfsr.all;
use DESIGN.records.all;
-------------------------------------------------------------------------------
entity uart_tx_if is
    generic (
        freq_g          : integer       := 100e6;
        baud_rate_g     : integer       := 115200;
        parity_g        : boolean       := false;
        data_bits_g     : integer       := 8
    );
    port (
        clk             : in  std_logic;
        reset           : in  std_logic;
        data            : in  std_logic_vector(data_bits_g-1 downto 0);
        data_valid      : in  std_logic;
        uart_out        : out std_logic;
        busy            : out std_logic
    );
begin

    assert (not (busy = '1' and data_valid= '1')) report "DATA_VALID asserted whilst BUSY, ignored." severity warning;
    assert (parity_g = false) report "Parity not supported." severity failure;

end uart_tx_if;
-------------------------------------------------------------------------------
architecture rtl of uart_tx_if is

    constant baud_clks_c    : integer := integer(real(freq_g) / real(baud_rate_g));
    constant lfsr_width_c   : integer := integer(ceil(log2(real(baud_clks_c))));

    subtype lfsr_t is std_logic_vector(lfsr_width_c-1 downto 0);
    signal lfsr             : lfsr_t;
    constant lfsr_max_c     : lfsr_t := lfsr_evaluate(lfsr, baud_clks_c);

    signal baud_pulse       : std_logic;

    signal data_int         : std_logic_vector(data'range);
    signal data_int_valid   : std_logic_vector(data_bits_g-2 downto 0);

    type tx_state_t is (
        idle,
        start_bit,
        data_bits,
        stop_bit
    );
    signal tx_state         : tx_state_t;

begin

    comb_logic: process(all)
    begin

        if (lfsr = lfsr_max_c) then
            baud_pulse                  <= '1';
        else
            baud_pulse                  <= '0';
        end if;

    end process comb_logic;


    seq_logic: process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                tx_state                        <= idle;
                lfsr                            <= (others => '0');
                uart_out                        <= '1';
                busy                            <= '0';

            else

                lfsr_advance(lfsr, lfsr_max_c);

                case tx_state is
                    when idle =>
                        uart_out                <= '1';
                        busy                    <= '0';
                        -- Hold counter at zero until start detected
                        lfsr                    <= (others => '0');
                        -- Set data valid
                        data_int_valid          <= (others => '1');
                        -- Wait for data
                        if data_valid = '1' then
                            tx_state            <= start_bit;
                            data_int            <= data;
                            busy                <= '1';
                        end if;

                    when start_bit =>
                        uart_out                <= '0';
                        -- Wait for one symbol
                        if baud_pulse = '1' then
                            tx_state            <= data_bits;
                        end if;

                    when data_bits =>
                        uart_out                <= data_int(data_int'high);
                        if baud_pulse = '1' then
                            if data_int_valid = (data_int_valid'range => '0') then
                                tx_state        <= stop_bit;
                            else
                                data_int        <= data_int(data_int'high-1 downto 0) & '0';
                                data_int_valid  <= data_int_valid(data_int_valid'high-1 downto 0) & '0';
                            end if;
                        end if;

                    when stop_bit =>
                        uart_out            <= '1';
                        -- Wait for one symbol
                        if baud_pulse = '1' then
                            tx_state        <= idle;
                        end if;
                end case;
            end if;
        end if;
    end process seq_logic;

end rtl;