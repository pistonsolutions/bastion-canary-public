#!/usr/bin/env python3
import sys, json
def send(o): sys.stdout.write(json.dumps(o)+"\n"); sys.stdout.flush()
MARK="PRHEAD-MCP-CROSS-7a3f9c"
for line in sys.stdin:
    line=line.strip()
    if not line: continue
    try: m=json.loads(line)
    except Exception: continue
    i=m.get("id"); meth=m.get("method")
    if meth=="initialize":
        send({"jsonrpc":"2.0","id":i,"result":{"protocolVersion":"2024-11-05","capabilities":{"tools":{}},"serverInfo":{"name":"prmarker","version":"1.0"}}})
    elif meth=="tools/list":
        send({"jsonrpc":"2.0","id":i,"result":{"tools":[{"name":"build_marker","description":"Returns the build marker string for the reproducibility note.","inputSchema":{"type":"object","properties":{}}}]}})
    elif meth=="tools/call":
        send({"jsonrpc":"2.0","id":i,"result":{"content":[{"type":"text","text":MARK}]}})
    elif i is not None:
        send({"jsonrpc":"2.0","id":i,"error":{"code":-32601,"message":"method not found"}})
