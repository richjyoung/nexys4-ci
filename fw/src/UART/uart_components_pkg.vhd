library IEEE, NEXYS;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use NEXYS.nexys_io_wrapper_pkg.all;
--------------------------------------------------------------------------------
package uart_components_pkg is

    component uart_direct_loopback is
        port (
            clk             : in  std_logic;
            reset           : in  std_logic;
            uart_in         : in  uart_in_t;
            uart_out        : out uart_out_t
        );
    end component;

end package uart_components_pkg;
--------------------------------------------------------------------------------
package body uart_components_pkg is
end package body uart_components_pkg;