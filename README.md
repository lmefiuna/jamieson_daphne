# Off the Shelf Ethernet Interface (OEI) for SFP

## Introduction

The OEI interface is straightforward way for a PC to talk to an FPGA over a Gigabit Ethernet link. This design was developed at Fermilab by Ryan Rivera and Lorenzo Uplegger. The network interface uses special UDP packets which are easy to create in any programming language like Python or C. Commands contained in these packets support reading and writing parallel data from addresses. Inside the FPGA the OEI firmware block presents a synchronous parallel address data bus which can be used to read and write registers, buffers, FIFOs, etc. in the user design.

Originally this design used a 1000BASE-T Ethernet PHY chip located outside the FPGA, with the remaining logic (including MAC layer) in the FPGA. The demo presented here pulls the Ethernet PHY logic into the FPGA using an MGT transceiver running at 1.25Gbps. An SFP transceiver (copper or fiber) is then used for the physical connection to the network.

## IP Cores

This design uses the "Gigabit Ethernet PCS PMA" IP core from Xilinx. It is included in every Vivado build and is free to use. The build script pulls this core. 

## Hardware

This demo design is targetted towards the Xilinx KC705 development board. Plug an SFP or SFP+ module into the SFP cage on the development board and connect the other end to a GbE port in a switch or PC.

The default Ethernet MAC address (00:80:55:EC:00:0C) and IP address (192.168.133.12) are defined in the VHDL package file.

## Instructions

This demo is to be built from the command like in Vivado Non-Project mode:

  vivado -mode tcl -source vivado_batch.tcl

Build it and program the FPGA on the KC705 board with the bit file. Then connect it to the network and try pinging the IP address. It should respond. Then you can try reading and writing using the special OEI UDP packets. There are some registers and buffer memories in this demo design to try out.
