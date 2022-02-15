-- sync.vhd
-- DAPHNE synchronization interface includes the bare timing endpoint design

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--library unisim;
--use unisim.vcomponents.all;
--
--library unimacro;
--use unimacro.vcomponents.all;

use work.daphne_package.all;

entity sync is
port(

    reset: in std_logic; -- async reset from uC

    -- local board clocks 

	mclk_p, mclk_n:  in  std_logic; -- main clock 62.5MHz LVDS
	sclk_p, sclk_n:  in  std_logic; -- system clock 100MHz LVDS

    -- optical timing link interface

    cdr_clk_p, cdr_clk_n: in std_logic; -- CDR link clock LVDS ~300MHz
    cdr_dat_p, cdr_dat_n: in std_logic; -- CDR link data LVDS
    cdr_los:     in std_logic; -- loss of signal, loss of lock from CDR chip
    cdr_lol:     in std_logic; -- loss of signal, loss of lock from CDR chip

    cdr_sfp_los: in std_logic; -- high = loss of signal from SFP module
    cdr_sfp_abs: in std_logic; -- low = SFP optical module is present
    cdr_sfp_tx_p, cdr_sfp_tx_n: out std_logic; -- data to send up the SFP link
    cdr_sfp_txdis: out std_logic; -- low = enable the CDR SFP transmitter

    -- FPGA interface

    sysclk: out std_logic;  -- 200MHz system clock bufg
    clock:  out std_logic;  -- master clock 62.5MHz bufg
    ts:     out std_logic_vector(63 downto 0)
  );
end sync;

architecture sync_arch of sync is

begin

    -- instantiate buffers, pll, etc. here...

        -- send mclk to MMCM to generate master clock 62.5MHz and 7x copy for fe

        -- send sysclk to MMCM to generate 200MHz internal system clock


    -- TO DO instantiate timing system bare endpoint top level here...

end sync_arch;
