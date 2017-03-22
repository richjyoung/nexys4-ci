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

end package device_components_pkg;
--------------------------------------------------------------------------------
package body device_components_pkg is
end package body device_components_pkg;