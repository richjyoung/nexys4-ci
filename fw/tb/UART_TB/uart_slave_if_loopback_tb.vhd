library vunit_lib;
context vunit_lib.vunit_context;
library NEXYS, IEEE, UART;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use UART.uart_components_pkg.all;
use NEXYS.nexys_top_level_pkg.all;
-------------------------------------------------------------------------------
entity uart_slave_if_loopback_tb is
    generic (runner_cfg : string);
end uart_slave_if_loopback_tb;
-------------------------------------------------------------------------------
architecture tb of uart_slave_if_loopback_tb is

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

    data_in            <= (others => '0');
    data_in_valid      <= '0';

    tb_proc: process
    begin
        test_runner_setup(runner, runner_cfg);

        reset           <= '1';
        wait until rising_edge(clk);
        reset           <= '0';
        wait for 100 ns;

        while test_suite loop
            if run("single_byte") then

                -- Start
                uart_in.txd     <= '0';
                wait for sym_time;
                
                uart_in.txd     <= '1'; wait for sym_time; -- Bit 0
                uart_in.txd     <= '0'; wait for sym_time; -- Bit 1
                uart_in.txd     <= '1'; wait for sym_time; -- Bit 2
                uart_in.txd     <= '0'; wait for sym_time; -- Bit 3
                uart_in.txd     <= '1'; wait for sym_time; -- Bit 4
                uart_in.txd     <= '0'; wait for sym_time; -- Bit 5
                uart_in.txd     <= '1'; wait for sym_time; -- Bit 6
                uart_in.txd     <= '0'; wait for sym_time; -- Bit 7

                -- Idle
                uart_in.txd     <= '1';

                wait for sym_time * 15;

                wait for 100 ns;
            elsif run("two_bytes") then

                uart_in.txd     <= '0'; wait for sym_time; -- Start
                uart_in.txd     <= '1'; wait for sym_time; -- Bit 0
                uart_in.txd     <= '0'; wait for sym_time; -- Bit 1
                uart_in.txd     <= '1'; wait for sym_time; -- Bit 2
                uart_in.txd     <= '0'; wait for sym_time; -- Bit 3
                uart_in.txd     <= '1'; wait for sym_time; -- Bit 4
                uart_in.txd     <= '0'; wait for sym_time; -- Bit 5
                uart_in.txd     <= '1'; wait for sym_time; -- Bit 6
                uart_in.txd     <= '0'; wait for sym_time; -- Bit 7
                uart_in.txd     <= '1'; wait for sym_time; -- Stop
                uart_in.txd     <= '0'; wait for sym_time; -- Start
                uart_in.txd     <= '0'; wait for sym_time; -- Bit 0
                uart_in.txd     <= '1'; wait for sym_time; -- Bit 1
                uart_in.txd     <= '0'; wait for sym_time; -- Bit 2
                uart_in.txd     <= '1'; wait for sym_time; -- Bit 3
                uart_in.txd     <= '0'; wait for sym_time; -- Bit 4
                uart_in.txd     <= '1'; wait for sym_time; -- Bit 5
                uart_in.txd     <= '0'; wait for sym_time; -- Bit 6
                uart_in.txd     <= '1'; wait for sym_time; -- Bit 7
                uart_in.txd     <= '1'; wait for sym_time; -- Stop

                wait for sym_time * 15;

                wait for 100 ns;
            end if;
        end loop;

        test_runner_cleanup(runner);
    end process tb_proc;

    slave_if: uart_slave_if
    generic map (
        loopback_g      => true
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