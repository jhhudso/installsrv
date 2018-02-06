#!/usr/bin/python3
#socat -u TCP4-LISTEN:4242,reuseaddr,fork OPEN:/dev/usb/lp0

import sys
import json
from escpos import printer

jsonStr = """
{
   "id": "123456789012",
   "cpu": "Intel Core i7-5960X CPU @ 3.00GHz",
   "motherboard": "Asrock X99 Professional/3.1",
   "memory": "Corsair CMK32GX4M4A2666C15 32GiB",
   "storage": [
      {
         "type": "hdd",
         "model": "Seagate STXXXXXXX",
         "size": "2 TiB"
      },
      {
         "type": "ssd",
         "model": "Samsung 850 EVO",
         "size": "1 TiB"
      }
   ],
   "psu": "Corsair AX850i",
   "gpu": "EVGA Geforce GTX Titan X 12GB"
}"""

j = json.loads(jsonStr)

p = printer.File('/dev/usb/lp0')
#p = printer.Network("192.168.1.172", 4242)
p.set('center')
p.image("fgarlogo.png", False, False, "bitImageRaster", 960)

p.set('left','a',True)
p.text("CPU: ")
p.set('left','a',False)
p.textln(j['cpu'])

p.set('left','a',True)
p.text("Motherboard: ")
p.set('left','a',False)
p.textln(j['motherboard'])

p.set('left','a',True)
p.text("Memory: ")
p.set('left','a',False)
p.textln(j['memory'])

p.set('left','a',True)
p.text("Power Supply: ")
p.set('left','a',False)
p.textln(j['psu'])

p.set('left','a',True)
p.text("GPU: ")
p.set('left','a',False)
p.textln(j['gpu'])

p.set('left','a',True)
p.text("Storage: ")
p.set('left','a',False)
for storage in j['storage']:
    p.ln()
    p.textln(' Type:  ' + storage['type'])
    p.textln(' Model: ' + storage['model'])
    p.textln(' Size:  ' + storage['size'])

p.set('center')
p.barcode(j['id'], 'UPC-A')

p.cut()

sys.exit(0)
