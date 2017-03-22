library IEEE, XIL_DEFAULTLIB;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use XIL_DEFAULTLIB.xil_defaultlib_components_pkg.all;
-------------------------------------------------------------------------------
entity clk_gen is
    port (
        sys_clk     : in std_logic;
        sys_nreset  : in std_logic;
        clk_100m    : out std_logic;
        reset       : out std_logic
    );
end clk_gen;
-------------------------------------------------------------------------------
architecture struct of clk_gen is

    signal nreset       : std_logic;

begin

    reset               <= not nreset;

    mmcm : clk_wiz_0
    port map (
        clk_in1         => sys_clk,
        resetn          => sys_nreset,
        clk_out1        => clk,
        locked          => nreset
    );

end struct;