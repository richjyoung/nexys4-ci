library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--------------------------------------------------------------------------------
package xil_defaultlib_components_pkg is

    component clk_wiz_0
        port
        (-- Clock in ports
        -- Clock out ports
            clk_out1          : out    std_logic;
            -- Status and control signals
            resetn            : in     std_logic;
            locked            : out    std_logic;
            clk_in1           : in     std_logic
        );
    end component;

end package xil_defaultlib_components_pkg;
--------------------------------------------------------------------------------
package body xil_defaultlib_components_pkg is
end package body xil_defaultlib_components_pkg;