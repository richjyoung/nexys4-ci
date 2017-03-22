library DESIGN, IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use DESIGN.records.all;
--------------------------------------------------------------------------------
package uart_components_pkg is

    component uart_direct_loopback is
        port (
            clk             : in  std_logic;
            reset           : in  std_logic;
            uart_in         : in  uart_in_t;
            uart_out        : out uart_out_t
        );
    end component uart_direct_loopback;

    component uart_rx_if is
    generic (
        baud_rate_g     : integer       := 115200;
        parity_g        : boolean       := false;
        data_bits_g     : integer       := 8
    );
    port (
        clk             : in  std_logic;
        reset           : in  std_logic;
        uart_in         : in  uart_in_t;
        data            : out std_logic_vector(data_bits_g-1 downto 0);
        data_valid      : out std_logic
    );
    end component uart_rx_if;

end package uart_components_pkg;
--------------------------------------------------------------------------------
package body uart_components_pkg is
end package body uart_components_pkg;