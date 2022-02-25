# simple program to connect to the DAPHNE board via Gigabit Ethernet
# and readout raw AFE data
# 
# in linux, you may need to configure your NIC card as root, something like this:
#
# $ ifconfig p3p1 192.168.133.99 netmask 255.255.255.0
# $ ip route add 192.168.133.0/24 dev p3p1
# 
# Jamieson Olsen <jamieson@fnal.gov>

from oei import *

thing = OEI("192.168.133.12")

# single read from register at 0xaa55, should return 0xdeadbeef
print "read addr 0xaa55 (should read 0xdeadbeef) read", hex(thing.read(0xaa55,1)[2])

# single read from register at 0x9000, should return the git sh for this commit
print "read addr 0x9000, git commit hash =", hex(thing.read(0x9000,1)[2])

# write to test register and read it back
thing.write(0x12345678, [0xdeadbeef1234] )
print "read test reg addr 0x12345678 read", hex(thing.read(0x12345678,1)[2])

print "\nBegin AFE data alignment"

print "Reset the front end"
thing.write(0x2001, [0xdeadbeef])

print "Set delay taps to ideal sample point"
thing.write(0x4000, [14,19,13,20,14])

# trigger, read, bitslip until frame marker reads 0x3F80

for a in range(5):
    print "calibrating AFE%d" % a,
    for bs in range(20): # attempt bitslip this many times max
        thing.write(0x2000, [0xdeadbeef]) 
        x = thing.read((0x40080000+(0x100000*a)),1)[2]
        if (x == 0x3F80):
            print "ALIGNED!"
            break
        else:
            print ".",
            thing.write(0x3000+a,[1234])

print "End AFE data alignment"

# dump all channels all delay values to check it

print "\n          00   01   02   03   04   05   06   07   08   09   10   11   12   13   14   15",
print "  16   17   18   19   20   21   22   23   24   25   26   27   28   29   30   31",

for a in range(5):
    for b in range(9):
        print "\nAFE%d[%d]:" % (a,b),
        for dv in range(32):
            thing.write(0x4000+a, [dv])
            thing.write(0x2000, [1234])
            x = thing.read((0x40000000+(0x100000*a)+(0x10000*b)),1)[2]
            print "%04X" % x,
    print
        
print "\n\nReset delay taps to ideal sample point"
thing.write(0x4000, [14,19,13,20,14])

# force trigger, all spy buffers will capture
thing.write(0x2000, [0xdeadbeef]) 

# read 10 words from spy buffer for AFE0 data 4, the address will auto increment
# be careful not to transfer too many words at once, I'm not sure if this supports JUMBO UDP packets
x = thing.read(0x40040000,10)

# note that the read method returns a list
print x

# the raw data from the spy buffer starts at index 2
print x[2:]

# print it in hex
for a in x[2:]:
    print "%04X" % a

# read from the timestamp spy buffer and dump them, should be an incrementing 64-bit counter
x = thing.read(0x40500000,100)

for a in x[2:]:
    print "%016X" % a

thing.close()


