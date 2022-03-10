from oei import *

thing = OEI("192.168.133.12")

# number of times we should bitslip before giving up

BSRETRY = 100

# define the minimum bit width (in delay taps)

MINWIDTH = 13

print "DAPHNE firmware version %0X" % thing.read(0x9000,1)[2]

print "Resetting IDELAY and ISERDES..."
thing.write(0x2001, [0xdeadbeef])

# looking at the frame markers find the bit edges 
# and determine the ideal delay tap value for each AFE

for afe in range(5):
    print "AFE%d :" % afe,
    for r in range(BSRETRY):
        x = []
        w = 0
        c = 0
        es = ""
        for dv in range(32): # scan all 32 delay values
            thing.write(0x4000+afe, [dv]) # write delay value
            thing.write(0x2000, [1234]) # trigger
            x.append(thing.read((0x40000000+(0x100000*afe)+(0x80000)),5)[3])
        for i in range(32): # x contains 32 samples each with different delay
            if (x[i]==0x3F80): # test for the proper frame marker
                w = w + 1
                c = c + i
                es = es + "*"
            else:
                es = es + "."
        if (x[0]==0x3F80 and x[31]==0x3F80): # we want to avoid double hump alignment
            continue
        if (w >= MINWIDTH):
            print "[%s] ALIGNED OK! bit width %d, using IDELAY tap %d" % (es, w, int(c/w))
            thing.write(0x4000+afe, [int(c/w)]) # program idelay with optimal value
            break
        else:
            thing.write((0x3000+(0x10*afe)), [0,1,2,3,4,5,6,7,8]) # bitslip all AFE channels
        if (r==BSRETRY-1):
            print "FAILED!"


# now dump all channels sweep all delay values to check it
#print "\n          00   01   02   03   04   05   06   07   08   09   10   11   12   13   14   15",
#print "  16   17   18   19   20   21   22   23   24   25   26   27   28   29   30   31",

#for a in range(5):
#    for b in range(9):
#        print "\nAFE%d[%d]:" % (a,b),
#        for dv in range(32):
#            thing.write(0x4000+a, [dv])
#            thing.write(0x2000, [1234])
#            x = thing.read((0x40000000+(0x100000*a)+(0x10000*b)),5)[3]
#            print "%04X" % x,
#    print




# AFEs should be in RAMP mode, let's check 'em
# should see the 8 data channels for each AFE incrementing by 1 count
# all data channels within an AFE should be aligned if reg 10 bit 8 is set.

# thing.write(0x2000, [1234]) # trigger

# print

# for a in range(5):
#     for c in range(9):
#         print "AFE%d[%d]: " % (a,c),
#        for x in thing.read(0x40000000+(a*0x100000)+(c*0x10000),20)[3:]:
#            print "%04X" % x,
#        print 
       
thing.close()

