library IEEE, STD;
use IEEE.std_logic_1164.all;
--------------------------------------------------------------------------------
package body lfsr is

    ----------------------------------------------------------------------------
    -- Procedure: LFSR Advance
    ----------------------------------------------------------------------------
    procedure lfsr_advance (signal REG : inout std_logic_vector) is
        variable TEMP       : std_logic_vector(REG'range);
    begin
        TEMP                := REG;
        lfsr_advance_var(TEMP);
        REG                 <= TEMP;
    end procedure lfsr_advance;

    ----------------------------------------------------------------------------
    -- Procedure: LFSR Advance
    ----------------------------------------------------------------------------
    procedure lfsr_advance (
        signal REG          : inout std_logic_vector;
        constant RESET      : in std_logic_vector
    ) is
        variable TEMP       : std_logic_vector(REG'range);
    begin
        TEMP                := REG;
        lfsr_advance_var(TEMP, RESET);
        REG                 <= TEMP;
    end procedure lfsr_advance;

    ----------------------------------------------------------------------------
    -- Procedure: LFSR Advance (Variable)
    ----------------------------------------------------------------------------
    procedure lfsr_advance_var (variable REG : inout std_logic_vector) is
        variable INDEX      : integer;
        variable FEEDBACK   : std_logic;
    begin
        INDEX               := REG'length;
        if REG'ascending then
            FEEDBACK            := REG(C_TAPTABLE(INDEX, 0) - REG'length + 1); -- Start with first tap value
            for I in 1 to C_TAPTABLE_WIDTH-1 loop -- Iterate over all taps
                if C_TAPTABLE(INDEX, I) /= 0 then -- Mask invalid taps
                    FEEDBACK    := FEEDBACK xnor REG(C_TAPTABLE(INDEX, I) - REG'length + 1); -- XNOR next tap value
                end if;
            end loop;
            REG                 := REG(1 to REG'high) & FEEDBACK; -- Shift LFSR register and append feedback value
        else
            FEEDBACK            := REG(C_TAPTABLE(INDEX, 0) - 1); -- Start with first tap value
            for I in 1 to C_TAPTABLE_WIDTH-1 loop -- Iterate over all taps
                if C_TAPTABLE(INDEX, I) /= 0 then -- Mask invalid taps
                    FEEDBACK    := FEEDBACK xnor REG(C_TAPTABLE(INDEX, I) - 1); -- XNOR next tap value
                end if;
            end loop;
            REG                 := REG(REG'high-1 downto 0) & FEEDBACK; -- Shift LFSR register and append feedback value
        end if;
    end procedure lfsr_advance_var;

    ----------------------------------------------------------------------------
    -- Procedure: LFSR Advance (Variable)
    ----------------------------------------------------------------------------
    procedure lfsr_advance_var (
        variable REG    : inout std_logic_vector;
        constant RESET  : in std_logic_vector
    ) is
    begin
        if REG = RESET then
            REG         := (REG'range => '0');
        else
            lfsr_advance_var(REG);
        end if;
    end procedure lfsr_advance_var;

    ----------------------------------------------------------------------------
    -- Function: LFSR Evaluate
    ----------------------------------------------------------------------------
    function lfsr_evaluate (
        constant REG    : std_logic_vector;
        constant VALUE  : natural
    ) return std_logic_vector is
        variable V_REG  : std_logic_vector(REG'range) := (others => '0');
    begin
        if VALUE > 0 then
            for I in 1 to VALUE loop
                lfsr_advance_var(V_REG);
            end loop;
        end if;
        return V_REG;
    end function lfsr_evaluate;

    ----------------------------------------------------------------------------
    -- Function: LFSR Maximum
    ----------------------------------------------------------------------------
    function lfsr_maximum (constant SIZE : natural) return natural is
    begin
        return 2**SIZE - 1;
    end function lfsr_maximum;

end lfsr;