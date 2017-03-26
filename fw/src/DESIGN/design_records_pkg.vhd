library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
-------------------------------------------------------------------------------
package records is

    -- HMI Interface
    constant led_count_c    : integer := 16;
    constant sw_count_c     : integer := 16;

    type hmi_out_t is record
        led     : std_logic_vector(led_count_c-1 downto 0);
    end record hmi_out_t;

    type hmi_in_t is record
        sw      : std_logic_vector(sw_count_c-1 downto 0);
    end record hmi_in_t;

    procedure reset_bus(signal hmi_out : out hmi_out_t);

    -- UART
    type uart_slave_out_t is record
        rxd     : std_logic;
        cts     : std_logic;
    end record uart_slave_out_t;

    type uart_slave_in_t is record
        txd     : std_logic;
        rts     : std_logic;
    end record uart_slave_in_t;

    procedure reset_bus(signal uart_out : out uart_slave_out_t);

    -- Component
    component nexys_io_wrapper is
        generic (
            testbench_g     : boolean := false;
            freq_g          : integer := 100e6
        );
        port (
            clk             : in  std_logic;
            reset           : in  std_logic;
            hmi_in          : in  hmi_in_t;
            hmi_out         : out hmi_out_t;
            uart_in         : in  uart_slave_in_t;
            uart_out        : out uart_slave_out_t
        );
    end component;

end package records;
-------------------------------------------------------------------------------
package body records is

    -- Reset LED Bus
    procedure reset_bus(signal hmi_out : out hmi_out_t) is
    begin
        hmi_out.led     <= (others => '0');
    end reset_bus;

    -- Reset UART output
    procedure reset_bus(signal uart_out : out uart_slave_out_t) is
    begin
        uart_out.rxd     <= '1';
        uart_out.cts     <= '0';
    end reset_bus;

end package body records;