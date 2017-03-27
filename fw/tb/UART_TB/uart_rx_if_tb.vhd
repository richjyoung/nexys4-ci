library vunit_lib;
context vunit_lib.vunit_context;
library NEXYS, IEEE, UART;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use UART.uart_components_pkg.all;
use NEXYS.nexys_top_level_pkg.all;
-------------------------------------------------------------------------------
entity uart_rx_if_tb is
    generic (runner_cfg : string);
end uart_rx_if_tb;
-------------------------------------------------------------------------------
architecture tb of uart_rx_if_tb is

    constant sym_time   : time          := (real(1)/real(115200)) * (1000 ms);

    signal clk          : std_logic     := '1';
    signal reset        : std_logic;
    signal uart_in      : std_logic;
    signal data         : std_logic_vector(7 downto 0);
    signal data_valid   : std_logic;

begin
    clk                 <= not clk after 5 ns;

    tb_proc: process
    begin
        test_runner_setup(runner, runner_cfg);

        reset           <= '1';
        uart_in         <= '1';
        wait until rising_edge(clk);
        wait for 100 ns;
        reset           <= '0';

        while test_suite loop
            if run("single_byte") then

                -- Start
                uart_in         <= '0';
                wait for sym_time;
                
                uart_in         <= '1'; wait for sym_time; -- Bit 0
                uart_in         <= '0'; wait for sym_time; -- Bit 1
                uart_in         <= '1'; wait for sym_time; -- Bit 2
                uart_in         <= '0'; wait for sym_time; -- Bit 3
                uart_in         <= '1'; wait for sym_time; -- Bit 4
                uart_in         <= '0'; wait for sym_time; -- Bit 5
                uart_in         <= '1'; wait for sym_time; -- Bit 6
                uart_in         <= '0'; wait for sym_time; -- Bit 7

                -- Idle
                uart_in         <= '1';

                -- Check
                wait until data_valid = '1';
                assert data = x"AA";

                wait for 100 ns;
            elsif run("two_bytes") then

                -- Start
                uart_in         <= '0';
                wait for sym_time;
                
                uart_in         <= '1'; wait for sym_time; -- Bit 0
                uart_in         <= '0'; wait for sym_time; -- Bit 1
                uart_in         <= '1'; wait for sym_time; -- Bit 2
                uart_in         <= '0'; wait for sym_time; -- Bit 3
                uart_in         <= '1'; wait for sym_time; -- Bit 4
                uart_in         <= '0'; wait for sym_time; -- Bit 5
                uart_in         <= '1'; wait for sym_time; -- Bit 6
                uart_in         <= '0'; wait for sym_time; -- Bit 7

                -- Idle
                uart_in         <= '1';

                -- Check
                wait until data_valid = '1';
                check(data = x"AA", "Data does not match expected value 0xAA", warning);
                wait until data_valid = '0';

                -- Start
                uart_in         <= '0';
                wait for sym_time;
                
                uart_in         <= '0'; wait for sym_time; -- Bit 0
                uart_in         <= '1'; wait for sym_time; -- Bit 1
                uart_in         <= '0'; wait for sym_time; -- Bit 2
                uart_in         <= '1'; wait for sym_time; -- Bit 3
                uart_in         <= '0'; wait for sym_time; -- Bit 4
                uart_in         <= '1'; wait for sym_time; -- Bit 5
                uart_in         <= '0'; wait for sym_time; -- Bit 6
                uart_in         <= '1'; wait for sym_time; -- Bit 7

                -- Idle
                uart_in         <= '1';

                -- Check
                wait until data_valid = '1';
                check(data = x"55", "Data does not match expected value 0x55", warning);

                wait for 100 ns;
            end if;
        end loop;

        test_runner_cleanup(runner);
    end process tb_proc;

    rx_if: uart_rx_if
    port map (
        clk         => clk,
        reset       => reset,
        uart_in     => uart_in,
        data        => data,
        data_valid  => data_valid
    );

end tb;