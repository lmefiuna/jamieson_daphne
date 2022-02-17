-- top_level.vhd
-- for DAPHNE GbE AFE Readout
-- Target: XC7A200T-3FBG676C
-- Uses single GTX Transceiver connected to SFP optical module
-- Line rate is 1.25Gbps with refclk 125MHz

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library unimacro;
use unimacro.vcomponents.all;

use work.daphne_package.all;

entity top_level is
generic(version: std_logic_vector(27 downto 0) := X"1234567"); -- git commit number is passed in from tcl
port(

    reset_n:    in  std_logic; -- active LOW reset from the microcontroller
    sysclk_p:   in  std_logic; -- system clock LVDS 100MHz from local oscillator
	sysclk_n:   in  std_logic; -- (note internal 62.5MHz clock is generated from this 100MHz clock)

    -- AFE LVDS i/o

    AFE0_D0_P, AFE0_D0_N: in std_logic;
    AFE0_D1_P, AFE0_D1_N: in std_logic;
    AFE0_D2_P, AFE0_D2_N: in std_logic;
    AFE0_D3_P, AFE0_D3_N: in std_logic;
    AFE0_D4_P, AFE0_D4_N: in std_logic;
    AFE0_D5_P, AFE0_D5_N: in std_logic;
    AFE0_D6_P, AFE0_D6_N: in std_logic;
    AFE0_D7_P, AFE0_D7_N: in std_logic;
    AFE0_FR_P, AFE0_FR_N: in std_logic;

    AFE1_D0_P, AFE1_D0_N: in std_logic;
    AFE1_D1_P, AFE1_D1_N: in std_logic;
    AFE1_D2_P, AFE1_D2_N: in std_logic;
    AFE1_D3_P, AFE1_D3_N: in std_logic;
    AFE1_D4_P, AFE1_D4_N: in std_logic;
    AFE1_D5_P, AFE1_D5_N: in std_logic;
    AFE1_D6_P, AFE1_D6_N: in std_logic;
    AFE1_D7_P, AFE1_D7_N: in std_logic;
    AFE1_FR_P, AFE1_FR_N: in std_logic;

    AFE2_D0_P, AFE2_D0_N: in std_logic;
    AFE2_D1_P, AFE2_D1_N: in std_logic;
    AFE2_D2_P, AFE2_D2_N: in std_logic;
    AFE2_D3_P, AFE2_D3_N: in std_logic;
    AFE2_D4_P, AFE2_D4_N: in std_logic;
    AFE2_D5_P, AFE2_D5_N: in std_logic;
    AFE2_D6_P, AFE2_D6_N: in std_logic;
    AFE2_D7_P, AFE2_D7_N: in std_logic;
    AFE2_FR_P, AFE2_FR_N: in std_logic;

    AFE3_D0_P, AFE3_D0_N: in std_logic;
    AFE3_D1_P, AFE3_D1_N: in std_logic;
    AFE3_D2_P, AFE3_D2_N: in std_logic;
    AFE3_D3_P, AFE3_D3_N: in std_logic;
    AFE3_D4_P, AFE3_D4_N: in std_logic;
    AFE3_D5_P, AFE3_D5_N: in std_logic;
    AFE3_D6_P, AFE3_D6_N: in std_logic;
    AFE3_D7_P, AFE3_D7_N: in std_logic;
    AFE3_FR_P, AFE3_FR_N: in std_logic;

    AFE4_D0_P, AFE4_D0_N: in std_logic;
    AFE4_D1_P, AFE4_D1_N: in std_logic;
    AFE4_D2_P, AFE4_D2_N: in std_logic;
    AFE4_D3_P, AFE4_D3_N: in std_logic;
    AFE4_D4_P, AFE4_D4_N: in std_logic;
    AFE4_D5_P, AFE4_D5_N: in std_logic;
    AFE4_D6_P, AFE4_D6_N: in std_logic;
    AFE4_D7_P, AFE4_D7_N: in std_logic;
    AFE4_FR_P, AFE4_FR_N: in std_logic;

    afe_clk_p:  out std_logic; -- copy of 62.5MHz master clock sent to AFEs
    afe_clk_n:  out std_logic;

    -- Gigabit Ethernet i/o

    gtrefclk_p: in  std_logic; -- refclk LVDS 125MHz
	gtrefclk_n: in  std_logic; 
    sfp_rx_p:   in  std_logic; 
	sfp_rx_n:   in  std_logic; 
	sfp_los:    in  std_logic; -- high if SFP RX fiber is dark
	sfp_tx_dis: out std_logic; -- high to disable SFP transmitter
    sfp_tx_p:   out std_logic; 
	sfp_tx_n:   out std_logic;

    -- misc board i/o

    trig_ext:   in std_logic; -- from back panel SMA connector, trigger on rising edge
    led:        out std_logic_vector(7 downto 0) -- KC705 user LEDs active high

  );
end top_level;

