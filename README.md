# Off the Shelf Ethernet Interface (OEI) Demo for DAPHNE

## Introduction

The OEI interface is straightforward way for a PC to talk to an FPGA over a Gigabit Ethernet link. This design was developed at Fermilab by Ryan Rivera and Lorenzo Uplegger. The network interface uses special UDP packets which are easy to create in any programming language like Python or C. Commands contained in these packets support reading and writing parallel data from addresses. Inside the FPGA the OEI firmware block presents a synchronous parallel address data bus which can be used to read and write registers, buffers, FIFOs, etc. in the user design.

Originally this design used a 1000BASE-T Ethernet PHY chip located outside the FPGA, with the remaining logic (including MAC layer) in the FPGA. The demo presented here pulls the Ethernet PHY logic into the FPGA using an MGT transceiver running at 1.25Gbps. An SFP transceiver (copper or fiber) is then used for the physical connection to the network.

## IP Cores

This design uses the "Gigabit Ethernet PCS PMA" IP core from Xilinx. It is included in every Vivado build and is free to use. The build script pulls this core automatically from the XCIX file.

## Hardware

This demo design targets the XC7A200T-3FBG676C FPGA used on the DAPHNE board. Plug an SFP or SFP+ module into the SFP cage for DAQ1 and connect the other end to a GbE port in a switch or PC.

In the FPGA there are some various registers and memories that are connected to the internal address data bus. Specifically there is a BlockRAM, a couple of static readonly registers, a read-write test register, and a FIFO. The address mapping for these things is defined in the VHDL package file.

Note the XCIX IP core package needed to be regenerated because the Artix family uses different MGTs.

### Clocks

This design requires a 125MHz MGT refclk and a 100MHz system clock (FPGA_MCLK). The microcontroller on the DAPHNE must configure the clock generator to produce these frequencies. The 62.5MHz "main" clock is not used in this design.

## DAPHNE specific logic

### Timestamp

A free running 64 counter is used as the timestamp. THis 

### AFE Front End

This design includes the AFE front end logic, which enables the user to MANUALLY deskew and align the high speed AFE data outputs (IDELAY) and convert the serial data stream to parallel (ISERDES). There are 45 channels, 9 per AFE chip (8 data channels and one "FCLK" or frame channel).

### Spy Buffers

There are 45 spy buffers for the AFEs. Each spy buffer is 14 bits wide by 4k deep. An additional 64-bit wide spy buffer is used to store the timestamp value.

### Trigger

All spy buffers are triggered from a common signal, either the external SMA input on the rear panel, or by writing to a specific register from the Ethernet side. Once triggered, the spy buffers capture data, then stop and rearm waiting for the next trigger.

## Software

Some example routines are included, they are written in Python and included in the src directory. The default Ethernet MAC address (00:80:55:EC:00:0C) and IP address (192.168.133.12) are defined in the VHDL package file. These python programs will read from and write to the various test registers and memories mentioned above.

### Memory Map

The memory map is defined in daphne_package.vhd and the address space is 32 bit. Data width is 64 bits.

0x70000 - 0x703FF  Test BlockRam 1kx36, R/W, 36 bit
0xAA55             Test register R/O always returns 0xDEADBEEF, R/O, 32 bit
0x1974             Status vector for the PCS/PMA IP Core, R/O, 16 bit
0x12345678         Test register, R/W, 64 bit
0x80000000         Test FIFO, 512 x 64, R/W, 64-bit

0x2000             Write anything to trigger spy buffers, W/O

