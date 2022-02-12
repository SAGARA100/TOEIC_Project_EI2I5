extends Spatial

var server := UDPServer.new()
var peers = []

func _ready():
	server.listen(4242)

func _process(delta):
	server.poll() # Important!
	if server.is_connection_available():
		var peer : PacketPeerUDP = server.take_connection()
		var pkt = peer.get_packet()
		print("Accepted peer: %s:%s" % [peer.get_packet_ip(), peer.get_packet_port()])
		var pktstr=pkt.get_string_from_utf8()
		print(len(pktstr))
		#print("Received data: %c" % [pktstr[0]])
		if (len(pktstr)>0):
			if (pktstr[0]=='b'):
				$Camera.translation.z+=1
			elif (pktstr[0]=='f'):
				$Camera.translation.z-=1
			elif (pktstr[0]=='r'):
				$Camera.translation.x+=1
			elif (pktstr[0]=='l'):
				$Camera.translation.x-=1
