import socket
import struct

class OEI(object):

    def __init__(self,ipaddr):
        self.sock = socket.socket(socket.AF_INET,
                                  socket.SOCK_DGRAM)
        self.target = (ipaddr,2001)

    def read(self,addr):
        cmd = ""
        cmd += struct.pack("B",0)  # read operation
        cmd += struct.pack("B",1)  # read 1 word
        cmd += struct.pack("Q",addr) 
        self.sock.sendto(cmd,self.target)
        d,a = self.sock.recvfrom(10)
        ptype,seq,data = struct.unpack('<BBQ',d)
        return "0x"+format(data,'016x')

    def write(self,addr,data):
        cmd = ""
        cmd += struct.pack("B",1)  # write operation
        cmd += struct.pack("B",1)  # write 1 word
        cmd += struct.pack("Q",addr) 
        cmd += struct.pack("Q",data)
        self.sock.sendto(cmd,self.target)

    def close(self):
        self.sock.close()


thing = OEI("192.168.133.12")

print thing.read(0xAA55)

thing.write(0x12345678, 0xdeadbeefbabecafe)
print thing.read(0x12345678)

thing.write(0x70000, 0x2005)
thing.write(0x70001, 0x2008)
thing.write(0x70002, 0x2011)
thing.write(0x70003, 0xFEDCBA9876543210)

print thing.read(0x70000)
print thing.read(0x70001)
print thing.read(0x70002)
print thing.read(0x70003)

thing.close()

