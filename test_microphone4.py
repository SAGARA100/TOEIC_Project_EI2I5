#!/usr/bin/env python3

import argparse
import os
import queue
# import sounddevice as sd
import vosk
import sys
from vosk import Model, KaldiRecognizer

import socket
import json
import difflib
import threading
import time

# Par rapport au programme test_microphone.py original, nous avons besoin
# d'un serveur UDP dans cette application pour recevoir les messages de Mute et UnMute
serverAddressPort=("127.0.0.1", 4242)
UDPClientSocket=socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)
bufferSize=1024
messageFromGodot=""
# La variable globale muted est tres importante. Si le thread de reception
# de message UDP recoit un ordre Mute alors mutes=1, on desactive temporairement vosk
# Si le message recu est UnMute, alors muted repasse a 0
muted=0

# La tres importante liste des mots connus et attendus
knownWords=[["a","a"],["hey","a"],["b","b"],["be","b"],["c","c"],["see","c"],["dee","d"],["d","d"],["the","d"],["left","left"],["right","right"],["forward","forward"],["play","play"],["stop","stop"]]

# La fonction de thread permettant de recevoir les messages UDP sur le port 4243
def thread_function(name):
   UDPServerSocket = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)
   UDPServerSocket.bind(("127.0.0.1", 4243))
   while True:
      bytesAddressPair = UDPServerSocket.recvfrom(1024)
      message = bytesAddressPair[0]
      messageFromGodot=message.decode()
      print("messageFromGodot=",messageFromGodot[0])
      global muted
      if (messageFromGodot[0]=='U'):
         muted=0
      else:
         muted=1
      print("muted=",muted)

# Il ne faut pas oublier de creer le thread
x = threading.Thread(target=thread_function, args=(1,))
# et de lui donner la propriete daemon, pour qu'on puisse arreter l'application par Ctrl-C, sinon il faut
# fermer la fenetre
x.setDaemon(True)
x.start()

# tout le reste vient du programme original
q = queue.Queue()

def int_or_str(text):
    """Helper function for argument parsing."""
    try:
        return int(text)
    except ValueError:
        return text

def callback(indata, frames, time, status):
    """This is called (from a separate thread) for each audio block."""
    if status:
        print(status, file=sys.stderr)
    q.put(bytes(indata))

parser = argparse.ArgumentParser(add_help=False)
parser.add_argument(
    '-l', '--list-devices', action='store_true',
    help='show list of audio devices and exit')
args, remaining = parser.parse_known_args()
if args.list_devices:
    print(sd.query_devices())
    parser.exit(0)
parser = argparse.ArgumentParser(
    description=__doc__,
    formatter_class=argparse.RawDescriptionHelpFormatter,
    parents=[parser])
parser.add_argument(
    '-f', '--filename', type=str, metavar='FILENAME',
    help='audio file to store recording to')
parser.add_argument(
    '-m', '--model', type=str, metavar='MODEL_PATH',
    help='Path to the model')
parser.add_argument(
    '-d', '--device', type=int_or_str,
    help='input device (numeric ID or substring)')
parser.add_argument(
    '-r', '--samplerate', type=int, help='sampling rate')
args = parser.parse_args(remaining)

try:
    if args.model is None:
        args.model = "model"
    if not os.path.exists(args.model):
        print ("Please download a model for your language from https://alphacephei.com/vosk/models")
        print ("and unpack as 'model' in the current folder.")
        parser.exit(0)
    if args.samplerate is None:
        device_info = sd.query_devices(args.device, 'input')
        # soundfile expects an int, sounddevice provides a float:
        args.samplerate = int(device_info['default_samplerate'])

    model = vosk.Model(args.model)

    if args.filename:
        dump_fn = open(args.filename, "wb")
    else:
        dump_fn = None

    with sd.RawInputStream(samplerate=args.samplerate, blocksize = 8000, device=args.device, dtype='int16',
                            channels=1, callback=callback):

            print('#' * 80)
            print('Press Ctrl+C to stop the recording')
            print('#' * 80)

            rec = vosk.KaldiRecognizer(model, args.samplerate)
            #
            # C'est ici que se trouve la boucle principale de l'application
            #
            while True:
            	# On affiche la valeur de muted. Si muted==1 alors on n'ecoute pas vosk
                print(muted)
                if muted==1:
                    continue
		#
		# sinon, on recupere le message au format JSON dans res
                data = q.get()
                if rec.AcceptWaveform(data):
                    res=json.loads(rec.Result())['text']
                    print("|",res,"|")
                    # et on compare res avec tous les mots connus, en utilisant difflib.SequenceMatcher
                    # qui permet de comparer des chaines de caracteres quelconques en donnant un ratio
                    # de similarite, 0.0 pas similaire 1.0 similaire
                    mx=-1.0
                    wx=""
                    for w in knownWords:
                    	seq=difflib.SequenceMatcher(a=res.lower(), b=w[0].lower())
                    	print(w,seq.ratio())
                    	if seq.ratio()>mx and seq.ratio()>0.0:
                    	   mx=seq.ratio()
                    	   wx=w[1]
                    # A la fin wx contient le mot le plus probable
                    # Si il n'est pas vide, on l'envoie en UDP sur le port 4242 a destination de Godot
                    if wx!="":
                       print(wx)
                       bytesToSend=str.encode(wx)
                       UDPClientSocket.sendto(bytesToSend, serverAddressPort)
                else:
                    pass
                    #print(rec.PartialResult())
                if dump_fn is not None:
                    dump_fn.write(data)

except KeyboardInterrupt:
    print('\nDone')
    parser.exit(0)
except Exception as e:
    parser.exit(type(e).__name__ + ': ' + str(e))
