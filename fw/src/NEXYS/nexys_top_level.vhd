library NEXYS, IEEE, UART;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use UART.uart_components_pkg.all;
use NEXYS.nexys_top_level_pkg.all;
-------------------------------------------------------------------------------
entity nexys_top_level is
    generic (
        testbench_g     : boolean := false;
        freq_g          : integer := 100e6
    );
    port (
        clk             : in  std_logic;
        reset           : in  std_logic;
        hmi_in          : in  hmi_in_t;
        hmi_out         : out hmi_out_t;
        uart_in         : in  uart_slave_in_t;
        uart_out        : out uart_slave_out_t
    );
end nexys_top_level;
-------------------------------------------------------------------------------
architecture rtl of nexys_top_level is
begin

    process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                reset_bus(hmi_out);
            else
                hmi_out.led     <= hmi_in.sw;
            end if;
        end if;
    end process;

    uart_if: uart_slave_if
    generic map (
        loopback_g      => true
    )
    port map (
        clk             => clk,
        reset           => reset,
        data_in         => X"00",
        data_in_valid   => '0',
        uart_in         => uart_in,
        busy            => open,
        data_out        => open,
        data_out_valid  => open,
        uart_out        => uart_out
    );

end rtl;