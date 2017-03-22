library DESIGN, IEEE, UART;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use UART.uart_components_pkg.all;
use DESIGN.records.all;
-------------------------------------------------------------------------------
entity nexys_io_wrapper is
    generic (
        testbench_g     : boolean := false;
        freq_g          : integer := 100e6
    );
    port (
        clk             : in  std_logic;
        reset           : in  std_logic;
        hmi_in          : in  hmi_in_t;
        hmi_out         : out hmi_out_t;
        uart_in         : in  uart_in_t;
        uart_out        : out uart_out_t
    );
end nexys_io_wrapper;
-------------------------------------------------------------------------------
architecture rtl of nexys_io_wrapper is
begin

    process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                reset_bus(hmi_out);
            else
                hmi_out.led     <= hmi_in.sw;
            end if;
        end if;
    end process;

    uart_direct_lb: uart_direct_loopback
    port map (
        clk         => clk,
        reset       => reset,
        uart_in     => uart_in,
        uart_out    => uart_out
    );

end rtl;