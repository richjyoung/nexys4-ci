library IEEE, NEXYS;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use NEXYS.nexys_top_level_pkg.all;
-------------------------------------------------------------------------------
entity uart_slave_direct_loopback is
    port (
        clk             : in  std_logic;
        reset           : in  std_logic;
        uart_in         : in  uart_slave_in_t;
        uart_out        : out uart_slave_out_t
    );
end uart_slave_direct_loopback;
-------------------------------------------------------------------------------
architecture rtl of uart_slave_direct_loopback is
begin

    process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                reset_bus(uart_out);
            else
                -- Loop host TX -> RX
                uart_out.rxd    <= uart_in.txd;
                -- Clear-To-Send when host is Ready-To-Send
                uart_out.cts    <= uart_in.rts;
            end if;
        end if;
    end process;

end rtl;