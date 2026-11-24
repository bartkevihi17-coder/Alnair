"""Patch the ONE existing Roblox Studio session through its official MCP.
No RobloxStudioBeta process is ever started. Requires Edit mode.
Usage:
  python apply_r15_costumes_in_place.py --group shared
  python apply_r15_costumes_in_place.py --group server
  python apply_r15_costumes_in_place.py --group client
  python apply_r15_costumes_in_place.py --group settings
"""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import sys
import time

sys.stdout.reconfigure(encoding="utf-8",errors="replace")
ROOT=Path(r"C:\Users\bartk\Desktop\Alnair")
BRIDGE=ROOT/"tools/roblox_studio_mcp_bridge.py"
sp=importlib.util.spec_from_file_location("bridge",BRIDGE)
bridge=importlib.util.module_from_spec(sp)
sp.loader.exec_module(bridge)

def luau_literal(s):
    for n in range(2,12):
        eq="="*n
        if ("]"+eq+"]") not in s:
            return "["+eq+"["+s+"]"+eq+"]"
    raise ValueError("Cannot quote Luau text")

def tool(s, name, data, timeout=75):
    response=s.call(name,data,timeout=timeout)
    if response.get("isError"):
        raise RuntimeError(name+" failed: "+str(bridge.data(response))[:1700])
    return bridge.data(response)

def execute(s,studio_id,code):
    data={"studio_id":studio_id,"datamodel_type":"Edit","code":code}
    return tool(s,"execute_luau",data,timeout=75)

def server_file_paths(group):
    folder=ROOT/"src"/group
    items=[]
    for f in sorted(folder.iterdir()):
        if f.suffix not in (".lua",".luau"):continue
        name=f.name
        if name.endswith(".client.luau"):
            className="LocalScript"
            bare=name[:-len(".client.luau")]
        elif name.endswith(".server.luau"):
            className="Script"
            bare=name[:-len(".server.luau")]
        else:
            className="ModuleScript"
            bare=name.split(".")[0]
        items.append((f,bare,className))
    return items

def apply_group(s,studio_id,group):
    paths=server_file_paths(group)
    for f,bare,kind in paths:
        if group=="shared":
            parent='game:GetService("ReplicatedStorage"):WaitForChild("AlnairShared")'
        elif group=="server":
            parent='game:GetService("ServerScriptService"):WaitForChild("AlnairServer")'
        elif group=="client":
            parent='game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"):WaitForChild("AlnairClient")'
        else:raise ValueError(group)
        content=f.read_text(encoding="utf-8")
        code=f'''local parent={parent}
local target=parent:FindFirstChild({json.dumps(bare)})
if target and target.ClassName~={json.dumps(kind)} then
    error("Alnair file class conflict: "+target.ClassName)
end
if not target then
    target=Instance.new({json.dumps(kind)})
    target.Name={json.dumps(bare)}
    target.Parent=parent
end
target.Source={luau_literal(content)}
return {{path=target:GetFullName(),size=#target.Source,
    verified=target.Source=={luau_literal(content)}}}'''
        result=execute(s,studio_id,code)
        if isinstance(result,dict):
            if result.get("verified") is False:
                raise RuntimeError("Source comparison failed "+str(f))
        print("SYNC_OK",group,bare,kind,len(content.encode("utf-8")),
              str(result)[:110],flush=True)
    if group=="client":
        code='''local folder=game:GetService("StarterPlayer"):
WaitForChild("StarterPlayerScripts"):WaitForChild("AlnairClient")
local obsolete=folder:FindFirstChild("R6Motion")
if obsolete then obsolete:Destroy() end
return {removedLegacyR6Motion=true,
  r15=folder:FindFirstChild("R15Motion")~=nil}'''
        code=code.replace('game:GetService("StarterPlayer"):\nWaitForChild',
                         'game:GetService("StarterPlayer"):WaitForChild')
        print("CLEAN_CLIENT",execute(s,studio_id,code),flush=True)

def apply_settings(s,studio_id):
    code='''local w=game:GetService("Workspace")
w.StreamingEnabled=true
w.StreamingMinRadius=64
w.StreamingTargetRadius=160
w.StreamOutBehavior=Enum.StreamOutBehavior.Opportunistic
local l=game:GetService("Lighting")
l.GlobalShadows=true
l.ClockTime=16.0
l.Brightness=2.25
l.ExposureCompensation=.02
l.Ambient=Color3.fromRGB(74,82,83)
l.OutdoorAmbient=Color3.fromRGB(124,135,130)
l.ShadowSoftness=.29
pcall(function()l.LightingStyle=Enum.LightingStyle.Realistic end)
pcall(function()l.PrioritizeLightingQuality=true end)
local p=game:GetService("StarterPlayer")
p.LoadCharacterAppearance=false
pcall(function()p.CharacterRigType=Enum.HumanoidRigType.R15 end)
local names={}
local lib=game.ReplicatedStorage:FindFirstChild("AlnairWeapons")
if lib then for _,item in ipairs(lib:GetChildren())do
 table.insert(names,item.Name) end end
return {streaming=w.StreamingEnabled,target=w.StreamingTargetRadius,
  globalShadows=l.GlobalShadows,lighting=tostring(l.LightingStyle),
  arms=names,clientR15=not not p.StarterPlayerScripts.AlnairClient:FindFirstChild("R15Motion") }'''
    value=execute(s,studio_id,code)
    print("SETTINGS",str(value)[:1800],flush=True)
    result=tool(s,"save_place",{"studio_id":studio_id},timeout=80)
    print("SAVED_ORIGINAL_PLACE",str(result)[:800],flush=True)

def main():
    cli=argparse.ArgumentParser()
    cli.add_argument("--group",choices=["shared","server","client","settings"],
                     required=True)
    args=cli.parse_args()
    import subprocess
    ps=subprocess.check_output(["powershell.exe","-NoProfile","-Command",
        "(Get-Process RobloxStudioBeta -ErrorAction SilentlyContinue | Measure-Object).Count"],
        text=True).strip()
    if ps!="1":
        raise RuntimeError("Refusing: expected exactly one existing Roblox Studio, got "+ps)
    session=bridge.Session()
    try:
        studios={}
        matched=[]
        for attempt in range(18):
            studios=bridge.data(session.call("list_roblox_studios"))
            matched=[x for x in studios.get("studios",[])
                     if x.get("file")=="Alnair-NATIVE-R6-TEST.rbxl"
                     and x.get("mode")=="Edit"]
            if len(matched)==1:break
            time.sleep(.7)
        if len(matched)!=1:
            raise RuntimeError("Expected one open authorized Edit: "+str(studios))
        id=matched[0]["id"]
        print("EXISTING_STUDIO",id,args.group,flush=True)
        if args.group=="settings":
            apply_settings(session,id)
        else:
            apply_group(session,id,args.group)
    finally:
        session.close()
if __name__=="__main__":main()
