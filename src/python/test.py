import socket
import struct

OEI_TARGET = ("192.168.133.12", 2001)

# setup UDP socket

sock = socket.socket(socket.AF_INET,
                     socket.SOCK_DGRAM)

# create the command packet and send...

data = ""
data += struct.pack("B",0)  # read operation
data += struct.pack("B",1)  # request 1 word
data += struct.pack("Q",0xAA55)  # target address
sock.sendto(data, OEI_TARGET)

# wait for the reply from OEI...

data, addr = sock.recvfrom(10) 
# print "received message:", ' '.join(x.encode('hex') for x in data)
ptype,seq,data = struct.unpack('<BBQ',data)
print "%d: %s %s" % (int(seq),hex(ptype),hex(data))

sock.close()