0x3000 			   Write anything to BITSLIP AFE0 data0, W/O
0x3001 			   Write anything to BITSLIP AFE0 data1
0x3002 			   Write anything to BITSLIP AFE0 data2
0x3003 			   Write anything to BITSLIP AFE0 data3
0x3004 			   Write anything to BITSLIP AFE0 data4
0x3005 			   Write anything to BITSLIP AFE0 data5
0x3006 			   Write anything to BITSLIP AFE0 data6
0x3007 			   Write anything to BITSLIP AFE0 data7
0x3008 			   Write anything to BITSLIP AFE0 frame
0x3009 			   Write anything to BITSLIP AFE1 data0
0x300A 			   Write anything to BITSLIP AFE1 data1
0x300B 			   Write anything to BITSLIP AFE1 data2
0x300C 			   Write anything to BITSLIP AFE1 data3
0x300D 			   Write anything to BITSLIP AFE1 data4
0x300E 			   Write anything to BITSLIP AFE1 data5
0x300F 			   Write anything to BITSLIP AFE1 data6
0x3010 			   Write anything to BITSLIP AFE1 data7
0x3011 			   Write anything to BITSLIP AFE1 frame
0x3012 			   Write anything to BITSLIP AFE2 data0
0x3013 			   Write anything to BITSLIP AFE2 data1
0x3014 			   Write anything to BITSLIP AFE2 data2
0x3015 			   Write anything to BITSLIP AFE2 data3
0x3016 			   Write anything to BITSLIP AFE2 data4
0x3017 			   Write anything to BITSLIP AFE2 data5
0x3018 			   Write anything to BITSLIP AFE2 data6
0x3019 			   Write anything to BITSLIP AFE2 data7
0x301A 			   Write anything to BITSLIP AFE2 frame
0x301B 			   Write anything to BITSLIP AFE3 data0
0x301C 			   Write anything to BITSLIP AFE3 data1
0x301D 			   Write anything to BITSLIP AFE3 data2
0x301E 			   Write anything to BITSLIP AFE3 data3
0x301F 			   Write anything to BITSLIP AFE3 data4
0x3020 			   Write anything to BITSLIP AFE3 data5
0x3021 			   Write anything to BITSLIP AFE3 data6
0x3022 			   Write anything to BITSLIP AFE3 data7
0x3023 			   Write anything to BITSLIP AFE3 frame
0x3024 			   Write anything to BITSLIP AFE4 data0
0x3025 			   Write anything to BITSLIP AFE4 data1
0x3026 			   Write anything to BITSLIP AFE4 data2
0x3027 			   Write anything to BITSLIP AFE4 data3
0x3028 			   Write anything to BITSLIP AFE4 data4
0x3029 			   Write anything to BITSLIP AFE4 data5
0x302A 			   Write anything to BITSLIP AFE4 data6
0x302B 			   Write anything to BITSLIP AFE4 data7
0x302C 			   Write anything to BITSLIP AFE4 frame

0x4000 			   Write fine delay value for AFE0 data0, W/O 5 bit
0x4001 			   Write fine delay value for AFE0 data1
0x4002 			   Write fine delay value for AFE0 data2
0x4003 			   Write fine delay value for AFE0 data3
0x4004 			   Write fine delay value for AFE0 data4
0x4005 			   Write fine delay value for AFE0 data5
0x4006 			   Write fine delay value for AFE0 data6
0x4007 			   Write fine delay value for AFE0 data7
0x4008 			   Write fine delay value for AFE0 frame
0x4009 			   Write fine delay value for AFE1 data0
0x400A 			   Write fine delay value for AFE1 data1
0x400B 			   Write fine delay value for AFE1 data2
0x400C 			   Write fine delay value for AFE1 data3
0x400D 			   Write fine delay value for AFE1 data4
0x400E 			   Write fine delay value for AFE1 data5
0x400F 			   Write fine delay value for AFE1 data6
0x4010 			   Write fine delay value for AFE1 data7
0x4011 			   Write fine delay value for AFE1 frame
0x4012 			   Write fine delay value for AFE2 data0
0x4013 			   Write fine delay value for AFE2 data1
0x4014 			   Write fine delay value for AFE2 data2
0x4015 			   Write fine delay value for AFE2 data3
0x4016 			   Write fine delay value for AFE2 data4
0x4017 			   Write fine delay value for AFE2 data5
0x4018 			   Write fine delay value for AFE2 data6
0x4019 			   Write fine delay value for AFE2 data7
0x401A 			   Write fine delay value for AFE2 frame
0x401B 			   Write fine delay value for AFE3 data0
0x401C 			   Write fine delay value for AFE3 data1
0x401D 			   Write fine delay value for AFE3 data2
0x401E 			   Write fine delay value for AFE3 data3
0x401F 			   Write fine delay value for AFE3 data4
0x4020 			   Write fine delay value for AFE3 data5
0x4021 			   Write fine delay value for AFE3 data6
0x4022 			   Write fine delay value for AFE3 data7
0x4023 			   Write fine delay value for AFE3 frame
0x4024 			   Write fine delay value for AFE4 data0
0x4025 			   Write fine delay value for AFE4 data1
0x4026 			   Write fine delay value for AFE4 data2
0x4027 			   Write fine delay value for AFE4 data3
0x4028 			   Write fine delay value for AFE4 data4
0x4029 			   Write fine delay value for AFE4 data5
0x402A 			   Write fine delay value for AFE4 data6
0x402B 			   Write fine delay value for AFE4 data7
0x402C 			   Write fine delay value for AFE4 frame

