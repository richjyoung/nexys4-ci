library vunit_lib;
context vunit_lib.vunit_context;
library DESIGN, IEEE, UART;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use UART.uart_components_pkg.all;
use DESIGN.records.all;
-------------------------------------------------------------------------------
entity uart_direct_loopback_tb is
    generic (runner_cfg : string);
end uart_direct_loopback_tb;
-------------------------------------------------------------------------------
architecture tb of uart_direct_loopback_tb is

    signal clk          : std_logic := '1';
    signal reset        : std_logic;
    signal uart_in      : uart_in_t;
    signal uart_out     : uart_out_t;

begin
    clk                 <= not clk after 5 ns;

    tb_proc: process
    begin
        test_runner_setup(runner, runner_cfg);

        reset           <= '1';
        uart_in.rxd     <= '1';
        uart_in.cts     <= '0';
        wait until rising_edge(clk);

        while test_suite loop
            if run("reset") then
                report("Waiting for rising edge");
                wait until rising_edge(clk);
                report("Rising edge");
                assert uart_out.txd = '1' report "Invalid TXD reset behaviour";
                assert uart_out.rts = '0' report "Invalid RTS reset behaviour";
                wait for 100 ns;
                
            elsif run("loopback") then
                reset       <= '0';
                uart_in.rxd <= '0';
                uart_in.cts <= '1';
                wait until rising_edge(clk);
                wait until rising_edge(clk);
                assert uart_out.txd = '0' report "Invalid TXD loopback behaviour";
                assert uart_out.rts = '1' report "Invalid RTS loopback behaviour";
                wait for 100 ns;
                
            elsif run("pass") then
                report("pass");
                wait for 100 ns;
            end if;
        end loop;

        test_runner_cleanup(runner);
    end process tb_proc;

    uart_direct_lb: uart_direct_loopback
    port map (
        clk         => clk,
        reset       => reset,
        uart_in     => uart_in,
        uart_out    => uart_out
    );

end tb;