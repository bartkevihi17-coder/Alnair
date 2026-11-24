"""Safe two-phase sync of Alnair sources into the *existing* authenticated Studio.
Never calls pc_open, RobloxStudioBeta.exe or start_stop_play.
Usage: python sync_r15_to_existing_studio.py --phase 1|2
"""
from pathlib import Path
import argparse,importlib.util,json,time,hashlib,sys
sys.stdout.reconfigure(encoding="utf-8",errors="replace")
home=Path(r"C:\Users\bartk\Desktop\Alnair")
spec=importlib.util.spec_from_file_location("bridge",home/"tools/roblox_studio_mcp_bridge.py")
bridge=importlib.util.module_from_spec(spec);spec.loader.exec_module(bridge)

mapping=[
 ("src/shared/BlockyRig.lua","ReplicatedStorage",["AlnairShared","BlockyRig"],"ModuleScript"),
 ("src/shared/Appearance.lua","ReplicatedStorage",["AlnairShared","Appearance"],"ModuleScript"),
 ("src/shared/WeaponRender.lua","ReplicatedStorage",["AlnairShared","WeaponRender"],"ModuleScript"),
 ("src/server/EnemyDirector.lua","ServerScriptService",["AlnairServer","EnemyDirector"],"ModuleScript"),
 ("src/server/ArtAssets.lua","ServerScriptService",["AlnairServer","ArtAssets"],"ModuleScript"),
 ("src/server/Bootstrap.server.luau","ServerScriptService",["AlnairServer","Bootstrap"],"Script"),
 ("src/client/CameraDirector.lua","StarterPlayer",["StarterPlayerScripts","AlnairClient","CameraDirector"],"ModuleScript"),
 ("src/client/Alnair.client.luau","StarterPlayer",["StarterPlayerScripts","AlnairClient","Alnair"],"LocalScript"),
 ("src/client/R6Motion.client.luau","StarterPlayer",["StarterPlayerScripts","AlnairClient","R6Motion"],"LocalScript"),
 ("src/client/GameplayUI.client.luau","StarterPlayer",["StarterPlayerScripts","AlnairClient","GameplayUI"],"LocalScript"),
 ("src/server/WorldLighting.lua","ServerScriptService",["AlnairServer","WorldLighting"],"ModuleScript"),
 ("src/server/MenuHouseStage.lua","ServerScriptService",["AlnairServer","MenuHouseStage"],"ModuleScript"),
]
parser=argparse.ArgumentParser()
parser.add_argument("--phase",type=int,required=True,choices=[1,2])
args=parser.parse_args()

session=bridge.Session()
try:
    matches=[]
    for _ in range(20):
        studios=bridge.data(session.call("list_roblox_studios"))
        matches=[x for x in studios.get("studios",[])
                 if x.get("file")=="Alnair-NATIVE-R6-TEST.rbxl" and x.get("mode")=="Edit"]
        if len(matches)==1:break
        time.sleep(.6)
    if len(matches)!=1:raise RuntimeError("Refusing to sync: expected one existing Studio Edit session: "+str(studios)[:600])
    sid=matches[0]["id"]
    print("REUSING_EXISTING_STUDIO",sid,"PHASE",args.phase,flush=True)

    def run(code,timeout=55):
        reply=session.call("execute_luau",{"studio_id":sid,
           "datamodel_type":"Edit","code":code},timeout=timeout)
        result=bridge.data(reply)
        if reply.get("isError") or (isinstance(result,dict) and result.get("ok") is False):
            raise RuntimeError("Studio execute failure "+str(result)[:700])
        return result

    batch=mapping[:6] if args.phase==1 else mapping[6:]
    for filepath,service,segments,kind in batch:
        text=(home/filepath).read_text(encoding="utf-8")
        parent="game:GetService("+json.dumps(service)+")"
        for seg in segments[:-1]:parent+=":WaitForChild("+json.dumps(seg)+")"
        leaf=segments[-1]
        luau=f"""local parent={parent}
local target=parent:FindFirstChild({json.dumps(leaf)})
if not target then
 target=Instance.new({json.dumps(kind)})
 target.Name={json.dumps(leaf)}
 target.Parent=parent
end
if not target:IsA({json.dumps(kind)}) then return {{ok=false,error="Wrong class"}} end
target.Source={json.dumps(text,ensure_ascii=False)}
return {{ok=target.Source=={json.dumps(text,ensure_ascii=False)},bytes=#target.Source,class=target.ClassName}}
"""
        result=run(luau,timeout=85)
        print("SYNCED",filepath,"utf8",len(text.encode("utf-8")),
            "result",str(result)[:250],flush=True)
    if args.phase==2:
        env=r"""local ReplicatedStorage=game:GetService("ReplicatedStorage")
local ServerStorage=game:GetService("ServerStorage")
local art=ReplicatedStorage:WaitForChild("AlnairShared"):FindFirstChild("AlnairArtV05")
if art then art.Parent=ServerStorage end
if not ServerStorage:FindFirstChild("AlnairArtV05") then
 return {ok=false,error="Private art library missing"}
end
local W=workspace
W.StreamingEnabled=true
W.StreamingMinRadius=64
W.StreamingTargetRadius=256
W.StreamOutBehavior=Enum.StreamOutBehavior.Opportunistic
W.StreamingIntegrityMode=Enum.StreamingIntegrityMode.PauseOutsideLoadedArea
local weapons=ReplicatedStorage:FindFirstChild("AlnairWeapons")
if not weapons then return {ok=false,error="Curated weapon models missing"}end
local names={}
for _,model in ipairs(weapons:GetChildren()) do
 for _,item in ipairs(model:GetDescendants()) do
  if item:IsA("LuaSourceContainer") then
    return {ok=false,error="Untrusted third-party script: "..item:GetFullName()}
  end
 end
 table.insert(names,model.Name)
end
return {ok=true,streaming=W.StreamingEnabled,target=W.StreamingTargetRadius,
 library=ServerStorage.AlnairArtV05.Name,weaponModels=names}
"""
        result=run(env,timeout=70)
        print("STUDIO_WORKSPACE_CONFIG",result,flush=True)
        reply=session.call("save_place",{"studio_id":sid},timeout=75)
        result=bridge.data(reply)
        if reply.get("isError"):raise RuntimeError("Save failed "+str(result)[:600])
        print("SAVED_EXISTING_STUDIO_PLACE",str(result)[:300],flush=True)
    print("SYNC_PHASE_SUCCESS",args.phase,flush=True)
finally:session.close()
