-- febit.vhd
-- DAPHNE FPGA AFE front end for one bit. This module does the following:
-- single LVDS receiver with IDELAY and ISERDES (master + slave cascaded)
-- LVDS input is DDR 14 bit, manual input delay and manual bitslip
--
-- Jamieson Olsen <jamieson@fnal.gov>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.daphne_package.all;

entity febit is
port(
    din_p, din_n:  std_logic;  -- LVDS data input from AFE chip
    mclk:       in std_logic;  -- master clock 62.5MHz
    fclk:       in std_logic;  -- 7 x clock = 437.5MHz, from internal PLL, not from IOB
    fclkb:      in std_logic;  -- inverted copy of fast 7 x clock
    reset:      in std_logic;  -- async reset
    bitslip:    in std_logic;  -- sync to mclk
    delay_clk:  in std_logic;                     -- clock for loading idelay value
    delay_ld:   in std_logic;                     -- sync delay load
    delay_dat:  in std_logic_vector(4 downto 0);  -- sync delay value (range 0 to 31)
    q:          out std_logic_vector(13 downto 0) -- aligned data
  );
end febit;

architecture febit_arch of febit is

    signal din_ibuf, din_delayed : std_logic;
    signal icascade1, icascade2 : std_logic;
    signal delay_reg : std_logic_vector(4 downto 0);

begin

    -- LVDS input buffer with internal termination

    IBUFDS_inst: IBUFDS
    generic map(
        DIFF_TERM    => TRUE,
        IBUF_LOW_PWR => FALSE,
        IOSTANDARD   => "LVDS"
    )
    port map(
        I  => din_p,
        IB => din_n,
        O  => din_ibuf
    );

    -- try this: register the delay value and then always try to load this register into idelay...

    delay_proc: process(delay_clk)
    begin
        if rising_edge(delay_clk) then
            if (delay_ld='1') then
                delay_reg <= delay_dat;
            end if;
        end if;
    end process delay_proc;

    -- adjustable input delay 2.5ns in 32 78ps steps

    IDELAYE2_inst: IDELAYE2
    generic map(
        CINVCTRL_SEL          => "FALSE",
        DELAY_SRC             => "IDATAIN",
        HIGH_PERFORMANCE_MODE => "TRUE",
        IDELAY_TYPE           => "VAR_LOAD",
        IDELAY_VALUE          => 0,
        PIPE_SEL              => "FALSE",
        REFCLK_FREQUENCY      => 200.0,   -- 200 MHz
        SIGNAL_PATTERN        => "DATA"
    )
    port map(
        CNTVALUEOUT => open,  -- delay readback not implemented yet
        DATAOUT     => din_delayed,
        C           => delay_clk,
        CE          => '0',
        CINVCTRL    => '0',
        CNTVALUEIN  => delay_reg,
        DATAIN      => '0', 
        IDATAIN     => din_ibuf,
        INC         => '0', 
        LD          => '1',  -- always load delay value from ext register
        LDPIPEEN    => '0',
        REGRST      => '0' -- no reset on this primitive
    );

    -- master/slave cascaded pair of ISERDES serial-to-parallel converters, inspired by selectio_wiz 

    iserdese2_master_inst: ISERDESE2
    generic map(
        DATA_RATE         => "DDR",
        DATA_WIDTH        => 14,
        INTERFACE_TYPE    => "NETWORKING",
        DYN_CLKDIV_INV_EN => "FALSE", 
        DYN_CLK_INV_EN    => "FALSE",
        NUM_CE            => 2,
        OFB_USED          => "FALSE",
        IOBDELAY          => "NONE", 
        SERDES_MODE       => "MASTER"
    )
    port map(
        Q1                => q(0),
        Q2                => q(1),
        Q3                => q(2),
        Q4                => q(3),
        Q5                => q(4),
        Q6                => q(5),
        Q7                => q(6),
        Q8                => q(7),
        SHIFTOUT1         => icascade1,        -- connection to slave
        SHIFTOUT2         => icascade2,
        BITSLIP           => bitslip,
        CE1               => '1',              -- clock always enabled
        CE2               => '1', 
        CLK               => fclk,           -- fast bit clock
        CLKB              => fclkb,          -- inverted fast clock
        CLKDIV            => mclk,            -- slow clock
        CLKDIVP           => '0',              -- not used tie low
        D                 => '0',              -- from iob, not used
        DDLY              => din_delayed,      -- from idelay use this one
        RST               => reset,            
        SHIFTIN1          => '0',
        SHIFTIN2          => '0',
        DYNCLKDIVSEL      => '0',
        DYNCLKSEL         => '0',
        OFB               => '0',
        OCLK              => '0',
        OCLKB             => '0',
        O                 => open
    );                      

    iserdese2_slave_inst: ISERDESE2
    generic map(
        DATA_RATE         => "DDR",
        DATA_WIDTH        => 14,
        INTERFACE_TYPE    => "NETWORKING",
        DYN_CLKDIV_INV_EN => "FALSE",
        DYN_CLK_INV_EN    => "FALSE",
        NUM_CE            => 2,
        OFB_USED          => "FALSE",
        IOBDELAY          => "NONE", 
        SERDES_MODE       => "SLAVE"
    )
   port map(
        Q1                => open,
        Q2                => open,
        Q3                => q(8),
        Q4                => q(9),
        Q5                => q(10),
        Q6                => q(11),
        Q7                => q(12),
        Q8                => q(13),
        SHIFTOUT1         => open,      -- not used on slave
        SHIFTOUT2         => open,
        SHIFTIN1          => icascade1, -- from master
        SHIFTIN2          => icascade2,
        BITSLIP           => bitslip,
        CE1               => '1',       -- always clock enable
        CE2               => '1',      
        CLK               => fclk,    -- fast bit clock
        CLKB              => fclkb,   -- inverted fast clock
        CLKDIV            => mclk, 
        CLKDIVP           => '0',       -- tie low
        D                 => '0',       -- not used on slave
        DDLY              => '0',       -- not used on slave
        RST               => reset,   
        DYNCLKDIVSEL      => '0',
        DYNCLKSEL         => '0',
        OFB               => '0',
        OCLK              => '0',
        OCLKB             => '0',
        O                 => open
    );

end febit_arch;
