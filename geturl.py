#!/usr/bin/python3

import subprocess
#output = subprocess.run(['./fullmetadata.sh'], stdout=subprocess.PIPE).stdout.decode('utf-8')
output = subprocess.run(['playerctl', '--player=spotify', 'metadata'], stdout=subprocess.PIPE).stdout.decode('utf-8')
output = output.replace('\n','')

print(output[-53::]) # get last N characters, in this case the URL is 53 chars long 