architecture top_level_arch of top_level is

	-- declare components

	-- this version of the IP core (16.2) was generated for Artix 7 
	-- Vivado 2020.2
	-- extra debug ports are NOT needed on DAPHNE version since
	--  we don't need to invert the TXD and RXD pairs going to the SFP module

	component gig_ethernet_pcs_pma_0
      port(
		gtrefclk_p           : in std_logic;                     -- Very high quality clock for GT transceiver
		gtrefclk_n           : in std_logic;                    
		gtrefclk_out         : out std_logic;                  
		gtrefclk_bufg_out    : out std_logic;                           
      
		txp                  : out std_logic;                    -- Differential +ve of serial transmission from PMA to PMD.
		txn                  : out std_logic;                    -- Differential -ve of serial transmission from PMA to PMD.
		rxp                  : in std_logic;                     -- Differential +ve for serial reception from PMD to PMA.
		rxn                  : in std_logic;                     -- Differential -ve for serial reception from PMD to PMA.

		mmcm_locked_out      : out std_logic;                     -- Locked signal from MMCM
		userclk_out          : out std_logic;                  
		userclk2_out         : out std_logic;                 
		rxuserclk_out          : out std_logic;               
		rxuserclk2_out         : out std_logic;               
		independent_clock_bufg : in std_logic;                
		pma_reset_out         : out std_logic;                     -- transceiver PMA reset signal
		resetdone             :out std_logic;

		gmii_txd             : in std_logic_vector(7 downto 0);  -- Transmit data from client MAC.
		gmii_tx_en           : in std_logic;                     -- Transmit control signal from client MAC.
		gmii_tx_er           : in std_logic;                     -- Transmit control signal from client MAC.
		gmii_rxd             : out std_logic_vector(7 downto 0); -- Received Data to client MAC.
		gmii_rx_dv           : out std_logic;                    -- Received control signal to client MAC.
		gmii_rx_er           : out std_logic;                    -- Received control signal to client MAC.
		gmii_isolate         : out std_logic;                    -- Tristate control to electrically isolate GMII.
	
		configuration_vector : in std_logic_vector(4 downto 0);  -- Alternative to MDIO interface.
		an_interrupt         : out std_logic;                    -- Interrupt to processor to signal that Auto-Negotiation has completed
		an_adv_config_vector : in std_logic_vector(15 downto 0); -- Alternate interface to program REG4 (AN ADV)
		an_restart_config    : in std_logic;                     -- Alternate signal to modify AN restart bit in REG0

		status_vector        : out std_logic_vector(15 downto 0); -- Core status.
		reset                : in std_logic;                      -- Asynchronous reset for entire core.
		signal_detect        : in std_logic;                      -- Input from PMD to indicate presence of optical input.
		gt0_pll0outclk_out     : out std_logic;
		gt0_pll0outrefclk_out  : out std_logic;
		gt0_pll1outclk_out     : out std_logic;
		gt0_pll1outrefclk_out  : out std_logic;
		gt0_pll0refclklost_out : out std_logic;
		gt0_pll0lock_out       : out std_logic
    );
	end component;

    component ethernet_interface -- Ryan's OEI core logic
    port(
        reset_in:       in  std_logic;
        tx_data:        in  std_logic_vector(63 downto 0);
        ready:          in  std_logic;
        b_data:         in  std_logic_vector(63 downto 0);
        b_data_we:      in  std_logic;
        b_force_packet: in  std_logic;
        reset_out:      out std_logic;
        rx_addr:        out std_logic_vector(31 downto 0);
        rx_data:        out std_logic_vector(63 downto 0);
        rx_wren:        out std_logic;
        tx_rden:        out std_logic;
        b_enable:       out std_logic;
        user_addr:          in  std_logic_vector( 7 downto 0);
        internal_block_sel: in  std_logic_vector(31 downto 0);
        internal_addr:      in  std_logic_vector(31 downto 0);
        internal_din:       in  std_logic_vector(63 downto 0);
        internal_we:        in  std_logic;
        internal_dout:      out std_logic_vector(63 downto 0);
        phy_rxd:    in  std_logic_vector(7 downto 0);
        phy_rx_dv:  in  std_logic;
        phy_rx_er:  in  std_logic;
        master_clk: in  std_logic;
        phy_txd:    out std_logic_vector(7 downto 0);
        phy_tx_en:  out std_logic;
        phy_tx_er:  out std_logic;
        tx_clk:     out std_logic
    );
    end component;

    component fe
    port(
        afe_p: in std_logic_vector(44 downto 0);
        afe_n: in std_logic_vector(44 downto 0);
        afe_clk_p:  out std_logic; -- copy of 62.5MHz master clock sent to AFEs
        afe_clk_n:  out std_logic;
        mclk:   in std_logic; -- master clock 62.5MHz
        fclk:   in std_logic; -- 7 x master clock = 437.5MHz
        fclkb:  in std_logic;
        sclk:   in std_logic; -- 200MHz system clock, constant, 
        reset:  in std_logic;  
        delay_di: in  std_logic_vector(4 downto 0);
        delay_we: in  std_logic_vector(44 downto 0);
        bitslip:  in  std_logic_vector(44 downto 0);
        afe: out array45x14_type
      );
    end component;

    component spy
    port(
        clka:  in std_logic;  
        reset: in std_logic; -- reset sync to clka
        trig:  in std_logic; -- trigger pulse sync to clka
        dia:   in std_logic_vector(15 downto 0); -- data bus from AFE channel    
        clkb:  in  std_logic;
        addrb: in  std_logic_vector(11 downto 0);
        dob:   out std_logic_vector(15 downto 0)
      );
    end component;
	
	-- declare signals to connect everything up

    signal gtrefclk_bufg_out, oeiclk, ready: std_logic;
    signal gtrefclk_p_ibuf, gtrefclk_n_ibuf: std_logic;

    signal gmii_rxd, gmii_txd: std_logic_vector(7 downto 0);
    signal gmii_tx_en, gmii_tx_er: std_logic;
    signal gmii_rx_dv, gmii_rx_er: std_logic;
    signal status_vector: std_logic_vector(15 downto 0);

    signal tx_data, rx_data: std_logic_vector(63 downto 0);
    signal rx_addr, rx_addr_reg: std_logic_vector(31 downto 0);
    signal tx_rden, rx_wren: std_logic;

    signal test_reg: std_logic_vector(63 downto 0);
    signal testreg_we: std_logic;

    signal bram0_we: std_logic_vector(3 downto 0);
    signal bram0_do: std_logic_vector(35 downto 0);

    signal fifo_DO: std_logic_vector(63 downto 0);
    signal dummy_RDCOUNT, dummy_WRCOUNT: std_logic_vector(8 downto 0);
    signal fifo_RDEN, fifo_WREN: std_logic;

    signal count_reg: std_logic_vector(23 downto 0);
    signal edge_reg: std_logic;
    signal led_temp, led1_reg, led0_reg: std_logic_vector(7 downto 0);

    -- DAPHNE specific signals...

	signal reset_async, reset_sync: std_logic;
    signal trig_sync, trig_gbe: std_logic;

    signal afe_p, afe_n: std_logic_vector(44 downto 0);

    signal sysclk_ibuf, clkfbout, clkfbout_buf, clkout0, clkout1, clkout2, clkout2b, locked: std_logic;
    signal sclk, mclk, fclk, fclkb: std_logic;

    signal afe_bus: array45x14_type;
    signal afe16_bus: array45x16_type;
    signal bitslip: std_logic_vector(44 downto 0);
    signal bitslip_strobe: std_logic;
    signal delay_we: std_logic_vector(44 downto 0);
    signal spyout: array45x16_type;
    
    signal timestamp_reg, timestamp_spy_out: std_logic_vector(63 downto 0);

    signal rx_wren_reg: std_logic_vector(2 downto 0);
    signal bs_edge1_reg, bs_edge0_reg: std_logic;
    signal trig_gbe0_reg, trig_gbe1_reg, trig_gbe2_reg: std_logic;

