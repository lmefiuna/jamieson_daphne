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
# print "read addr 0x9000, git commit hash =", hex(thing.read(0x9000,1)[2])

# write to test register and read it back
#thing.write(0x12345678, [0xdeadbeef1234] )
#print "read test reg addr 0x12345678 read", hex(thing.read(0x12345678,1)[2])

thing.write(0x2001, [0xdeadbeef]) # reset all ISERDES 

# now do some bitslips, this is determined experimentally
# yeah, currently this is a total hack. I'm sure there is some clever way to 
# 1) determine the ideal delay tap value for each AFE
# 2) bitslip each channel until it is properly aligned
# but for now, just paste in the number of bitslips for each channel to make it look OK.

thing.write(0x3018, [0])
thing.write(0x3018, [0])
thing.write(0x3018, [0])


thing.write(0x3028, [0])
thing.write(0x3028, [0])
thing.write(0x3028, [0])
thing.write(0x3028, [0])
thing.write(0x3028, [0])
thing.write(0x3028, [0])

# now dump all channels sweep all delay values to check it

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

# prompt user which 


#for a in range(5):
#    print "calibrating AFE%d" % a,
#    for bs in range(20): # attempt bitslip this many times max
#        thing.write(0x2000, [0xdeadbeef]) 
#        x = thing.read((0x40080000+(0x100000*a)),1)[2]
#        if (x == 0x3F80):
#            print "ALIGNED!"
#            break
#        else:
#            print ".",
#            thing.write(0x3000+a,[1234])



# print "Set delay taps to ideal sample point (determined experimentally)"
thing.write(0x4000, [14,19,13,20,14])

# I think AFE0 is in RAMP mode, let's check it
# should see the 8 data channels for AFE0 incrementing by 1 count

thing.write(0x2000, [1234]) # trigger

print

for c in range(9):
    for x in thing.read(0x40000000+(c*0x10000),20)[3:]:
        print "%04X" % x,
    print 
       
thing.close()


