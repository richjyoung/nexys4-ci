library vunit_lib;
context vunit_lib.vunit_context;
library IEEE, DEVICE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use DEVICE.device_components_pkg.all;
-------------------------------------------------------------------------------
entity usr_access_tb is
    generic (runner_cfg : string);
end usr_access_tb;
-------------------------------------------------------------------------------
architecture tb of usr_access_tb is

    signal data         : std_logic_vector(31 downto 0);

begin
    tb_proc: process
    begin
        test_runner_setup(runner, runner_cfg);

        while test_suite loop
            if run("tb_mode") then
                wait for 100 ns;
                check(data = X"DEADBEEF", "TB Mode output does not match expected value");
            end if;
        end loop;

        test_runner_cleanup(runner);
    end process tb_proc;

    usr: usr_access
    generic map (
        testbench_g     => true
    )
    port map (
        usr_access_data => data
    );

end tb;