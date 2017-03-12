library IEEE, NEXYS;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use NEXYS.nexys_io_wrapper_pkg.all;
-------------------------------------------------------------------------------
entity uart_direct_loopback is
    port (
        clk             : in  std_logic;
        reset           : in  std_logic;
        uart_in         : in  uart_in_t;
        uart_out        : out uart_out_t
    );
end uart_direct_loopback;
-------------------------------------------------------------------------------
architecture rtl of uart_direct_loopback is
begin

    process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                reset_bus(uart_out);
            else
                uart_out.txd    <= uart_in.rxd;
                uart_out.rts    <= uart_in.cts;
            end if;
        end if;
    end process;

end rtl;