-- ovec.vhd
-- Jamieson Olsen <jamieson@fnal.gov>
-- 9 May 2014
--
-- 32kbit test vector generator, no output delay.
-- RAM interface is 1024 x 32.
-- Port A is 32 bits wide goes to the FPGA logic and is RW
-- Port B is 32 bit wide and is reserved for this module and is R/O

-- When GO is asserted this module transmits the contents of the blockram 
-- serially at the clk rate.  e.g. at 200MHz 32768 bits x 5ns = 163.84 usec.
--
-- Address 0, 0 is sent first.
-- Address 0x3FF, bit 31 is sent last.
-- 
-- when this module is idle the output Q is zero.
-- 
-- Output may be delayed in 78ps steps, up to 2.5ns.  asserting reset 
-- will force the output delay back to the minimum value.
--
-- This module does not prevent writes to the buffer when operating!
--
-- 10 October 2014: hold value
-- 23 October 2014: add two end states so the last bit of the last 
--                  word is properly held until next GO


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Library UNISIM;
use UNISIM.vcomponents.all;
library UNIMACRO;
use unimacro.Vcomponents.all;

entity ovec is
port(
    clock:  in  std_logic;
    addr:   in  std_logic_vector(9 downto 0);
    din:    in  std_logic_vector(31 downto 0);
    dout:   out std_logic_vector(31 downto 0);
    we:     in  std_logic;

    clk: in  std_logic;
    reset:  in  std_logic;
    go:     in  std_logic;
    q:      out std_logic);
end ovec;

architecture ovec_arch of ovec is

    signal wea : std_logic_vector(3 downto 0);
    signal addrb_reg : std_logic_vector(9 downto 0);
    signal count_reg : std_logic_vector(4 downto 0);
    signal doa, dob, dob_reg : std_logic_vector(31 downto 0);

    type state_type is (rst, wait4go, countup, end1, end2);
    signal state: state_type;

begin

    wea <= "1111" when (we='1') else "0000";

-- BRAM_TDP_MACRO: True Dual Port RAM
-- 7 Series
-- Xilinx HDL Libraries Guide, version 14.7
-- Note - This Unimacro model assumes the port directions to be "downto".
-- Simulation of this model with "to" in the port directions could lead to erroneous results.
--------------------------------------------------------------------------
-- DATA_WIDTH_A/B | BRAM_SIZE | RAM Depth | ADDRA/B Width | WEA/B Width --
-- ===============|===========|===========|===============|=============--
-- 19-36          | "36Kb"    | 1024      | 10-bit        | 4-bit --
-- 10-18          | "36Kb"    | 2048      | 11-bit        | 2-bit --
-- 10-18          | "18Kb"    | 1024      | 10-bit        | 2-bit --
-- 5-9            | "36Kb"    | 4096      | 12-bit        | 1-bit --
-- 5-9            | "18Kb"    | 2048      | 11-bit        | 1-bit --
-- 3-4            | "36Kb"    | 8192      | 13-bit        | 1-bit --
-- 3-4            | "18Kb"    | 4096      | 12-bit        | 1-bit --
-- 2              | "36Kb"    | 16384     | 14-bit        | 1-bit --
-- 2              | "18Kb"    | 8192      | 13-bit        | 1-bit --
-- 1              | "36Kb"    | 32768     | 15-bit        | 1-bit --
-- 1              | "18Kb"    | 16384     | 14-bit        | 1-bit --
--------------------------------------------------------------------------
BRAM_TDP_MACRO_inst : BRAM_TDP_MACRO
generic map (
    BRAM_SIZE     => "36Kb", -- Target BRAM, "18Kb" or "36Kb"
    DEVICE        => "7SERIES", -- Target Device: "VIRTEX5", "VIRTEX6", "7SERIES", "SPARTAN6"
    DOA_REG       => 1, -- Optional port A output register (0 or 1)
    DOB_REG       => 1, -- Optional port B output register (0 or 1)
    INIT_A        => X"000000000", -- Initial values on A output port
    INIT_B        => X"000000000", -- Initial values on B output port
    INIT_FILE     => "NONE",
    READ_WIDTH_A  => 32, -- Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
    READ_WIDTH_B  => 32, -- Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
    SIM_COLLISION_CHECK => "NONE", -- Collision check enable "ALL", "WARNING_ONLY", "GENERATE_X_ONLY" or "NONE"
    SRVAL_A       => X"000000000", -- Set/Reset value for A port output
    SRVAL_B       => X"000000000", -- Set/Reset value for B port output
    WRITE_MODE_A  => "WRITE_FIRST", -- "WRITE_FIRST", "READ_FIRST" or "NO_CHANGE"
    WRITE_MODE_B  => "WRITE_FIRST", -- "WRITE_FIRST", "READ_FIRST" or "NO_CHANGE"
    WRITE_WIDTH_A => 32, -- Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
    WRITE_WIDTH_B => 32, -- Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
    -- The following INIT_xx declarations specify the initial contents of the RAM
    INIT_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_0F => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_10 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_11 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_12 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_13 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_14 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_15 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_16 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_17 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_18 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_19 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_1A => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_1B => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_1C => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_1D => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_1E => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_1F => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_20 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_21 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_22 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_23 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_24 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_25 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_26 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_27 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_28 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_29 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_2A => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_2B => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_2C => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
    -- The next set of INIT_xx are valid when configured as 36Kb
    INIT_40 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_41 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_42 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_43 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_44 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_45 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_46 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_47 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_48 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_49 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_4A => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_4B => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_4C => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_4D => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_4E => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_4F => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_50 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_51 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_52 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_53 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_54 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_55 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_56 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_57 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_58 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_59 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_5A => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_5B => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_5C => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_5D => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_5E => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_5F => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_60 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_61 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_62 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_63 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_64 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_65 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_66 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_67 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_68 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_69 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_6A => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_6B => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_6C => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_6D => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_6E => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_6F => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_70 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_71 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_72 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_73 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_74 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_75 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_76 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
    INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
    -- The next set of INITP_xx are for the parity bits
    INITP_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
    -- The next set of INIT_xx are valid when configured as 36Kb
    INITP_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INITP_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
    INITP_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
    INITP_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
    INITP_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
    INITP_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
    INITP_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
    INITP_0F => X"0000000000000000000000000000000000000000000000000000000000000000")
