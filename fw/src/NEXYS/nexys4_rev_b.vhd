library NEXYS, DEVICE, IEEE, IO;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IO.io_components_pkg.all;
use DEVICE.device_components_pkg.all;
use NEXYS.nexys_top_level_pkg.all;
-------------------------------------------------------------------------------
entity nexys4_rev_b is
    generic (
        testbench_g     : boolean := false;
        freq_g          : integer := 100e6
    );
    port (
        -- Clock & Reset
        clk_100mhz   	: in  std_logic;
        cpu_reset   	: in  std_logic;
        -- LEDs & Switches
        led         	: out std_logic_vector(15 downto 0);
        sw              : in  std_logic_vector(15 downto 0);
        -- UART
        uart_txd        : in  std_logic;
        uart_rts        : in  std_logic;
        uart_rxd        : out std_logic;
        uart_cts        : out std_logic
    );
end nexys4_rev_b;
-------------------------------------------------------------------------------
architecture rtl of nexys4_rev_b is

    -- Busses
    signal hmi_in           : hmi_in_t;
    signal hmi_out          : hmi_out_t;
    signal uart_in          : uart_slave_in_t;
    signal uart_out         : uart_slave_out_t;

    -- Metastability signals
    signal sw_filtered      : std_logic_vector(sw'range);
    signal uart_in_async    : std_logic_vector(1 downto 0);
    signal uart_in_filtered : std_logic_vector(1 downto 0);

    -- Clock & Reset
    signal clk              : std_logic;
    signal reset            : std_logic;

begin

    -- HMI
    hmi_in.sw       <= sw_filtered;
    led             <= hmi_out.led;

    -- UART
    uart_in_async   <= uart_txd & uart_rts;
    uart_in.txd     <= uart_in_filtered(1);
    uart_in.rts     <= uart_in_filtered(0);
    uart_rxd        <= uart_out.rxd;
    uart_cts        <= uart_out.cts;


    ---------------------------------------------------------------------------
    -- Design Top Level
    ---------------------------------------------------------------------------
    top_level: nexys_top_level
    generic map (
        testbench_g     => testbench_g,
        freq_g          => freq_g
    )
    port map (
        clk             => clk,
        reset           => reset,
        hmi_in          => hmi_in,
        hmi_out         => hmi_out,
        uart_in         => uart_in,
        uart_out        => uart_out
    );


    ---------------------------------------------------------------------------
    -- Signal Conditioning
    ---------------------------------------------------------------------------

    clk_reset : clk_gen
    port map (
        sys_clk         => clk_100mhz,
        sys_nreset      => cpu_reset,
        clk_100m        => clk,
        reset           => reset
    );

    sw_metastability_filter: io_metastability_filter
    generic map (
        width_g         => sw'length
    )
    port map (
        clk             => clk,
        reset           => reset,
        async           => sw,
        filtered        => sw_filtered
    );

    uart_metastability_filter: io_metastability_filter
    generic map (
        width_g         => uart_in_async'length
    )
    port map (
        clk             => clk,
        reset           => reset,
        async           => uart_in_async,
        filtered        => uart_in_filtered
    );

end rtl;