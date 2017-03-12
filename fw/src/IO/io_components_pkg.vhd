library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--------------------------------------------------------------------------------
package io_components_pkg is

    component io_metastability_filter is
        generic (
            width_g         : integer := 1
        );
        port (
            clk             : in  std_logic;
            reset           : in  std_logic;
            async           : in  std_logic_vector(width_g-1 downto 0);
            filtered        : out std_logic_vector(width_g-1 downto 0)
        );
    end component;

end package io_components_pkg;
--------------------------------------------------------------------------------
package body io_components_pkg is
end package body io_components_pkg;