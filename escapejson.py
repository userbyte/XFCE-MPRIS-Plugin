import re, sys

jsonstring=sys.stdin.read()

def repl_call(m):
    preq = m.group(1)
    qbody = m.group(2)
    qbody = re.sub(r'"', '\\"', qbody)
    return preq + '"' + qbody + '"'

print(re.sub(r'([:\[,{]\s*)"(.*?)"(?=\s*[:,\]}])', repl_call, jsonstring))