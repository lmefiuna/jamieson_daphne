# OEI Gigabit Ethernet for DAPHNE

## Introduction

The OEI interface is straightforward way for a PC to talk to an FPGA over a Gigabit Ethernet link. This design was developed at Fermilab by Ryan Rivera and Lorenzo Uplegger. The network interface uses special UDP packets which are easy to create in any programming language like Python or C. Commands contained in these packets support reading and writing parallel data from addresses. Inside the FPGA the OEI firmware block presents a synchronous parallel address data bus which can be used to read and write registers, buffers, FIFOs, etc. in the user design.

Originally this design used a 1000BASE-T Ethernet PHY chip located outside the FPGA, with the remaining logic (including MAC layer) in the FPGA. The demo presented here pulls the Ethernet PHY logic into the FPGA using an MGT transceiver running at 1.25Gbps. An SFP transceiver (copper or fiber) is then used for the physical connection to the network.

## IP Cores

This design uses the "Gigabit Ethernet PCS PMA" IP core from Xilinx. It is included in every Vivado build and is free to use. The build script pulls this core automatically from the included XCIX file.

## Hardware

This demo design targets the XC7A200T-2FBG676C FPGA used on the DAPHNE board. Plug an SFP or SFP+ module into the "SFP1" cage for DAQ1 and connect the other end to a GbE port in a switch or PC.

In the FPGA there are some various registers and memories that are connected to the internal address data bus. Specifically there is a BlockRAM, a couple of static readonly registers, a read-write test register, and a FIFO. The address mapping for these things is defined in the VHDL package file.

### Required Clocks

This design requires a 125MHz MGT refclk and a 100MHz system clock (FPGA_MCLK). The microcontroller on the DAPHNE must configure the clock generator to produce these frequencies. The 62.5MHz "main" clock is not used in this design as it is internally generated using an MMCM.

## DAPHNE specific logic

### Timestamp Counter

A free running 64 bit counter is used as the timestamp. This timestamp can be read from a dedicated spy buffer.

### AFE Front End

This design includes the AFE front end logic, in which the user MANUALLY deskews and aligns the high speed AFE data outputs (IDELAY) and convert the serial data stream to parallel (ISERDES). There are 45 channels, 9 per AFE chip (8 data channels and one "FCLK" or frame channel). See procedure below.

### Spy Buffers

There are 45 spy buffers for the AFEs. Each spy buffer is 14 bits wide by 4k deep. An additional 64-bit wide spy buffer is used to store the timestamp value.

### Trigger

All spy buffers are triggered from a common signal, a rising edge on the external SMA input on the rear panel, OR by writing to a specific register from the Ethernet side. Once triggered, the spy buffers capture data, then stop and rearm waiting for the next trigger.

### DAPHNE LEDs

DAPHNE has 6 LEDs controlled by the FPGA, which are labeled on the PCB like this:
```
    led(5)   led(4)     led(3)     led(2)    led(1)    led(0)
    "LED14"   "LED13"    "LED4"     "LED3"    "LED2"    "LED1"    "LED5 (uC)"     
```
Note that the rightmost LED "LED5" is controlled by the uC. Refer to the top_level.vhd file for the meaning of these 6 FPGA LEDs.

## Software

Some example routines are included, they are written in Python and included in the src directory. The default Ethernet MAC address (00:80:55:EC:00:0C) and IP address (192.168.133.12) are defined in the VHDL package file. These python programs will read from and write to the various test registers and memories mentioned above.

### Internal Memory Map