begin

	reset_async <= not reset_n;

	-- sysclk is 100MHz LVDS, receive it with IBUFDS and drive it out on a BUFG net. sysclk comes in on bank 33
	-- which has VCCO=1.5V. IOSTANDARD is LVDS and the termination resistor is external (DIFF_TERM=FALSE)
    -- use MMCM/PLL to generate the following internal clocks:
    --
    --      200MHz used to calibrate the IDELAYs in the front end.
    --      62.5MHz master clock
    --      437.5MHz (7 x the master clock) used for ISERDES in the front end (also produce an inverted copy of this.)

	sysclk_ibufds_inst : IBUFGDS port map(O => sysclk_ibuf, I => sysclk_p, IB => sysclk_n);

    mmcm_inst: MMCME2_ADV
    generic map(
        BANDWIDTH            => "OPTIMIZED",
        CLKOUT4_CASCADE      => FALSE,
        COMPENSATION         => "ZHOLD",
        STARTUP_WAIT         => FALSE,
        DIVCLK_DIVIDE        => 1,
        CLKFBOUT_MULT_F      => 8.750,
        CLKFBOUT_PHASE       => 0.000,
        CLKFBOUT_USE_FINE_PS => FALSE,
        CLKOUT0_DIVIDE_F     => 4.375,
        CLKOUT0_PHASE        => 0.000,
        CLKOUT0_DUTY_CYCLE   => 0.500,
        CLKOUT0_USE_FINE_PS  => FALSE,
        CLKOUT1_DIVIDE       => 14,
        CLKOUT1_PHASE        => 0.000,
        CLKOUT1_DUTY_CYCLE   => 0.500,
        CLKOUT1_USE_FINE_PS  => FALSE,
        CLKOUT2_DIVIDE       => 2,
        CLKOUT2_PHASE        => 0.000,
        CLKOUT2_DUTY_CYCLE   => 0.500,
        CLKOUT2_USE_FINE_PS  => FALSE,
        CLKIN1_PERIOD        => 10.000
    )
    port map(
        CLKFBOUT            => clkfbout,
        CLKFBOUTB           => open,
        CLKOUT0             => clkout0,  -- 200MHz
        CLKOUT0B            => open,
        CLKOUT1             => clkout1,  -- 62.5MHz
        CLKOUT1B            => open,
        CLKOUT2             => clkout2,  -- 437.5MHz
        CLKOUT2B            => clkout2b, -- 437.5MHz inverted 
        CLKOUT3             => open,
        CLKOUT3B            => open,
        CLKOUT4             => open,
        CLKOUT5             => open,
        CLKOUT6             => open,
        CLKFBIN             => clkfbout_buf,
        CLKIN1              => sysclk_ibuf,
        CLKIN2              => '0',
        CLKINSEL            => '1',
        DADDR               => (others=>'0'),
        DCLK                => '0',
        DEN                 => '0',
        DI                  => (others=>'0'),
        DO                  => open,
        DRDY                => open,
        DWE                 => '0',
        PSCLK               => '0',
        PSEN                => '0',
        PSINCDEC            => '0',
        PSDONE              => open,
        LOCKED              => locked,
        CLKINSTOPPED        => open,
        CLKFBSTOPPED        => open,
        PWRDWN              => '0',
        RST                 => reset_async
    );

    clkfb_inst: BUFG port map( I => clkfbout, O => clkfbout_buf);

    clk0_inst:  BUFG port map( I => clkout0, O => sclk);   -- system clock 200MHz

    clk1_inst:  BUFG port map( I => clkout1, O => mclk);   -- master clock 62.5MHz

    clk2_inst:  BUFG port map( I => clkout2, O => fclk);   -- fast clock 437.5MHz

    clk2b_inst: BUFG port map( I => clkout2b, O => fclkb); -- fast clock 437.5MHz inverted
    
    -- square up some async inputs in the mclk domain
    -- also make a fake 64 bit timestamp counter

    misc_proc: process(mclk)
    begin
        if rising_edge(mclk) then
            reset_sync <= reset_async;
            if (reset_sync='1') then
                timestamp_reg <= (others=>'0');
            else
                timestamp_reg <= std_logic_vector(unsigned(timestamp_reg) + 1);
            end if;
        end if;
    end process misc_proc;

    -- the trigger pulse can come from the outside world (aysnc) or from a write to a special address (oeiclk domain). 
    -- square this up and edge detect this and move it into the MCLK domain

    trig_gbe <= '1' when (std_match(rx_addr,TRIGGER_ADDR) and rx_wren='1') else '0';

    trig_oei_proc: process(oeiclk)
    begin
        if rising_edge(oeiclk) then
            trig_gbe0_reg <= trig_gbe;
            trig_gbe1_reg <= trig_gbe0_reg;
            trig_gbe2_reg <= trig_gbe1_reg;
        end if;
    end process trig_oei_proc;

    trig_proc: process(mclk)
    begin
        if rising_edge(mclk) then
            trig_sync <= trig_ext or trig_gbe0_reg or trig_gbe1_reg or trig_gbe2_reg; 
        end if;
    end process trig_proc;

    -- Map the LVDS inputs into (44..0) arrays. this sets the order for the whole design, spy buffers, etc.

    afe_p(0) <= AFE0_D0_P;  afe_n(0) <= AFE0_D0_N;
    afe_p(1) <= AFE0_D1_P;  afe_n(1) <= AFE0_D1_N;
    afe_p(2) <= AFE0_D2_P;  afe_n(2) <= AFE0_D2_N;
    afe_p(3) <= AFE0_D3_P;  afe_n(3) <= AFE0_D3_N;
    afe_p(4) <= AFE0_D4_P;  afe_n(4) <= AFE0_D4_N;
    afe_p(5) <= AFE0_D5_P;  afe_n(5) <= AFE0_D5_N;
    afe_p(6) <= AFE0_D6_P;  afe_n(6) <= AFE0_D6_N;
    afe_p(7) <= AFE0_D7_P;  afe_n(7) <= AFE0_D7_N;
    afe_p(8) <= AFE0_FR_P;  afe_n(8) <= AFE0_FR_N;

    afe_p( 9) <= AFE1_D0_P;  afe_n( 9) <= AFE1_D0_N;
    afe_p(10) <= AFE1_D1_P;  afe_n(10) <= AFE1_D1_N;
    afe_p(11) <= AFE1_D2_P;  afe_n(11) <= AFE1_D2_N;
    afe_p(12) <= AFE1_D3_P;  afe_n(12) <= AFE1_D3_N;
    afe_p(13) <= AFE1_D4_P;  afe_n(13) <= AFE1_D4_N;
    afe_p(14) <= AFE1_D5_P;  afe_n(14) <= AFE1_D5_N;
    afe_p(15) <= AFE1_D6_P;  afe_n(15) <= AFE1_D6_N;
    afe_p(16) <= AFE1_D7_P;  afe_n(16) <= AFE1_D7_N;
    afe_p(17) <= AFE1_FR_P;  afe_n(17) <= AFE1_FR_N;

    afe_p(18) <= AFE2_D0_P;  afe_n(18) <= AFE2_D0_N;
    afe_p(19) <= AFE2_D1_P;  afe_n(19) <= AFE2_D1_N;
    afe_p(20) <= AFE2_D2_P;  afe_n(20) <= AFE2_D2_N;
    afe_p(21) <= AFE2_D3_P;  afe_n(21) <= AFE2_D3_N;
    afe_p(22) <= AFE2_D4_P;  afe_n(22) <= AFE2_D4_N;
    afe_p(23) <= AFE2_D5_P;  afe_n(23) <= AFE2_D5_N;
    afe_p(24) <= AFE2_D6_P;  afe_n(24) <= AFE2_D6_N;
    afe_p(25) <= AFE2_D7_P;  afe_n(25) <= AFE2_D7_N;
    afe_p(26) <= AFE2_FR_P;  afe_n(26) <= AFE2_FR_N;

    afe_p(27) <= AFE3_D0_P;  afe_n(27) <= AFE3_D0_N;
    afe_p(28) <= AFE3_D1_P;  afe_n(28) <= AFE3_D1_N;
    afe_p(29) <= AFE3_D2_P;  afe_n(29) <= AFE3_D2_N;
    afe_p(30) <= AFE3_D3_P;  afe_n(30) <= AFE3_D3_N;
    afe_p(31) <= AFE3_D4_P;  afe_n(31) <= AFE3_D4_N;
    afe_p(32) <= AFE3_D5_P;  afe_n(32) <= AFE3_D5_N;
    afe_p(33) <= AFE3_D6_P;  afe_n(33) <= AFE3_D6_N;
    afe_p(34) <= AFE3_D7_P;  afe_n(34) <= AFE3_D7_N;
    afe_p(35) <= AFE3_FR_P;  afe_n(35) <= AFE3_FR_N;

    afe_p(36) <= AFE4_D0_P;  afe_n(36) <= AFE4_D0_N;
    afe_p(37) <= AFE4_D1_P;  afe_n(37) <= AFE4_D1_N;
    afe_p(38) <= AFE4_D2_P;  afe_n(38) <= AFE4_D2_N;
    afe_p(39) <= AFE4_D3_P;  afe_n(39) <= AFE4_D3_N;
    afe_p(40) <= AFE4_D4_P;  afe_n(40) <= AFE4_D4_N;
    afe_p(41) <= AFE4_D5_P;  afe_n(41) <= AFE4_D5_N;
    afe_p(42) <= AFE4_D6_P;  afe_n(42) <= AFE4_D6_N;
    afe_p(43) <= AFE4_D7_P;  afe_n(43) <= AFE4_D7_N;
    afe_p(44) <= AFE4_FR_P;  afe_n(44) <= AFE4_FR_N;

    -- now instantiate the AFE front end, total 45 channels (40 AFE data channels + 5 frame marker channels)

    fe_inst: fe 
    port map(

        afe_p => afe_p,
        afe_n => afe_n,
        afe_clk_p => afe_clk_p,
        afe_clk_n => afe_clk_n,

        mclk  => mclk,
        fclk  => fclk,
        fclkb => fclkb,
        sclk  => sclk,
        reset => reset_async,

        delay_di => rx_data(4 downto 0),
        delay_we => delay_we(44 downto 0),
        bitslip  => bitslip(44 downto 0),

        afe      => afe_bus -- mclk domain, this bus is 45x14
    );

    -- pad out 45x14 array to 45x16 array (because spy buffers are 16 bits wide)

    afegen: for i in 44 downto 0 generate

        afe16_bus(i) <= "00" & afe_bus(i);

    end generate afegen;

    -- address decode delay_we
    -- this signal originates in oeiclk domain 
    -- writing this into the idelay module is essentially async

    dewe_gen: for i in 44 downto 0 generate

        delay_we(i) <= '1' when (rx_wren='1' and (rx_addr=std_logic_vector(unsigned(DELAY_BASEADDR) + i)) ) else '0';

    end generate dewe_gen;

    -- address decode bitslip
    -- this signal originates in the oeiclk domain (125MHz) but must be resync in the in MCLK domain (62.5MHz)
    -- it must be asserted for only ONE MCLK cycle. the oeiclk domain write enable (rx_wren) is fast, so pulse stretch
    -- it for a few cycles, then edge detect this signal in the MCLK domain and assert this for one MCLK cycle.

    we_proc: process(oeiclk)
    begin
        if rising_edge(oeiclk) then
            rx_wren_reg(0) <= rx_wren;
            rx_wren_reg(1) <= rx_wren_reg(0);
            rx_wren_reg(2) <= rx_wren_reg(1) or rx_wren_reg(0);
        end if;
    end process we_proc;

    bsedge_proc: process(mclk)
    begin
        if rising_edge(mclk) then
            bs_edge0_reg <= rx_wren_reg(2);
            bs_edge1_reg <= bs_edge0_reg;
            if (bs_edge0_reg='1' and bs_edge1_reg='0') then
                bitslip_strobe <= '1';
            else
                bitslip_strobe <= '0';
            end if;
        end if;
    end process bsedge_proc;

    bs_gen: for i in 44 downto 0 generate

        bitslip(i) <= '1' when ( bitslip_strobe='1' and (rx_addr=std_logic_vector(unsigned(BITSLIP_BASEADDR) + i)) ) else '0';

    end generate bs_gen;

    -- make 45 spy buffers for AFE data, these buffers are READ ONLY

    spygen: for i in 44 downto 0 generate
    
        spy_inst: spy
        port map(
            -- mclk domain
            clka  => mclk,
            reset => reset_sync,
            trig  => trig_sync,
            dia   => afe16_bus(i),

            -- oeiclk domain    
            clkb  => oeiclk,
            addrb => rx_addr_reg(11 downto 0),
            dob   => spyout(i)
          );

    end generate spygen;

    -- make 4 more spy buffers which are used to store the 64-bit timestamp value

    ts_spy_gen: for i in 3 downto 0 generate

        ts_spy_inst: spy
        port map(
            -- mclk domain
            clka  => mclk,
            reset => reset_sync,
            trig  => trig_sync,
            dia   => timestamp_reg( ((i*16)+15) downto (i*16) ),

            -- oeiclk domain    
            clkb  => oeiclk,
            addrb => rx_addr_reg(11 downto 0),
            dob   => timestamp_spy_out( ((i*16)+15) downto (i*16) )
          );

    end generate ts_spy_gen;

    -- must manually add IBUFs for refclk inputs
    -- see http://forums.xilinx.com/t5/Implementation/Vivado-IBUFDS-GTE2-driven-by-IBUF/td-p/383187

    gtrefclk_p_ibuf_inst: IBUF port map ( I => gtrefclk_p, O => gtrefclk_p_ibuf );
    gtrefclk_n_ibuf_inst: IBUF port map ( I => gtrefclk_n, O => gtrefclk_n_ibuf );
 
	phy_inst: gig_ethernet_pcs_pma_0 
	port map(
		gtrefclk_p    => gtrefclk_p_ibuf,
        gtrefclk_n    => gtrefclk_n_ibuf,
        gtrefclk_out  => open,
        gtrefclk_bufg_out => gtrefclk_bufg_out, -- constant 125MHz derived from REFCLK
        txp               => sfp_tx_p,
        txn               => sfp_tx_n,
        rxp               => sfp_rx_p,
        rxn               => sfp_rx_n,
        mmcm_locked_out        => open,
        userclk_out            => open, 
        userclk2_out           => oeiclk, -- 125MHz clock to drive OEI logic, does it run constantly?
        rxuserclk_out          => open,
        rxuserclk2_out         => open, 
        independent_clock_bufg => sclk,   -- 200MHz system clock always running
        pma_reset_out          => open,
        resetdone              => open,
        gmii_txd     => gmii_txd,
        gmii_tx_en   => gmii_tx_en,
        gmii_tx_er   => gmii_tx_er,
        gmii_rxd     => gmii_rxd,
        gmii_rx_dv   => gmii_rx_dv,
        gmii_rx_er   => gmii_rx_er,
        gmii_isolate => open,
        configuration_vector(4 downto 0) => "10000",  -- Autoneg=1, Isolate=0, PowerDown=0, Loopback=0, Unidir=0 
        an_interrupt          => open,
        an_adv_config_vector  => X"0020",  -- AN FD, see PG047 table 2-55
        an_restart_config     => '0',
        status_vector         => status_vector, -- PG047 table 2-41
        reset                 => reset_async,
        signal_detect         => '1',   -- no optics, signal is always present
		gt0_pll0outclk_out => open,
		gt0_pll0outrefclk_out => open,
		gt0_pll1outclk_out => open,
		gt0_pll1outrefclk_out => open,
		gt0_pll0refclklost_out => open,
		gt0_pll0lock_out => open
      );

	-- make sure SFP transmitter is enabled!

	sfp_tx_dis <= '0';

	-- 'off the shelf' Ethernet Interface (OEI)
    -- burst mode not used here

    eth_int_inst: ethernet_interface
    port map(
        reset_in       => reset_async, 
        tx_data        => tx_data,
        ready          => ready,
        b_data         => X"0000000000000000",  -- burst mode not used
        b_data_we      => '0',
        b_force_packet => '0',
        reset_out      => open,
        rx_addr        => rx_addr,
        rx_data        => rx_data,
        rx_wren        => rx_wren,
        tx_rden        => tx_rden,
        b_enable       => open,
        user_addr          => OEI_USR_ADDR,
        internal_block_sel => X"00000000",  -- internal access not used
        internal_addr      => X"00000000",
        internal_din       => X"0000000000000000",
        internal_we        => '0',
        -- internal_dout   => 
        phy_rxd    => gmii_rxd,
        phy_rx_dv  => gmii_rx_dv,
        phy_rx_er  => gmii_rx_er,
        master_clk => oeiclk,
        phy_txd    => gmii_txd,
        phy_tx_en  => gmii_tx_en,
        phy_tx_er  => gmii_tx_er,
        tx_clk     => open
    );

    -- delay the read address by one clock, this register will be used to drive the readback mux
    -- going to Ethernet interface
    
    readmux_proc: process(oeiclk)
    begin
        if rising_edge(oeiclk) then
            rx_addr_reg <= rx_addr;
        end if;
    end process readmux_proc;

    -- BIG mux to determine what 64 bit value gets sent back to the Ethernet Interface

    tx_data <= test_reg                        when std_match(rx_addr_reg, TESTREG_ADDR) else 
               fifo_DO                         when std_match(rx_addr_reg, FIFO_ADDR) else 
               (X"000000000000"&status_vector) when std_match(rx_addr_reg, STATVEC_ADDR) else
               (X"00000000deadbeef")           when std_match(rx_addr_reg, DEADBEEF_ADDR) else
               (X"0000000"&bram0_do)           when std_match(rx_addr_reg, BRAM0_ADDR) else
               (X"000000000"&version)          when std_match(rx_addr_reg, GITVER_ADDR) else  -- 28 bit GIT commit hash
               (X"000000000000" & spyout( 0))  when std_match(rx_addr_reg, SPYBUF00_BASEADDR) else
               (X"000000000000" & spyout( 1))  when std_match(rx_addr_reg, SPYBUF01_BASEADDR) else
               (X"000000000000" & spyout( 2))  when std_match(rx_addr_reg, SPYBUF02_BASEADDR) else
               (X"000000000000" & spyout( 3))  when std_match(rx_addr_reg, SPYBUF03_BASEADDR) else
               (X"000000000000" & spyout( 4))  when std_match(rx_addr_reg, SPYBUF04_BASEADDR) else
               (X"000000000000" & spyout( 5))  when std_match(rx_addr_reg, SPYBUF05_BASEADDR) else
               (X"000000000000" & spyout( 6))  when std_match(rx_addr_reg, SPYBUF06_BASEADDR) else
               (X"000000000000" & spyout( 7))  when std_match(rx_addr_reg, SPYBUF07_BASEADDR) else
               (X"000000000000" & spyout( 8))  when std_match(rx_addr_reg, SPYBUF08_BASEADDR) else
               (X"000000000000" & spyout( 9))  when std_match(rx_addr_reg, SPYBUF09_BASEADDR) else
               (X"000000000000" & spyout(10))  when std_match(rx_addr_reg, SPYBUF10_BASEADDR) else
               (X"000000000000" & spyout(11))  when std_match(rx_addr_reg, SPYBUF11_BASEADDR) else
               (X"000000000000" & spyout(12))  when std_match(rx_addr_reg, SPYBUF12_BASEADDR) else
               (X"000000000000" & spyout(13))  when std_match(rx_addr_reg, SPYBUF13_BASEADDR) else
               (X"000000000000" & spyout(14))  when std_match(rx_addr_reg, SPYBUF14_BASEADDR) else
               (X"000000000000" & spyout(15))  when std_match(rx_addr_reg, SPYBUF15_BASEADDR) else
               (X"000000000000" & spyout(16))  when std_match(rx_addr_reg, SPYBUF16_BASEADDR) else
               (X"000000000000" & spyout(17))  when std_match(rx_addr_reg, SPYBUF17_BASEADDR) else
               (X"000000000000" & spyout(18))  when std_match(rx_addr_reg, SPYBUF18_BASEADDR) else
               (X"000000000000" & spyout(19))  when std_match(rx_addr_reg, SPYBUF19_BASEADDR) else
               (X"000000000000" & spyout(20))  when std_match(rx_addr_reg, SPYBUF20_BASEADDR) else
               (X"000000000000" & spyout(21))  when std_match(rx_addr_reg, SPYBUF21_BASEADDR) else
               (X"000000000000" & spyout(22))  when std_match(rx_addr_reg, SPYBUF22_BASEADDR) else
               (X"000000000000" & spyout(23))  when std_match(rx_addr_reg, SPYBUF23_BASEADDR) else
               (X"000000000000" & spyout(24))  when std_match(rx_addr_reg, SPYBUF24_BASEADDR) else
               (X"000000000000" & spyout(25))  when std_match(rx_addr_reg, SPYBUF25_BASEADDR) else
               (X"000000000000" & spyout(26))  when std_match(rx_addr_reg, SPYBUF26_BASEADDR) else
               (X"000000000000" & spyout(27))  when std_match(rx_addr_reg, SPYBUF27_BASEADDR) else
               (X"000000000000" & spyout(28))  when std_match(rx_addr_reg, SPYBUF28_BASEADDR) else
               (X"000000000000" & spyout(29))  when std_match(rx_addr_reg, SPYBUF29_BASEADDR) else
               (X"000000000000" & spyout(30))  when std_match(rx_addr_reg, SPYBUF30_BASEADDR) else
               (X"000000000000" & spyout(31))  when std_match(rx_addr_reg, SPYBUF31_BASEADDR) else
               (X"000000000000" & spyout(32))  when std_match(rx_addr_reg, SPYBUF32_BASEADDR) else
               (X"000000000000" & spyout(33))  when std_match(rx_addr_reg, SPYBUF33_BASEADDR) else
               (X"000000000000" & spyout(34))  when std_match(rx_addr_reg, SPYBUF34_BASEADDR) else
               (X"000000000000" & spyout(35))  when std_match(rx_addr_reg, SPYBUF35_BASEADDR) else
               (X"000000000000" & spyout(36))  when std_match(rx_addr_reg, SPYBUF36_BASEADDR) else
               (X"000000000000" & spyout(37))  when std_match(rx_addr_reg, SPYBUF37_BASEADDR) else
               (X"000000000000" & spyout(38))  when std_match(rx_addr_reg, SPYBUF38_BASEADDR) else
               (X"000000000000" & spyout(39))  when std_match(rx_addr_reg, SPYBUF39_BASEADDR) else
               (X"000000000000" & spyout(40))  when std_match(rx_addr_reg, SPYBUF40_BASEADDR) else
               (X"000000000000" & spyout(41))  when std_match(rx_addr_reg, SPYBUF41_BASEADDR) else
               (X"000000000000" & spyout(42))  when std_match(rx_addr_reg, SPYBUF42_BASEADDR) else
               (X"000000000000" & spyout(43))  when std_match(rx_addr_reg, SPYBUF43_BASEADDR) else
               (X"000000000000" & spyout(44))  when std_match(rx_addr_reg, SPYBUF44_BASEADDR) else
               timestamp_spy_out(63 downto 0)  when std_match(rx_addr_reg, SPYBUFTS_BASEADDR) else
               (X"00000000" & rx_addr_reg);

    -- drive the READY signal back to OEI immediately, this means immediate writes and 
    -- read latency of 1. Specific to the OEI handshaking.

    ready <= rx_wren or tx_rden;

    -- 64-bit R/W dummy register for testing reads and writes
    -- located at address 0x12345678

    testreg_we <= '1' when (std_match(rx_addr,TESTREG_ADDR) and rx_wren='1') else '0';

    test_proc: process(oeiclk)
    begin
        if rising_edge(oeiclk) then
            if (reset_async='1') then
                test_reg <= (others=>'0');
            elsif (testreg_we='1') then
                test_reg <= rx_data;
            end if;
        end if;
    end process test_proc;

    -- test: connect a single port 1k x 36 blockRAM to the OTS
    -- this memory block maps into 0x00070000 - 0x000703FF
 
    bram0_we <= "1111" when (std_match(rx_addr,BRAM0_ADDR) and rx_wren='1') else "0000";

    BRAM0_inst : BRAM_SINGLE_MACRO -- 1k x 36, 10 bit addr
    generic map(
        BRAM_SIZE => "36Kb",
        DEVICE => "7SERIES",
        DO_REG => 0,  -- no output register, read latency of 1 clk
        INIT => X"000000000",
        INIT_FILE => "NONE",
        WRITE_WIDTH => 36,
        READ_WIDTH => 36,
        SRVAL => X"000000000",
        WRITE_MODE => "READ_FIRST"
    )   
    port map(
        DO    => bram0_do(35 downto 0),
        ADDR  => rx_addr(9 downto 0),
        CLK   => oeiclk,
        DI    => rx_data(35 downto 0),
        EN    => '1',
        REGCE => '1',
        RST   => '0',
        WE    => bram0_we
    );

    -- test FIFO is 512 x 64. what happens if we try to read from an empty FIFO?

    fifo_WREN <= '1' when (std_match(rx_addr,FIFO_ADDR) and rx_wren='1') else '0'; 
    fifo_RDEN <= '1' when (std_match(rx_addr,FIFO_ADDR) and tx_rden='1') else '0'; 
    
    FIFO_SYNC_inst: FIFO_SYNC_MACRO
    generic map (
        DEVICE => "7SERIES",
        ALMOST_FULL_OFFSET => X"0080",
        ALMOST_EMPTY_OFFSET => X"0080",
        DATA_WIDTH => 64,
        FIFO_SIZE => "36Kb")
    port map (
        ALMOSTEMPTY => open,
        ALMOSTFULL => open,
        DO => fifo_DO,
        EMPTY => open,
        FULL => open,
        RDCOUNT => dummy_RDCOUNT,
        RDERR => open,
        WRCOUNT => dummy_WRCOUNT,
        WRERR => open,
        CLK => oeiclk,
        DI => rx_data,
        RDEN => fifo_RDEN,
        RST => reset_async,
        WREN => fifo_WREN
    );

	-- DAPHNE has 6 user LEDs, assign LED7 and LED6 to debug header.
	-- NOTE these LEDS are ACTIVE LOW on DAPHNE
	-- define what these mean here:

	led_temp(0) <= not sfp_los;          -- SFP optical Loss of Signal
    led_temp(1) <= not status_vector(0); -- set if link is UP 
	led_temp(2) <= '0' when (status_vector(11 downto 10)="10") else '1'; -- set link speed is 1000
	led_temp(3) <= not gmii_rx_dv; -- ethernet RX activity
	led_temp(4) <= not gmii_tx_en; -- ethernet TX activity
	led_temp(5) <= not testreg_we; -- write to test register
	led_temp(6) <= '0' when (bram0_we="1111") else '1';   -- write to BlockRAM
	led_temp(7) <= not locked; -- main PLL/MMCM locked

	-- LED driver logic. pulse stretch fast signals so they are visible (aka a "one shot")
	-- Use a fast clock to sample the signal led_temp. whenever led_temp is HIGH, led0_reg
	-- goes high and stays high. periodically (200MHz / 2^24 = 11Hz) copy led0_reg into led1_reg 
	-- and reset led0_reg. this insures that the output signal led1_reg is HIGH for a whole
	-- 11Hz cycle, regardless of when the blip on the led_temp occurs.

    oneshot_proc: process(sclk)
    begin
        if rising_edge(sclk) then
            if (reset_async='1') then
                count_reg <= (others=>'0');
                edge_reg  <= '0';
                led0_reg <= X"00";
				led1_reg <= X"00";
            else
                count_reg <= std_logic_vector(unsigned(count_reg) + 1);
                edge_reg  <= count_reg(23);

                if (edge_reg='0' and count_reg(23)='1') then -- MSB of the counter was JUST set
                    led1_reg <= led0_reg;
                    led0_reg <= X"00";
                else
                    led0_reg <= led0_reg or led_temp;
                end if;
            end if;
        end if;
    end process oneshot_proc;
   
    led <= led1_reg;

end top_level_arch;
