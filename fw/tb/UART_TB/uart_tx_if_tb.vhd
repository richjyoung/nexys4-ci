library vunit_lib;
context vunit_lib.vunit_context;
library NEXYS, IEEE, UART;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use UART.uart_components_pkg.all;
use NEXYS.nexys_top_level_pkg.all;
-------------------------------------------------------------------------------
entity uart_tx_if_tb is
    generic (runner_cfg : string);
end uart_tx_if_tb;
-------------------------------------------------------------------------------
architecture tb of uart_tx_if_tb is

    constant sym_time   : time          := (real(1)/real(115200)) * (1000 ms);

    signal clk          : std_logic     := '1';
    signal reset        : std_logic;
    signal uart_out     : std_logic;
    signal data         : std_logic_vector(7 downto 0);
    signal data_valid   : std_logic;
    signal busy         : std_logic;

begin
    clk                 <= not clk after 5 ns;

    tb_proc: process
    begin
        test_runner_setup(runner, runner_cfg);

        reset           <= '1';
        data_valid      <= '0';
        wait until rising_edge(clk);
        wait for 100 ns;
        reset           <= '0';

        while test_suite loop
            if run("single_byte") then

                -- Start
                data            <= X"AA";
                data_valid      <= '1';
                wait until rising_edge(clk);
                data_valid      <= '0';
                wait for sym_time * 15;

                -- Check
                
                wait for 100 ns;
            elsif run("two_bytes") then

                -- Start
                data            <= X"AA";
                data_valid      <= '1';
                wait until rising_edge(clk);
                data_valid      <= '0';
                wait until busy = '0';

                data            <= X"55";
                data_valid      <= '1';
                wait until rising_edge(clk);
                data_valid      <= '0';
                wait until busy = '0';
                -- Check
                
                wait for 100 ns;
            end if;
        end loop;

        test_runner_cleanup(runner);
    end process tb_proc;

    tx_if: uart_tx_if
    port map (
        clk         => clk,
        reset       => reset,
        data        => data,
        data_valid  => data_valid,
        uart_out    => uart_out,
        busy        => busy
    );

end tb;