library DESIGN, IEEE, LFSR, UART;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use LFSR.lfsr.all;
use DESIGN.records.all;
use UART.uart_components_pkg.all;
-------------------------------------------------------------------------------
entity uart_slave_if is
    generic (
        freq_g          : integer       := 100e6;
        baud_rate_g     : integer       := 115200;
        parity_g        : boolean       := false;
        data_bits_g     : integer       := 8;
        loopback_g      : boolean       := false
    );
    port (
        clk             : in  std_logic;
        reset           : in  std_logic;
        data_in         : in  std_logic_vector(data_bits_g-1 downto 0);
        data_in_valid   : in  std_logic;
        uart_in         : in  uart_slave_in_t;
        busy            : out std_logic;
        data_out        : out std_logic_vector(data_bits_g-1 downto 0);
        data_out_valid  : out std_logic;
        uart_out        : out uart_slave_out_t
    );
end uart_slave_if;
-------------------------------------------------------------------------------
architecture rtl of uart_slave_if is

    signal valid_latch          : std_logic;
    signal busy_int             : std_logic;
    signal data_out_valid_int   : std_logic;
    signal tx_valid_in          : std_logic;
    signal tx_data              : std_logic_vector(data_in'range);
    signal data_out_int         : std_logic_vector(data_out'range);

begin

    uart_out.cts    <= uart_in.rts;
    tx_valid_in     <= valid_latch and (not busy_int);
    tx_data         <= data_out_int when loopback_g else data_in;
    busy            <= busy_int;
    data_out        <= data_out_int;
    data_out_valid  <= data_out_valid_int;

    loopback_mode: if loopback_g generate

        seq_logic: process (clk)
        begin
            if rising_edge(clk) then
                if reset = '1' then
                    valid_latch         <= '0';
                else
                    if busy_int = '0' then
                        valid_latch     <= '0';
                    end if;
                    if data_out_valid_int = '1' then
                        valid_latch     <= '1';
                    end if;
                end if;
            end if;
        end process seq_logic;
    end generate;

    rx_if: uart_rx_if
    port map (
        clk         => clk,
        reset       => reset,
        uart_in     => uart_in.txd,
        data        => data_out_int,
        data_valid  => data_out_valid_int
    );

    tx_if: uart_tx_if
    port map (
        clk         => clk,
        reset       => reset,
        data        => tx_data,
        data_valid  => tx_valid_in,
        uart_out    => uart_out.rxd,
        busy        => busy_int
    );

end rtl;