port map(
    DOA => dout,      -- Output port-A data, width defined by READ_WIDTH_A parameter
    DOB => dob,       -- Output port-B data, width defined by READ_WIDTH_B parameter
    ADDRA => addr,    -- Input port-A address, width defined by Port A depth
    ADDRB => addrb_reg, -- Input port-B address, width defined by Port B depth
    CLKA => clock,    -- 1-bit input port-A clock
    CLKB => clk,      -- 1-bit input port-B clock
    DIA => din,       -- Input port-A data, width defined by WRITE_WIDTH_A parameter
    DIB => X"00000000",       -- Input port-B data, width defined by WRITE_WIDTH_B parameter
    ENA => '1',       -- 1-bit input port-A enable
    ENB => '1',       -- 1-bit input port-B enable
    REGCEA => '1',    -- 1-bit input port-A output register enable
    REGCEB => '1',    -- 1-bit input port-B output register enable
    RSTA => '0',      -- 1-bit input port-A reset
    RSTB => '0',      -- 1-bit input port-B reset
    WEA => wea,       -- Input port-A write enable, width defined by Port A depth
    WEB => "0000");   -- Input port-B write enable, width defined by Port B depth


fsm_proc: process(clk)
begin
    if rising_edge(clk) then
        if (reset='1') then
            state <= rst;
            dob_reg <= X"00000000";
        else
            case state is

                when rst =>
                    state <= wait4go;
                    addrb_reg <= "0000000000";
                    count_reg <= "00000";

                when wait4go =>
                    if ( go='1' ) then
                        state <= countup;
                        addrb_reg <= "0000000000";
                        count_reg <= "00000";
                    else
                        state <= wait4go;
                        -- dob_reg <= X"00000000";
                    end if;

                when countup =>
                    if ( count_reg = "11111" ) then
                        if ( addrb_reg = "1111111111" ) then
                            state <= end1; -- wait4go;
                        else
                            count_reg <= "00000";
                            addrb_reg <= std_logic_vector(unsigned(addrb_reg) + 1);
                        end if;
                    else -- shift
                        count_reg <= std_logic_vector(unsigned(count_reg) + 1);
                    end if;

                    if ( count_reg = "00010" ) then
                        dob_reg <= dob;
                    else
                        dob_reg <= '0' & dob_reg(31 downto 1);  -- shift RIGHT
                    end if;

                when end1 =>
                    dob_reg <= '0' & dob_reg(31 downto 1);  -- shift RIGHT
                    state <= end2;

                when end2 =>
                    dob_reg <= '0' & dob_reg(31 downto 1);  -- LAST shift RIGHT, hold final bit
                    state <= wait4go;

            end case;

        end if;
    end if;

end process fsm_proc;

q <= dob_reg(0);

end ovec_arch;

