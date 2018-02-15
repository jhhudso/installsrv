#!/usr/bin/python3
# Copyright 2017-2018 Jared H. Hudson
# Copyright 2018 Matthew Schuster
# 
# NOTES: If you need to make a USB ESCPOS printer be network accessible then use
# socat -u TCP4-LISTEN:4242,reuseaddr,fork OPEN:/dev/usb/lp0
#
# Requires python3-psycopg2

import sys
import select
import psycopg2
import psycopg2.extensions
import psycopg2.extras
import json
import argparse
from escpos import printer

parser = argparse.ArgumentParser(conflict_handler='resolve')
parser.add_argument('-h', '--host', help='hostname of database server (default: "installsrv.at.freegeekarkansas.org")', default='installsrv.at.freegeekarkansas.org')
parser.add_argument('-d', '--dbname', help='database name to connect to (default: "installsrv")',default='installsrv')
parser.add_argument('-U', '--username', help='database user name (default: "installsrv")',default='installsrv')
parser.add_argument('-W', '--password', help='database password',default=None)
parser.add_argument('-t', '--timeout', type=int, help='timeout in seconds for connection  (default: 3)',default='3')
args = parser.parse_args()

DSN = "host='{0}' dbname='{1}' user='{2}' password='{3}' connect_timeout={4}".format(args.host,args.dbname,args.username,args.password,args.timeout)

try:
    conn = psycopg2.connect(DSN)
except psycopg2.Error as e:
    print('Error connecting to database: {0}'.format(e))
    sys.exit(1)
else:
    print('Connected to database.')

conn.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)
curs = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)

curs.execute("LISTEN inventory;");
print("Listening...")
while 1:
    if select.select([conn],[],[],5) == ([],[],[]):
        continue
    else:
        conn.poll()
        while conn.notifies:
            notify = conn.notifies.pop(0)
            row_id = notify.payload
            computerString = "select * from computers where id = " + str(row_id) + ";"
            curs.execute(computerString)
				
            computer = curs.fetchone()
            computer_id = computer['id']
            print("Printing id:" + str(computer_id))
            motherboard = computer['motherboard_model']
            memory = computer['memory_model'] + " " + str(computer['memory_size'])
			#gpu = computer['gpu']
            cpu = computer['cpu_model']
            driveString = "select * from drives where computer_id = " + str(computer_id) + ";"
            curs.execute(driveString)
			
            hddrows = curs.fetchall()
            try:
                p = printer.File("/dev/usb/lp1")
				
                p.set('center')
                p.image("fgarlogo.png", False, False, "bitImageRaster", 960)
                p.set('left','a',True)

                p.text("CPU: ")
                p.set('left','a',False)
                p.textln(cpu)
                p.set('left','a',True)

                p.set('left','a',True)
                p.text("Motherboard: ")
                p.set('left','a',False)
                p.textln(motherboard)

                p.set('left','a',True)
                p.text("Memory: ")
                p.set('left','a',False)
                p.textln(memory)

				# p.set('left','a',True)
				# p.text("GPU: ")
				# p.set('left','a',False)
				# p.textln(gpu)

                p.set('left','a',True)
                p.text("Storage: ")
                p.set('left','a',False)
                for storage in hddrows:
                    p.ln()
                    p.textln(' Type:  ' + storage['type'])
                    p.textln(' Model: ' + storage['model'])
                    p.textln(' Size:  ' + str(storage['size']))

                p.set('center')
                p.barcode(str(computer_id), 'UPC-A')

                p.cut()
            except IOError as e:
                print("Printer error:" + str(e))
				


