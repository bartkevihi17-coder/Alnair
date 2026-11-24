"""Read-only capture of the EXISTING Roblox Studio's game viewport via official MCP.
Never opens Roblox Studio or changes focus. Emits compressed image as base64.
"""
import sys,importlib.util,base64,io,time,os,json
from pathlib import Path
from PIL import Image
sys.stdout.reconfigure(encoding="utf-8",errors="replace")
root=Path(r"C:\Users\bartk\Desktop\Alnair")
spec=importlib.util.spec_from_file_location("bridge",root/"tools/roblox_studio_mcp_bridge.py")
mod=importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)
s=mod.Session()
try:
    current={}
    matches=[]
    for i in range(18):
        current=mod.data(s.call("list_roblox_studios"))
        matches=[x for x in current.get("studios",[]) if x.get("file")=="Alnair-NATIVE-R6-TEST.rbxl"]
        if len(matches)==1:break
        time.sleep(.45)
    if len(matches)!=1:
        raise RuntimeError("Alnair original Studio unavailable: "+str(current)[:350])
    result=s.call("screen_capture",{"studio_id":matches[0]["id"],"capture_id":"ALNAIR_ARMOR_3D_LIVE_QA"},timeout=70)
    contents=list(result.get("content",[]))
    for item in contents[:]:
        if item.get("type")=="text":
            try:
                doc=json.loads(item.get("text","{}"))
                contents.extend(doc.get("content",[]))
            except ValueError:
                pass
    data=next((x.get("data") for x in contents if x.get("type")=="image" and x.get("data")),None)
    if data is None:raise RuntimeError("No image in screen capture: "+str(result)[:500])
    im=Image.open(io.BytesIO(base64.b64decode(data))).convert("RGB")
    size=im.size
    im.thumbnail((1140,850))
    q=io.BytesIO()
    im.save(q,format="JPEG",quality=79,optimize=True)
    out=root/"build/staging/alnair-3d-armor-official-capture.jpg"
    out.parent.mkdir(parents=True,exist_ok=True)
    out.write_bytes(q.getvalue())
    print("CAPTURE_SIZE="+str(size[0])+"x"+str(size[1]),flush=True)
    print("THUMBNAIL_BYTES="+str(len(q.getvalue())),flush=True)
    print("IMAGE_BASE64="+base64.b64encode(q.getvalue()).decode("ascii"),flush=True)
finally:
    s.close()
