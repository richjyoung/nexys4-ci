library IEEE, UNISIM;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use UNISIM.vcomponents.all;
-------------------------------------------------------------------------------
entity usr_access is
    generic (
        testbench_g         : boolean                           := false;
        testbench_data_g    : std_logic_vector(31 downto 0)     := X"DEADBEEF"
    );
    port (
        usr_access_data     : out std_logic_vector(31 downto 0)
    );
end usr_access;
-------------------------------------------------------------------------------
architecture struct of usr_access is

    signal data             : std_logic_vector(usr_access_data'range);

begin

    usr_access_data         <= data when (testbench_g = false) 
                                else testbench_data_g;
    
    primitive_gen: if (testbench_g = false) generate
        USR_ACCESS_7series_inst : USR_ACCESSE2
        port map (
            cfgclk          => open,
            data            => data,
            datavalid       => open
        );
    end generate;

end struct;