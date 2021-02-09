-- top_level.vhd
-- OEI test code for Xilinx KC705 Development Board
-- Target: XC7K325T-2FFG900C
-- Uses single GTX Transceiver connected to SFP optical module
-- Line rate is 1.25Gbps with refclk 125MHz
-- GTX transceiver is in bank 117, transceiver 2: MGTXRXP2_117_G4, MGTXRXN2_117_G3, MGTXTXP2_117_H2, MGTXTXN2_117_H1
-- 125MHz refclk is LVDS: MGTREFCLK0P_117_G8 / SGMIICLK_Q0_P, MGTREFCLK0N_117_G7 / SGMIICLK_Q0_N

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library unimacro;
use unimacro.vcomponents.all;

use work.kc705_package.all;

entity top_level is
port(
    reset:      in  std_logic; -- active high reset from board pushbutton called "cpu_reset" on schematics
    sysclk_p:   in  std_logic; -- system clock LVDS 200MHz 
	sysclk_n:   in  std_logic; -- 
    gtrefclk_p: in  std_logic; -- refclk LVDS 125MHz
	gtrefclk_n: in  std_logic; 
    sfp_rx_p:   in  std_logic; 
	sfp_rx_n:   in  std_logic; 
	sfp_los:    in  std_logic; -- high if SFP RX fiber is dark
	sfp_tx_dis: out std_logic; -- high to disable SFP transmitter
    sfp_tx_p:   out std_logic; 
	sfp_tx_n:   out std_logic; 
    led:        out std_logic_vector(7 downto 0) -- KC705 user LEDs active high
  );
end top_level;

