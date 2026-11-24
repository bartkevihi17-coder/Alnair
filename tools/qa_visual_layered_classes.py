"""Check 3D armor in all five classes using existing Studio official MCP.
No new Roblox Studio process, no permanent UI changes. Captures game viewport.
"""
import sys,importlib.util,time,base64,io,json
from pathlib import Path
from PIL import Image,ImageOps,ImageDraw
sys.stdout.reconfigure(encoding="utf-8",errors="replace")
root=Path(r"C:\Users\bartk\Desktop\Alnair")
spec=importlib.util.spec_from_file_location("bridge",root/"tools/roblox_studio_mcp_bridge.py")
bridge=importlib.util.module_from_spec(spec)
spec.loader.exec_module(bridge)
s=bridge.Session()
classes=[("Guerreiro","warrior"),("Assassino","assassin"),("Mago","mage"),("Lutador","fighter"),("Samurai","samurai")]
def call(name,arguments,timeout=75):
    result=s.call(name,arguments,timeout)
    if result.get("isError"):
        raise RuntimeError(name+" "+str(bridge.data(result))[:800])
    return result
def capture(sid,label):
    result=call("screen_capture",{"studio_id":sid,"capture_id":"ALNAIR_ARMOR_QA_"+label},85)
    parts=list(result.get("content",[]))
    for part in parts[:]:
        if part.get("type")=="text":
            try:
                data=json.loads(part.get("text","{}"))
                parts.extend(data.get("content",[]))
            except ValueError:pass
    raw=next((p.get("data") for p in parts if p.get("type")=="image" and p.get("data")),None)
    if not raw:raise RuntimeError("No image: "+str(result)[:300])
    return Image.open(io.BytesIO(base64.b64decode(raw))).convert("RGB")
def describe(sid):
    code="""local pl=game:GetService('Players').LocalPlayer
local result={found=false,class=nil,back=0,layers=0,jacket=nil}
for _,obj in ipairs(pl.PlayerGui:GetDescendants()) do
 if obj:IsA('Model') and obj.Name=='PreviewAvatarRobloxR15' then
  result.found=true
  for _,a in ipairs(obj:GetChildren()) do
   if a:IsA('Accessory') then
    if a.AccessoryType==Enum.AccessoryType.Back then result.back+=1 end
    if a:FindFirstChildWhichIsA('WrapLayer',true) then
     result.layers+=1
     if a.AccessoryType==Enum.AccessoryType.Jacket then result.jacket=a.Name end
    end
   end
  end
  break
 end
end
return result"""
    response=call("execute_luau",{"studio_id":sid,"datamodel_type":"Client","code":code},65)
    return bridge.data(response)
try:
    match=[]
    for _ in range(18):
        resp=bridge.data(s.call("list_roblox_studios"))
        match=[x for x in resp.get("studios",[]) if x.get("file")=="Alnair-NATIVE-R6-TEST.rbxl" and x.get("mode")=="Play"]
        if len(match)==1:break
        time.sleep(.4)
    if len(match)!=1:raise RuntimeError("No unique active Alnair Studio Play session")
    sid=match[0]["id"]
    findings=[]
    screenshots=[]
    outdir=root/"build"/"QA"/"authentic-layered-class-review"
    outdir.mkdir(parents=True,exist_ok=True)
    for label,key in classes:
        if label=="Samurai":
            call("user_mouse_input",{"studio_id":sid,"datamodel_type":"Client","actions":[
                {"action":"moveTo","x":380,"y":420},
                {"action":"scrollDown","x":380,"y":420},
                {"action":"scrollDown","x":380,"y":420},
                {"action":"wait","wait_time_ms":500}
            ]},55)
        try:
            call("user_mouse_input",{"studio_id":sid,"datamodel_type":"Client","actions":[
                {"action":"moveTo","instance_path":"LocalPlayer.PlayerGui.AlnairUI.MainMenuTextOnly.SelectionArea.ScrollingFrame.MenuOption_"+label},
                {"action":"mouseButtonClick","mouse_button":"left"},
                {"action":"wait","wait_time_ms":1600}
            ]},65)
        except Exception as e:
            print("INPUT_WARN",label,str(e)[:120],flush=True)
            continue
        info=describe(sid)
        # Roblox may still be loading a large genuine layered accessory.
        for retry in range(8):
            if isinstance(info,dict) and info.get("found") and info.get("layers")==3 and info.get("back")==5:
                break
            time.sleep(.7)
            info=describe(sid)
        im=capture(sid,key)
        im.save(outdir/(key+".jpg"),quality=79,optimize=True)
        findings.append({"class":key,"preview":info})
        screenshots.append((key,im))
        print("CLASS_CHECK",key,json.dumps(info,ensure_ascii=False)[:350],flush=True)
    panelW,panelH=260,495
    sheet=Image.new("RGB",(panelW*len(screenshots),panelH),"#141b1b")
    draw=ImageDraw.Draw(sheet)
    for i,(key,im) in enumerate(screenshots):
        x=i*panelW
        # Only the character half of the screen, to inspect actual 3D armor.
        cropped=im.crop((int(im.width*.56),int(im.height*.12),im.width,int(im.height*.95)))
        cropped.thumbnail((panelW-8,panelH-36))
        sheet.paste(cropped,(x+(panelW-cropped.width)//2,29))
        draw.text((x+8,8),key,fill="white")
    dest=outdir/"all-five-classes.jpg"
    sheet.save(dest,quality=81,optimize=True)
    report={"count":len(findings),"findings":findings,
            "status":"PASS" if len(findings)==5 and all(
                 isinstance(x["preview"],dict) and
                 x["preview"].get("layers")==3 and
                 x["preview"].get("back")==5 for x in findings
            ) else "REVIEW"}
    (outdir/"report.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf-8")
    print("CLASS_QA",report["status"],report["count"],flush=True)
    print("IMAGE_BASE64="+base64.b64encode(dest.read_bytes()).decode(),flush=True)
finally:
    s.close()
