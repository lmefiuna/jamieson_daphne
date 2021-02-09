-- kc705_package.vhd
-- constants for the KC705 OEI test firmware
-- Jamieson Olsen <jamieson@fnal.gov>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package kc705_package is

    -- Set Target address here. MAC = 00:80:55:EC:00:0C and IP = 192.168.133.12

    constant OEI_USR_ADDR: std_logic_vector(7 downto 0) := X"0C";

    -- Address Mapping using the std_match notation '-' is a "don't care" bit

    constant BRAM0_ADDR:    std_logic_vector(31 downto 0) := "0000000000000111000000----------";  -- 0x00070000-0x000703FF
    constant DEADBEEF_ADDR: std_logic_vector(31 downto 0) := X"0000aa55";
    constant STATVEC_ADDR:  std_logic_vector(31 downto 0) := X"00001974";
    constant TESTREG_ADDR:  std_logic_vector(31 downto 0) := X"12345678";
    constant FIFO_ADDR:     std_logic_vector(31 downto 0) := X"80000000";

    type array8x36 is array (7 downto 0) of std_logic_vector(35 downto 0);  -- KKKK&data(31..0)


end package;

