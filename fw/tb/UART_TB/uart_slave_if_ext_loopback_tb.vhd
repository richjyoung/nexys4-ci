library vunit_lib;
context vunit_lib.vunit_context;
library DESIGN, IEEE, UART;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use UART.uart_components_pkg.all;
use DESIGN.records.all;
-------------------------------------------------------------------------------
entity uart_slave_if_ext_loopback_tb is
    generic (runner_cfg : string);
end uart_slave_if_ext_loopback_tb;
-------------------------------------------------------------------------------
architecture tb of uart_slave_if_ext_loopback_tb is

    constant sym_time       : time          := (real(1)/real(115200)) * (1000 ms);

    signal clk              : std_logic     := '1';
    signal reset            : std_logic;

    signal data_in          : std_logic_vector(7 downto 0);
    signal data_in_valid    : std_logic;
    signal uart_in          : uart_slave_in_t;
    signal busy             : std_logic;
    signal data_out         : std_logic_vector(7 downto 0);
    signal data_out_valid   : std_logic;
    signal uart_out         : uart_slave_out_t;

begin
    clk                 <= not clk after 5 ns;

    uart_in.txd         <= uart_out.rxd;
    uart_in.rts         <= '1';

    tb_proc: process
    begin
        test_runner_setup(runner, runner_cfg);

        reset           <= '1';
        data_in_valid   <= '0';
        wait until rising_edge(clk);
        reset           <= '0';
        wait for 100 ns;

        while test_suite loop
            if run("single_byte") then

                -- Start
                data_in         <= X"AA";
                data_in_valid   <= '1';
                wait until rising_edge(clk);
                data_in_valid   <= '0';

                wait until data_out_valid = '1';
                check(data_out = X"AA", "Data output does not match");

                wait until busy = '0';
                wait for 100 ns;
            elsif run("two_bytes") then

                data_in         <= X"AA";
                data_in_valid   <= '1';
                wait until rising_edge(clk);
                data_in_valid   <= '0';

                wait until data_out_valid = '1';
                check(data_out = X"AA", "Data output does not match");

                wait until busy = '0';

                data_in         <= X"55";
                data_in_valid   <= '1';
                wait until rising_edge(clk);
                data_in_valid   <= '0';

                wait until data_out_valid = '1';
                check(data_out = X"55", "Data output does not match", warning);

                wait until busy = '0';
                wait for 100 ns;
            end if;
        end loop;

        test_runner_cleanup(runner);
    end process tb_proc;

    slave_if: uart_slave_if
    generic map (
        loopback_g      => false
    )
    port map (
        clk             => clk,
        reset           => reset,
        data_in         => data_in,
        data_in_valid   => data_in_valid,
        uart_in         => uart_in,
        busy            => busy,
        data_out        => data_out,
        data_out_valid  => data_out_valid,
        uart_out        => uart_out
    );

end tb;