0x4000000 - 0x40003FF Spy Buffer AFE0 data0
0x4010000 - 0x40103FF Spy Buffer AFE0 data1
0x4020000 - 0x40203FF Spy Buffer AFE0 data2
0x4030000 - 0x40303FF Spy Buffer AFE0 data3
0x4040000 - 0x40403FF Spy Buffer AFE0 data4
0x4050000 - 0x40503FF Spy Buffer AFE0 data5
0x4060000 - 0x40603FF Spy Buffer AFE0 data6
0x4070000 - 0x40703FF Spy Buffer AFE0 data7
0x4080000 - 0x40803FF Spy Buffer AFE0 frame
0x4090000 - 0x40903FF Spy Buffer AFE1 data0
0x40A0000 - 0x40A03FF Spy Buffer AFE1 data1
0x40B0000 - 0x40B03FF Spy Buffer AFE1 data2
0x40C0000 - 0x40C03FF Spy Buffer AFE1 data3
0x40D0000 - 0x40D03FF Spy Buffer AFE1 data4
0x40E0000 - 0x40E03FF Spy Buffer AFE1 data5
0x40F0000 - 0x40F03FF Spy Buffer AFE1 data6
0x4100000 - 0x41003FF Spy Buffer AFE1 data7
0x4110000 - 0x41103FF Spy Buffer AFE1 frame
0x4120000 - 0x41203FF Spy Buffer AFE2 data0
0x4130000 - 0x41303FF Spy Buffer AFE2 data1
0x4140000 - 0x41403FF Spy Buffer AFE2 data2
0x4150000 - 0x41503FF Spy Buffer AFE2 data3
0x4160000 - 0x41603FF Spy Buffer AFE2 data4
0x4170000 - 0x41703FF Spy Buffer AFE2 data5
0x4180000 - 0x41803FF Spy Buffer AFE2 data6
0x4190000 - 0x41903FF Spy Buffer AFE2 data7
0x41A0000 - 0x41A03FF Spy Buffer AFE2 frame
0x41B0000 - 0x41B03FF Spy Buffer AFE3 data0
0x41C0000 - 0x41C03FF Spy Buffer AFE3 data1
0x41D0000 - 0x41D03FF Spy Buffer AFE3 data2
0x41E0000 - 0x41E03FF Spy Buffer AFE3 data3
0x41F0000 - 0x41F03FF Spy Buffer AFE3 data4
0x4200000 - 0x42003FF Spy Buffer AFE3 data5
0x4210000 - 0x42103FF Spy Buffer AFE3 data6
0x4220000 - 0x42203FF Spy Buffer AFE3 data7
0x4230000 - 0x42303FF Spy Buffer AFE3 frame
0x4240000 - 0x42403FF Spy Buffer AFE4 data0
0x4250000 - 0x42503FF Spy Buffer AFE4 data1
0x4260000 - 0x42603FF Spy Buffer AFE4 data2
0x4270000 - 0x42703FF Spy Buffer AFE4 data3
0x4280000 - 0x42803FF Spy Buffer AFE4 data4
0x4290000 - 0x42903FF Spy Buffer AFE4 data5
0x42A0000 - 0x42A03FF Spy Buffer AFE4 data6
0x42B0000 - 0x42B03FF Spy Buffer AFE4 data7
0x42C0000 - 0x42C03FF Spy Buffer AFE4 frame
0x42D0000 - 0x42D03FF Spy Buffer for Timestamp (64-bit)

### Manual Alignment Procedure

1. Put AFEs into fixed test pattern output mode
2. Force trigger
3. Readout Spy buffer for channel x
4. Write fine delay value for channel x
5. Repeat steps 2-5 for all delay values 0-31
6. Note when data pattern "jumps" -- that is the edge of the bit window
7. choose center value, write that to delay register for channel x (now you are sampling in center of the eye!)
8. trigger, readout, and bitslip as needed until received data pattern is correct on channel x
9. put AFEs back into normal data mode

Note that the frame marker should always read "11111110000000"

## Build Instructions

This demo is to be built from the command like in Vivado Non-Project mode:

  vivado -mode tcl -source vivado_batch.tcl

Build it and program the FPGA on the DAPHNE board with the bit file. Then connect it to the network and try pinging the IP address. It should respond. Then you can try reading and writing using the special OEI UDP packets (see the example code in Python). There are some registers and buffer memories in this demo design to try out.

JTO