architecture top_level_arch of top_level is

	-- declare components

	-- Xilinx IP core includes the GTX transceiver, updated for Vivado 2018.1, extra debug ports enabled
	-- so that the TX and RX polarity can be flipped.

    component gig_ethernet_pcs_pma_0 
      port (

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

      gt0_txpmareset_in         : in  std_logic;
      gt0_txpcsreset_in         : in  std_logic;
      gt0_rxpmareset_in         : in  std_logic;
      gt0_rxpcsreset_in         : in  std_logic;
      gt0_rxbufreset_in         : in  std_logic;
      gt0_rxbufstatus_out       : out std_logic_vector(2 downto 0);
      gt0_txbufstatus_out       : out std_logic_vector(1 downto 0);
      gt0_dmonitorout_out       : out std_logic_vector(7 downto 0);
      
      gt0_drpaddr_in            : in   std_logic_vector(8 downto 0);
      gt0_drpclk_in             : in   std_logic;
      gt0_drpdi_in              : in   std_logic_vector(15 downto 0);
      gt0_drpdo_out             : out  std_logic_vector(15 downto 0);
      gt0_drpen_in              : in   std_logic;
      gt0_drprdy_out            : out  std_logic;
      gt0_drpwe_in              : in   std_logic;
      gt0_rxchariscomma_out     : out std_logic_vector(1 downto 0);
      gt0_rxcharisk_out         : out std_logic_vector(1 downto 0);
      gt0_rxbyteisaligned_out   : out std_logic;
      gt0_rxbyterealign_out     : out std_logic;
      gt0_rxcommadet_out        : out std_logic;
      gt0_txpolarity_in         : in  std_logic;
      gt0_txinhibit_in          : in  std_logic;
      gt0_txdiffctrl_in         : in  std_logic_vector(3 downto 0);
      gt0_txpostcursor_in       : in  std_logic_vector(4 downto 0);
      gt0_txprecursor_in        : in  std_logic_vector(4 downto 0);
      gt0_rxpolarity_in         : in  std_logic;
      gt0_rxdfelpmreset_in      : in  std_logic;
      gt0_rxdfeagcovrden_in     : in  std_logic;
      gt0_rxlpmen_in            : in  std_logic;
      gt0_txprbssel_in          : in  std_logic_vector(2 downto 0);
      gt0_txprbsforceerr_in     : in  std_logic;
      gt0_rxprbscntreset_in     : in  std_logic;
      gt0_rxprbserr_out         : out std_logic;
      gt0_rxprbssel_in          : in  std_logic_vector(2 downto 0);
      gt0_loopback_in           : in  std_logic_vector(2 downto 0);
      gt0_txresetdone_out       : out std_logic;
      gt0_rxresetdone_out       : out std_logic;
      gt0_rxdisperr_out         : out std_logic_vector(1 downto 0);
      gt0_rxnotintable_out      : out std_logic_vector(1 downto 0);
      gt0_eyescanreset_in       : in  std_logic;
      gt0_eyescandataerror_out  : out std_logic;
      gt0_eyescantrigger_in     : in  std_logic;
      gt0_rxcdrhold_in          : in  std_logic;
      gt0_rxmonitorout_out      : out std_logic_vector(6 downto 0);
      gt0_rxmonitorsel_in       : in  std_logic_vector(1 downto 0);

      status_vector        : out std_logic_vector(15 downto 0); -- Core status.
      reset                : in std_logic;                     -- Asynchronous reset for entire core.
      signal_detect        : in std_logic;                      -- Input from PMD to indicate presence of optical input.
      gt0_qplloutclk_out     : out std_logic;
      gt0_qplloutrefclk_out  : out std_logic
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
	
	-- declare signals to connect everything up

    signal gtrefclk_bufg_out, oeiclk, sysclk_ibuf, sysclk, ready: std_logic;
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

begin

	-- 200MHz sysclk is LVDS, receive it with IBUFDS and drive it out on a BUFG net. sysclk comes in on bank 33
	-- which has VCCO=1.5V. IOSTANDARD is LVDS and the termination resistor is external (DIFF_TERM=FALSE)

	sysclk_ibufds_inst : IBUFDS
	port map(O => sysclk_ibuf, I => sysclk_p, IB => sysclk_n);

	sysclk_bufg_inst : BUFG
	port map(O => sysclk, I => sysclk_ibuf);

    -- must manually add IBUFs for refclk inputs
    -- see http://forums.xilinx.com/t5/Implementation/Vivado-IBUFDS-GTE2-driven-by-IBUF/td-p/383187

    gtrefclk_p_ibuf_inst: IBUF port map ( I => gtrefclk_p, O => gtrefclk_p_ibuf );
    gtrefclk_n_ibuf_inst: IBUF port map ( I => gtrefclk_n, O => gtrefclk_n_ibuf );

    -- MGT transceiver with Xilinx 1G Ethernet PCS/PMA IP core, configured as:
    -- Data Rate = 1G
    -- Standard: 1000BASE-X
    -- Core Functionality: Auto Negotiation, No MDIO
    -- Shared Logic: Include Shared Logic in Core

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
        independent_clock_bufg => sysclk, -- 200MHz system clock always running
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
        reset                 => reset,
        signal_detect         => '1',   -- no optics, signal is always present
        gt0_qplloutclk_out    => open,  -- QPLL not used?
        gt0_qplloutrefclk_out => open,
		
		-- KC705 PCB rev1.0 has the SFP RX and TX polarity inverted. In order to get
		-- control of the polarity we have to enable a whole bunch of debug ports, which are 
		-- listed here. These inputs are using the default values from the IP core example design.

      gt0_txpmareset_in         => '0',
      gt0_txpcsreset_in         => '0',
      gt0_rxpmareset_in         => '0',
      gt0_rxpcsreset_in         => '0',
      gt0_rxbufreset_in         => '0',
      gt0_rxbufstatus_out       => open,
      gt0_txbufstatus_out       => open,
      gt0_dmonitorout_out       => open,
      gt0_drpaddr_in            => (others=>'0'),
      gt0_drpclk_in             => gtrefclk_bufg_out,
      gt0_drpdi_in              => (others=>'0'),
      gt0_drpdo_out             => open,
      gt0_drpen_in              => '0',
      gt0_drprdy_out            => open,
      gt0_drpwe_in              => '0',
      gt0_rxchariscomma_out     => open,
      gt0_rxcharisk_out         => open,
      gt0_rxbyteisaligned_out   => open,
      gt0_rxbyterealign_out     => open,
      gt0_rxcommadet_out        => open,
      gt0_txpolarity_in         => '1', -- FLIP IT!!!
      gt0_txinhibit_in          => '0',
      gt0_txdiffctrl_in         => "1000",
      
      gt0_txpostcursor_in       => (others=>'0'),
      gt0_txprecursor_in        => (others=>'0'),
      gt0_rxpolarity_in         => '1', -- FLIP IT!!!
      gt0_rxdfelpmreset_in      => '0',
      gt0_rxdfeagcovrden_in     => '0',
      gt0_rxlpmen_in            => '1',
      gt0_txprbssel_in          => (others=>'0'),
      gt0_txprbsforceerr_in     => '0',
      gt0_rxprbscntreset_in     => '0',
      gt0_rxprbserr_out         => open,
      gt0_rxprbssel_in          => (others=>'0'),
      gt0_loopback_in           => (others=>'0'),
      gt0_txresetdone_out       => open,
      gt0_rxresetdone_out       => open,
      gt0_rxdisperr_out         => open,
      gt0_rxnotintable_out      => open,
      gt0_eyescanreset_in       => '0',
      gt0_eyescandataerror_out  => open,
      gt0_eyescantrigger_in     => '0',
      gt0_rxcdrhold_in          => '0',
      gt0_rxmonitorout_out      => open,
      gt0_rxmonitorsel_in       => (others=>'0')

    );
 
	-- make sure SFP transmitter is enabled!

	sfp_tx_dis <= '0';

	-- 'off the shelf' Ethernet Interface (OEI)
    -- burst mode not used here

    eth_int_inst: ethernet_interface
    port map(
        reset_in       => reset, 
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

    -- big mux to determine what 64 bit value gets sent back to the Ethernet Interface

    tx_data <= test_reg                        when std_match(rx_addr_reg, TESTREG_ADDR) else 
               fifo_DO                         when std_match(rx_addr_reg, FIFO_ADDR) else 
               (X"000000000000"&status_vector) when std_match(rx_addr_reg, STATVEC_ADDR) else
               (X"00000000deadbeef")           when std_match(rx_addr_reg, DEADBEEF_ADDR) else
               (X"0000000"&bram0_do)           when std_match(rx_addr_reg, BRAM0_ADDR) else
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
            if (reset='1') then
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
        RST => reset,
        WREN => fifo_WREN
    );

	-- KC705 has 8 user LEDs: (7)(6)(5)(4)(3)(2)(1)(0) 
	-- define what these mean here:

	led_temp(0) <= sfp_los;          -- SFP optical Loss of Signal
    led_temp(1) <= status_vector(0); -- set if link is UP 
	led_temp(2) <= '1' when (status_vector(11 downto 10)="10") else '0'; -- set link speed is 1000
	led_temp(3) <= gmii_rx_dv; -- ethernet RX activity
	led_temp(4) <= gmii_tx_en; -- ethernet TX activity
	led_temp(5) <= testreg_we; -- write to test register
	led_temp(6) <= '1' when (bram0_we="1111") else '0';   -- write to BlockRAM
	led_temp(7) <= fifo_WREN or fifo_RDEN; -- accessing FIFO

	-- LED driver logic. pulse stretch fast signals so they are visible (aka a "one shot")
	-- Use a fast clock to sample the signal led_temp. whenever led_temp is HIGH, led0_reg
	-- goes high and stays high. periodically (200MHz / 2^24 = 11Hz) copy led0_reg into led1_reg 
	-- and reset led0_reg. this insures that the output signal led1_reg is HIGH for a whole
	-- 11Hz cycle, regardless of when the blip on the led_temp occurs.

    oneshot_proc: process(sysclk)
    begin
        if rising_edge(sysclk) then
            if (reset='1') then
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
