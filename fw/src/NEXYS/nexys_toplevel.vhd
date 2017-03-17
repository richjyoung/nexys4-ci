library DESIGN, IEEE, IO, XIL_DEFAULTLIB;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IO.io_components_pkg.all;
use DESIGN.records.all;
use XIL_DEFAULTLIB.xil_defaultlib_components_pkg.all;
-------------------------------------------------------------------------------
entity nexys_toplevel is
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
end nexys_toplevel;
-------------------------------------------------------------------------------
architecture rtl of nexys_toplevel is

    -- Busses
    signal hmi_in           : hmi_in_t;
    signal hmi_out          : hmi_out_t;
    signal uart_in          : uart_in_t;
    signal uart_out         : uart_out_t;

    -- Metastability signals
    signal sw_filtered      : std_logic_vector(sw'range);
    signal uart_in_async    : std_logic_vector(1 downto 0);
    signal uart_in_filtered : std_logic_vector(1 downto 0);

    -- Clock & Reset
    signal clk              : std_logic;
    signal nreset           : std_logic;
    signal reset            : std_logic;

begin

    reset           <= not nreset;

    -- HMI
    hmi_in.sw       <= sw_filtered;
    led             <= hmi_out.led;

    -- UART
    uart_in_async   <= uart_txd & uart_rts;
    uart_in.rxd     <= uart_in_filtered(1);
    uart_in.cts     <= uart_in_filtered(0);
    uart_rxd        <= uart_out.txd;
    uart_cts        <= uart_out.rts;


    ---------------------------------------------------------------------------
    -- IO Wrapper
    ---------------------------------------------------------------------------
    io_wrapper: nexys_io_wrapper
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

    mmcm : clk_wiz_0
    port map (
        clk_in1         => clk_100mhz,
        resetn          => cpu_reset,
        clk_out1        => clk,
        locked          => nreset
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