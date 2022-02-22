-- fe.vhd
-- DAPHNE FPGA AFE front end. This module does the following:
-- send master clock 62.5MHz to AFEs
-- receive high speed LVDS serial data from the AFEs, 
-- deskew and convert to 14 bit parallel bus in the master clock domain
--
-- Each high speed LVDS input feeds into an IDELAY + ISERDES.
--
-- You will notice that the high speed clock from the AFE chip is not used here. The reason for this is that it is not required. This FPGA sends
-- a copy of the master clock 62.5MHz to each AFE. Therefore each AFE chip is frequency locked to the FPGA master clock. The phase relationship,
-- however, is not known, but that is calibrated out using the IDELAY primitives. Thus this module REQUIRES manual calibration on each channel 
-- (LVDS pair) Here's how:
--
-- 1. Place the AFE into fixed data pattern mode, let's assume it is "11 1111 1000 0000"
-- 2. Adjust the IDELAY value to find the center of the bit
--    2.1 observe the parallel word for the channel you are adjusting. it doesn't really matter what the 
--        value is. what you're looking for is when it begins to change. start with a delay value in the middle
--    2.2 decrement the delay value, watching the parallel word each time. when the value changes you're at the edge of the bit
--        note this value.
--    2.3 reset the delay value to the center, then increment the delay until the parallel words begins to change again
--        this is the other edge of the bit. note this value
--    2.4 choose a delay value in the middle of the 2 values you found. this is the center of the bit. write this into the IDELAY.
--        this concludes the fine timing adjustment for the channel.
-- 3. The parallel word should now be stable and unchanging, but likely it will be shifted by some number of bits, e.g.
--    it might look like this: "11 1111 0000 0001". Assert BITSLIP for one clock cycle, then observe the parallel word. Keep going 
--    until it looks like what you'd expect.
-- 4. Done!
--
-- The link alignment process is a MANUAL PROCESS that should be done EVERY time the FPGA is configured. At some point we may
-- get fancy and make this process fully automatic.
--
-- Jamieson Olsen <jamieson@fnal.gov>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.daphne_package.all;

entity fe is
port(

    -- AFE interface 5 x 9 = 45 LVDS pairs

    afe_p: in std_logic_vector(44 downto 0);
    afe_n: in std_logic_vector(44 downto 0);
    afe_clk_p:  out std_logic; -- copy of 62.5MHz master clock sent to AFEs
    afe_clk_n:  out std_logic;

    -- FPGA interface

    mclk:   in std_logic; -- master clock 62.5MHz
    fclk:   in std_logic; -- 7 x master clock = 437.5MHz
    fclkb:  in std_logic;
    sclk:   in std_logic; -- 200MHz system clock, constant, 
    reset:  in std_logic; -- async reset 

    -- consider these signals slow and async, asserted for "a couple" mclk cycles
    bitslip:  in  std_logic_vector(44 downto 0); -- bitslip strobe

    delay_clk: in std_logic; -- clock for writing iserdes delay value
    delay_ld:  in  std_logic_vector(44 downto 0); -- write delay value strobe
    delay_din: in  std_logic_vector(4 downto 0);  -- delay value to write range 0-31
    delay_dout: out array45x5_type; -- delay value readback values

    afe: out array45x14_type

  );
end fe;

architecture fe_arch of fe is

    component febit -- single bit alignment component
    port(
        din_p, din_n:  std_logic;
        mclk:     in std_logic;
        fclk:     in std_logic;
        fclkb:    in std_logic;
        reset:    in std_logic; -- async reset
        bitslip:  in std_logic;
        delay_clk: in std_logic;
        delay_ld:  in std_logic;
        delay_din: in std_logic_vector(4 downto 0);
        delay_dout: out std_logic_vector(4 downto 0);
        q:        out std_logic_vector(13 downto 0)
      );
    end component;

    signal clock_out_temp: std_logic;
    signal bitslip_tmp: std_logic_vector(44 downto 0);
    signal bitslip1_reg, bitslip0_reg: std_logic_vector(44 downto 0);

begin

    -- Output the master clock to the AFEs 

    ODDR_inst: ODDR 
    generic map( DDR_CLK_EDGE => "OPPOSITE_EDGE" )
    port map(
        Q => clock_out_temp, 
        C => mclk,
        CE => '1',
        D1 => '1',
        D2 => '0',
        R => '0',
        S => '0');

    OBUFDS_inst: OBUFDS
        generic map(IOSTANDARD=>"LVDS")
        port map(
            I => clock_out_temp,
            O => afe_clk_p,
            OB => afe_clk_n);

    -- this controller is required for calibrating IDELAY elements...

    IDELAYCTRL_inst: IDELAYCTRL
        port map(
            REFCLK => sclk,
            RST    => reset,
            RDY    => open);

    process(mclk)
    begin
        if rising_edge(mclk) then
            bitslip0_reg(44 downto 0) <= bitslip;
            bitslip1_reg(44 downto 0) <= bitslip0_reg;
        end if;
    end process;


    -- instantiate 45 x single bit FEBIT modules

    gen_febit: for i in 44 downto 0 generate

        bitslip_tmp(i) <= '1' when (bitslip0_reg(i)='1' and bitslip1_reg(i)='0') else '0';

        febit_inst: febit
        port map(
            din_p    => afe_p(i),
            din_n    => afe_n(i),
            mclk     => mclk,
            fclk     => fclk,
            fclkb    => fclkb,
            reset    => reset, -- async reset
            bitslip  => bitslip_tmp(i),

            delay_clk => delay_clk,
            delay_ld  => delay_ld(i),
            delay_din => delay_din,
            delay_dout => delay_dout(i),

            q         => afe(i) 
          );

    end generate;




end fe_arch;
