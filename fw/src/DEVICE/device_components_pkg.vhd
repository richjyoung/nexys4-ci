library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--------------------------------------------------------------------------------
package device_components_pkg is

    component clk_gen is
        port (
            sys_clk     : in std_logic;
            sys_nreset  : in std_logic;
            clk_100m    : out std_logic;
            reset       : out std_logic
        );
    end component clk_gen;

    component usr_access is
        generic (
            testbench_g         : boolean                           := false;
            testbench_data_g    : std_logic_vector(31 downto 0)     := X"DEADBEEF"
        );
        port (
            usr_access_data : out std_logic_vector(31 downto 0)
        );
    end component usr_access;

end package device_components_pkg;
--------------------------------------------------------------------------------
package body device_components_pkg is
end package body device_components_pkg;