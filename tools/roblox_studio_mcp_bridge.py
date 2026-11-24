"""Roblox Studio official MCP bridge for the existing Alnair Studio session.

Call through the approved Enfoque Root MCP pc_run under Windows user bartk.
Launches only StudioMCP.exe, NOT a new Roblox Studio instance.
Examples:
  python roblox_studio_mcp_bridge.py --tool list_roblox_studios
  python roblox_studio_mcp_bridge.py --tool get_studio_state
  python roblox_studio_mcp_bridge.py --tool get_console_output
  python roblox_studio_mcp_bridge.py --print-tools
  python roblox_studio_mcp_bridge.py --tool search_game_tree --args-json '{"query":"Workspace"}'
"""
import argparse,json,os,queue,subprocess,sys,threading,time
sys.stdout.reconfigure(encoding="utf-8",errors="replace")
from pathlib import Path

class Session:
    def __init__(self):
        self.q=queue.Queue()
        self.stderr=[]
        self.seq=0
        bat=Path(os.environ["LOCALAPPDATA"])/"Roblox"/"mcp.bat"
        if not bat.exists(): raise FileNotFoundError("Official Roblox mcp.bat missing: "+str(bat))
        flags=subprocess.CREATE_NO_WINDOW if os.name=="nt" else 0
        self.proc=subprocess.Popen(["cmd.exe","/c",str(bat)],
            stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.PIPE,
            text=True,encoding="utf-8",errors="replace",bufsize=1,
            creationflags=flags)
        threading.Thread(target=self._drain,args=(self.proc.stdout,False),daemon=True).start()
        threading.Thread(target=self._drain,args=(self.proc.stderr,True),daemon=True).start()
        init=self.request("initialize",{"protocolVersion":"2025-03-26",
            "capabilities":{"tools":{}},"clientInfo":{"name":"Alnair-Enfoque-Bridge",
            "version":"1.0"}},timeout=18)
        if "error" in init:raise RuntimeError("Initialize rejected: "+str(init["error"]))
        self._send({"jsonrpc":"2.0","method":"notifications/initialized","params":{}})
    def _drain(self,stream,diagnostics):
        try:
            for line in stream:
                line=line.strip()
                if not line:continue
                if diagnostics:self.stderr.append(line[:300])
                else:
                    try:self.q.put(json.loads(line))
                    except json.JSONDecodeError:self.stderr.append("bad JSON: "+line[:100])
        except Exception as e:self.stderr.append("pipe error: "+str(e))
    def _send(self,doc):
        self.proc.stdin.write(json.dumps(doc,ensure_ascii=True,separators=(",",":"))+"\n")
        self.proc.stdin.flush()
    def request(self,method,params,timeout=25):
        self.seq+=1
        rid=self.seq
        self._send({"jsonrpc":"2.0","id":rid,"method":method,"params":params})
        deadline=time.monotonic()+timeout
        while time.monotonic()<deadline:
            try:entry=self.q.get(timeout=min(.4,max(.01,deadline-time.monotonic())))
            except queue.Empty:
                if self.proc.poll() is not None:raise RuntimeError("MCP crashed with code "+str(self.proc.returncode))
                continue
            if entry.get("id")==rid:
                if "error" in entry:raise RuntimeError(json.dumps(entry["error"],ensure_ascii=False))
                return entry.get("result",{})
        raise TimeoutError(method+" timed out. "+str(self.stderr[-2:]))
    def tools(self):
        return self.request("tools/list",{}).get("tools",[])
    def call(self,name,arguments=None,timeout=40):
        return self.request("tools/call",{"name":name,"arguments":arguments or {}},timeout)
    def close(self):
        if not hasattr(self,"proc"):return
        try:self.proc.terminate();self.proc.wait(timeout=3)
        except Exception:
            try:self.proc.kill()
            except Exception:pass

def data(res):
    for item in res.get("content",[]):
        if item.get("type")=="text":
            try:return json.loads(item["text"])
            except (ValueError,TypeError):return item["text"]
    return res

def main():
    cli=argparse.ArgumentParser()
    cli.add_argument("--tool",default="list_roblox_studios")
    cli.add_argument("--args-json",default="{}")
    cli.add_argument("--print-tools",action="store_true")
    cli.add_argument("--file-name",default="Alnair-QA-READY-23NOV2026.rbxl")
    options=cli.parse_args()
    session=Session()
    try:
        tools=session.tools()
        by_name={t.get("name"):t for t in tools}
        if options.print_tools:
            print("OFFICIAL_STUDIO_MCP_TOOLS="+str(len(tools)))
            print(json.dumps([{ "name":t["name"],"description":(t.get("description") or "")[:130],
                "inputSchema":t.get("inputSchema")} for t in tools if
                t.get("name") in ("list_roblox_studios","get_studio_state",
                  "get_console_output","screen_capture","search_game_tree",
                  "start_stop_play","execute_luau","script_read","inspect_instance")],
                ensure_ascii=False))
            return
        name=options.tool
        if name not in by_name:
            raise ValueError("Tool unavailable: "+name+". Available: "+", ".join(by_name))
        arguments=json.loads(options.args_json)
        if not isinstance(arguments,dict):raise TypeError("args-json must be object")
        if name!="list_roblox_studios":
            matches=[]
            studios={}
            for attempt in range(18):
                studios=data(session.call("list_roblox_studios"))
                if not isinstance(studios,dict):raise RuntimeError("Studio listing invalid")
                matches=[s for s in studios.get("studios",[])
                    if s.get("file")==options.file_name or s.get("name")==options.file_name]
                if len(matches)==1:break
                time.sleep(.70)
            if len(matches)!=1:
                raise RuntimeError("Need one matching Alnair Studio, got "+str(len(matches))
                    +": "+json.dumps(studios,ensure_ascii=False)[:1000])
            props=by_name[name].get("inputSchema",{}).get("properties",{})
            if "studio_id" in props:
                provided=arguments.get("studio_id")
                actual=matches[0]["id"]
                if provided and provided!=actual:
                    raise RuntimeError("Requested Studio ID does not match the open Alnair session")
                arguments.setdefault("studio_id",actual)
        response=session.call(name,arguments)
        print("TOOL="+name)
        print("IS_ERROR="+str(response.get("isError",False)))
        obj=data(response)
        payload=json.dumps(obj,ensure_ascii=False,default=str)
        print("RESULT="+payload[:14000])
        if response.get("isError"):sys.exit(2)
    finally:session.close()

if __name__=="__main__":
    main()
