-- daphne_package.vhd
-- Jamieson Olsen <jamieson@fnal.gov>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package daphne_package is

    -- Set static ethernet addresses here. MAC = 00:80:55:EC:00:0C and IP = 192.168.133.12

    constant OEI_USR_ADDR: std_logic_vector(7 downto 0) := X"0C";

    -- Address Mapping using the std_match notation '-' is a "don't care" bit

    constant BRAM0_ADDR:    std_logic_vector(31 downto 0) := "0000000000000111000000----------";  -- 0x00070000-0x000703FF
    constant DEADBEEF_ADDR: std_logic_vector(31 downto 0) := X"0000aa55";
    constant STATVEC_ADDR:  std_logic_vector(31 downto 0) := X"00001974";
    constant GITVER_ADDR:   std_logic_vector(31 downto 0) := X"00009000";
    constant TESTREG_ADDR:  std_logic_vector(31 downto 0) := X"12345678";
    constant FIFO_ADDR:     std_logic_vector(31 downto 0) := X"80000000";

    type array45x14_type is array (44 downto 0) of std_logic_vector(13 downto 0);
    type array45x16_type is array (44 downto 0) of std_logic_vector(15 downto 0);
    type array45x5_type  is array (44 downto 0) of std_logic_vector(4 downto 0);

    -- DAPHNE specific addresses

    -- write anything to force trigger

    constant TRIGGER_ADDR:      std_logic_vector(31 downto 0) := X"00002000";

    -- address to force reset of the AFE front end logic

    constant RESETFE_ADDR:    std_logic_vector(31 downto 0) := X"00002001";

    -- 45 addresses write anything to this address to bitslip AFE channel 0x3000 - 0x302C

    constant BITSLIP_BASEADDR:  std_logic_vector(31 downto 0) := X"00003000";

    -- 45 addresses, 5 bit delay values 0x4000-0x402C

    constant DELAY_BASEADDR:    std_logic_vector(31 downto 0) := X"00004000";

    -- 45 spy buffers align on 64k boundaries (0x0000-0x3FFF)

    constant SPYBUF00_BASEADDR: std_logic_vector(31 downto 0) := "0100000000000000----------------";
    constant SPYBUF01_BASEADDR: std_logic_vector(31 downto 0) := "0100000000000001----------------";
    constant SPYBUF02_BASEADDR: std_logic_vector(31 downto 0) := "0100000000000010----------------";
    constant SPYBUF03_BASEADDR: std_logic_vector(31 downto 0) := "0100000000000011----------------";
    constant SPYBUF04_BASEADDR: std_logic_vector(31 downto 0) := "0100000000000100----------------";
    constant SPYBUF05_BASEADDR: std_logic_vector(31 downto 0) := "0100000000000101----------------";
    constant SPYBUF06_BASEADDR: std_logic_vector(31 downto 0) := "0100000000000110----------------";
    constant SPYBUF07_BASEADDR: std_logic_vector(31 downto 0) := "0100000000000111----------------";
    constant SPYBUF08_BASEADDR: std_logic_vector(31 downto 0) := "0100000000001000----------------";
    constant SPYBUF09_BASEADDR: std_logic_vector(31 downto 0) := "0100000000001001----------------";
    constant SPYBUF10_BASEADDR: std_logic_vector(31 downto 0) := "0100000000001010----------------";
    constant SPYBUF11_BASEADDR: std_logic_vector(31 downto 0) := "0100000000001011----------------";
    constant SPYBUF12_BASEADDR: std_logic_vector(31 downto 0) := "0100000000001100----------------";
    constant SPYBUF13_BASEADDR: std_logic_vector(31 downto 0) := "0100000000001101----------------";
    constant SPYBUF14_BASEADDR: std_logic_vector(31 downto 0) := "0100000000001110----------------";
    constant SPYBUF15_BASEADDR: std_logic_vector(31 downto 0) := "0100000000001111----------------";
    constant SPYBUF16_BASEADDR: std_logic_vector(31 downto 0) := "0100000000010000----------------";
    constant SPYBUF17_BASEADDR: std_logic_vector(31 downto 0) := "0100000000010001----------------";
    constant SPYBUF18_BASEADDR: std_logic_vector(31 downto 0) := "0100000000010010----------------";
    constant SPYBUF19_BASEADDR: std_logic_vector(31 downto 0) := "0100000000010011----------------";
    constant SPYBUF20_BASEADDR: std_logic_vector(31 downto 0) := "0100000000010100----------------";
    constant SPYBUF21_BASEADDR: std_logic_vector(31 downto 0) := "0100000000010101----------------";
    constant SPYBUF22_BASEADDR: std_logic_vector(31 downto 0) := "0100000000010110----------------";
    constant SPYBUF23_BASEADDR: std_logic_vector(31 downto 0) := "0100000000010111----------------";
    constant SPYBUF24_BASEADDR: std_logic_vector(31 downto 0) := "0100000000011000----------------";
    constant SPYBUF25_BASEADDR: std_logic_vector(31 downto 0) := "0100000000011001----------------";
    constant SPYBUF26_BASEADDR: std_logic_vector(31 downto 0) := "0100000000011010----------------";
    constant SPYBUF27_BASEADDR: std_logic_vector(31 downto 0) := "0100000000011011----------------";
    constant SPYBUF28_BASEADDR: std_logic_vector(31 downto 0) := "0100000000011100----------------";
    constant SPYBUF29_BASEADDR: std_logic_vector(31 downto 0) := "0100000000011101----------------";
    constant SPYBUF30_BASEADDR: std_logic_vector(31 downto 0) := "0100000000011110----------------";
    constant SPYBUF31_BASEADDR: std_logic_vector(31 downto 0) := "0100000000011111----------------";
    constant SPYBUF32_BASEADDR: std_logic_vector(31 downto 0) := "0100000000100000----------------";
    constant SPYBUF33_BASEADDR: std_logic_vector(31 downto 0) := "0100000000100001----------------";
    constant SPYBUF34_BASEADDR: std_logic_vector(31 downto 0) := "0100000000100010----------------";
    constant SPYBUF35_BASEADDR: std_logic_vector(31 downto 0) := "0100000000100011----------------";
    constant SPYBUF36_BASEADDR: std_logic_vector(31 downto 0) := "0100000000100100----------------";
    constant SPYBUF37_BASEADDR: std_logic_vector(31 downto 0) := "0100000000100101----------------";
    constant SPYBUF38_BASEADDR: std_logic_vector(31 downto 0) := "0100000000100110----------------";
    constant SPYBUF39_BASEADDR: std_logic_vector(31 downto 0) := "0100000000100111----------------";
    constant SPYBUF40_BASEADDR: std_logic_vector(31 downto 0) := "0100000000101000----------------";
    constant SPYBUF41_BASEADDR: std_logic_vector(31 downto 0) := "0100000000101001----------------";
    constant SPYBUF42_BASEADDR: std_logic_vector(31 downto 0) := "0100000000101010----------------";
    constant SPYBUF43_BASEADDR: std_logic_vector(31 downto 0) := "0100000000101011----------------";
    constant SPYBUF44_BASEADDR: std_logic_vector(31 downto 0) := "0100000000101100----------------";

    -- spy buffer for the 64 bit timestamp value

    constant SPYBUFTS_BASEADDR: std_logic_vector(31 downto 0) := "0100000000101101----------------";

end package;

