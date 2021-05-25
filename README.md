# Off the Shelf Ethernet Interface (OEI) for SFP

## Introduction

The OEI interface is straightforward way for a PC to talk to an FPGA over a Gigabit Ethernet link. This design was developed at Fermilab by Ryan Rivera and Lorenzo Uplegger. The network interface uses special UDP packets which are easy to create in any programming language like Python or C. Commands contained in these packets support reading and writing parallel data from addresses. Inside the FPGA the OEI firmware block presents a synchronous parallel address data bus which can be used to read and write registers, buffers, FIFOs, etc. in the user design.

Originally this design used a 1000BASE-T Ethernet PHY chip located outside the FPGA, with the remaining logic (including MAC layer) in the FPGA. The demo presented here pulls the Ethernet PHY logic into the FPGA using an MGT transceiver running at 1.25Gbps. An SFP transceiver (copper or fiber) is then used for the physical connection to the network.

## IP Cores

This design uses the "Gigabit Ethernet PCS PMA" IP core from Xilinx. It is included in every Vivado build and is free to use. The build script pulls this core automatically.

## Hardware

This demo design is targets the XC7K325TFF900-2 FPGA on the Xilinx KC705 development board. Plug an SFP or SFP+ module into the SFP cage on the development board and connect the other end to a GbE port in a switch or PC.

Note there is a difference between the KC705 v1.0 and v1.1 PCB revisions. One of the SFP differential pairs used by this design is flipped on the v1.1 PCB. See comments in top_level.vhd for details.

In the FPGA there are some various registers and memories that are connected to the internal address data bus. Specifically there is a BlockRAM, a couple of static readonly registers, a read-write test register, and a FIFO. The address mapping for these things is defined in the kc705_package.vhd file.

## Software

Some example routines are included, they are written in Python and included in the src directory. The default Ethernet MAC address (00:80:55:EC:00:0C) and IP address (192.168.133.12) are defined in the VHDL package file. These python programs will read from and write to the various test registers and memories mentioned above.

## Instructions

This demo is to be built from the command like in Vivado Non-Project mode:

  vivado -mode tcl -source vivado_batch.tcl

Build it and program the FPGA on the KC705 board with the bit file. Then connect it to the network and try pinging the IP address. It should respond. Then you can try reading and writing using the special OEI UDP packets (see the example code in Python). There are some registers and buffer memories in this demo design to try out.

JTO
