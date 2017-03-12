library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
-------------------------------------------------------------------------------
entity io_metastability_filter is
    generic (
        width_g         : integer := 1
    );
    port (
        clk             : in  std_logic;
        reset           : in  std_logic;
        async           : in  std_logic_vector(width_g-1 downto 0);
        filtered        : out std_logic_vector(width_g-1 downto 0)
    );
end io_metastability_filter;
-------------------------------------------------------------------------------
architecture rtl of io_metastability_filter is
    signal reg_1        : std_logic_vector(width_g-1 downto 0);
    signal reg_2        : std_logic_vector(width_g-1 downto 0);
begin

    filtered            <= reg_2;

    process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then

                reg_1           <= (others => '0');
                reg_2           <= (others => '0');

            else

                reg_1           <= async;
                reg_2           <= reg_1;

            end if;
        end if;
    end process;

end rtl;