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
# print "read addr 0xaa55 (should read 0xdeadbeef) read", hex(thing.read(0xaa55,1)[2])

# single read from register at 0x9000, should return the git sh for this commit
print "DAPHNE firmware version %0X" % thing.read(0x9000,1)[2]

# write to test register and read it back
#thing.write(0x12345678, [0xdeadbeef1234] )
#print "read test reg addr 0x12345678 read", hex(thing.read(0x12345678,1)[2])

# now dump all channels sweep all delay values to check it
print "\n          00   01   02   03   04   05   06   07   08   09   10   11   12   13   14   15",
print "  16   17   18   19   20   21   22   23   24   25   26   27   28   29   30   31",

for a in range(5):
    for b in range(9):
        print "\nAFE%d[%d]:" % (a,b),
        for dv in range(32):
            thing.write(0x4000+a, [dv])
            thing.write(0x2000, [1234])
            x = thing.read((0x40000000+(0x100000*a)+(0x10000*b)),5)[3]
            print "%04X" % x,
    print

print
print "NOTE: Be sure to re-run auto alignment to select optimal IDELAY tap values"
       
thing.close()