The memory map is defined in daphne_package.vhd and the address space is 32 bit. Data width is 64 bits.
```
0x70000 - 0x703FF  Test BlockRam 1kx36, R/W, 36 bit
0xAA55             Test register R/O always returns 0xDEADBEEF, R/O, 32 bit
0x1974             Status vector for the PCS/PMA IP Core, R/O, 16 bit
0x9000             Read the git commit hash ID, 28 bits, R/O
0x12345678         Test register, R/W, 64 bit
0x80000000         Test FIFO, 512 x 64, R/W, 64-bit

0x00002000               Write anything to trigger spy buffers
0x00002001               Write anything to reset the AFE front end logic, need to do this first, before calibration.

Write anything these registers to BITSLIP the corresponding AFE chip:

0x00003000 bitslip AFE0
0x00003001 bitslip AFE1
0x00003002 bitslip AFE2
0x00003003 bitslip AFE3
0x00003004 bitslip AFE4

Write fine delay tap value (range 0-31) the correspoding AFE chip:

0x00004000 idelay value AFE0
0x00004001 idelay value AFE1
0x00004002 idelay value AFE2
0x00004003 idelay value AFE3
0x00004004 idelay value AFE4

AFE Spy Buffers are 14 bits wide and are read-only:

0x40000000 - 0x400003FF Spy Buffer AFE0 data0 
0x40010000 - 0x400103FF Spy Buffer AFE0 data1
0x40020000 - 0x400203FF Spy Buffer AFE0 data2
0x40030000 - 0x400303FF Spy Buffer AFE0 data3
0x40040000 - 0x400403FF Spy Buffer AFE0 data4
0x40050000 - 0x400503FF Spy Buffer AFE0 data5
0x40060000 - 0x400603FF Spy Buffer AFE0 data6
0x40070000 - 0x400703FF Spy Buffer AFE0 data7
0x40080000 - 0x400803FF Spy Buffer AFE0 frame

0x40100000 - 0x401003FF Spy Buffer AFE1 data0
0x40110000 - 0x401103FF Spy Buffer AFE1 data1
0x40120000 - 0x401203FF Spy Buffer AFE1 data2
0x40130000 - 0x401303FF Spy Buffer AFE1 data3
0x40140000 - 0x401403FF Spy Buffer AFE1 data4
0x40150000 - 0x401503FF Spy Buffer AFE1 data5
0x40160000 - 0x401603FF Spy Buffer AFE1 data6
0x40170000 - 0x401703FF Spy Buffer AFE1 data7
0x40180000 - 0x401803FF Spy Buffer AFE1 frame

0x40200000 - 0x402003FF Spy Buffer AFE2 data0
0x40210000 - 0x402103FF Spy Buffer AFE2 data1
0x40220000 - 0x402203FF Spy Buffer AFE2 data2
0x40230000 - 0x402303FF Spy Buffer AFE2 data3
0x40240000 - 0x402403FF Spy Buffer AFE2 data4
0x40250000 - 0x402503FF Spy Buffer AFE2 data5
0x40260000 - 0x402603FF Spy Buffer AFE2 data6
0x40270000 - 0x402703FF Spy Buffer AFE2 data7
0x40280000 - 0x402803FF Spy Buffer AFE2 frame

0x40300000 - 0x403003FF Spy Buffer AFE3 data0
0x40310000 - 0x403103FF Spy Buffer AFE3 data1
0x40320000 - 0x403203FF Spy Buffer AFE3 data2
0x40330000 - 0x403303FF Spy Buffer AFE3 data3
0x40340000 - 0x403403FF Spy Buffer AFE3 data4
0x40350000 - 0x403503FF Spy Buffer AFE3 data5
0x40360000 - 0x403603FF Spy Buffer AFE3 data6
0x40370000 - 0x403703FF Spy Buffer AFE3 data7
0x40380000 - 0x403803FF Spy Buffer AFE3 frame

0x40400000 - 0x404003FF Spy Buffer AFE4 data0
0x40410000 - 0x404103FF Spy Buffer AFE4 data1
0x40420000 - 0x404203FF Spy Buffer AFE4 data2
0x40430000 - 0x404303FF Spy Buffer AFE4 data3
0x40440000 - 0x404403FF Spy Buffer AFE4 data4
0x40450000 - 0x404503FF Spy Buffer AFE4 data5
0x40460000 - 0x404603FF Spy Buffer AFE4 data6
0x40470000 - 0x404703FF Spy Buffer AFE4 data7
0x40480000 - 0x404803FF Spy Buffer AFE4 frame

The Timestamp counter is also stored in a Spy buffer
this is 64 bits wide and is read only.

0x40500000 - 0x405003FF Spy Buffer for Timestamp
```
### Manual Alignment Procedure

0. Write to reset AFE front end logic
1. Put AFEs into fixed test pattern output mode
2. Force trigger
3. Readout Spy buffer for channel x
4. Write fine delay value for channel x
5. Repeat steps 2-5 for all delay values 0-31
6. Note when data pattern "jumps" -- that is the edge of the bit window
7. choose center value, write that to delay register for channel x (now you are sampling in center of the eye!)
8. trigger, readout, and bitslip as needed until received data pattern is correct on channel x
9. put AFEs back into normal data mode

Note that the frame markers should always read "11111110000000"  (0x3F80)

## Build Instructions

This demo is to be built from the command like in Vivado Non-Project mode:

  vivado -mode tcl -source vivado_batch.tcl

Build it and program the FPGA on the DAPHNE board with the bit file. Then connect it to the network and try pinging the IP address. It should respond. Then you can try reading and writing using the special OEI UDP packets (see the example code in Python). There are some registers and buffer memories in this demo design to try out.

JTO
