from pathlib import Path
import xml.etree.ElementTree as ET
import trimesh
from collections import Counter
import shutil,hashlib
ROOT=Path(r"C:\Users\bartk\Desktop\Alnair")
library=ROOT/"src/shared/AlnairArtV05.rbxmx"
backup=ROOT/"build/AlnairArtV05-pre-material-fix.rbxmx"
if not backup.exists():shutil.copy2(library,backup)
def name(el):
    p=el.find("./Properties/string[@name='Name']")
    return p.text if p is not None else ""
def rgb_from_linear(arr):
    if arr is None:return None
    if len(arr)<3:return None
    vals=[]
    for channel in arr[:3]:
        n=max(0,min(1,float(channel)/255))
        vals.append(round(min(255,255*(n**(1.0/2.2)))))
    return tuple(vals)
def argb(rgb):
    r,g,b=rgb
    return str((255<<24)|(r<<16)|(g<<8)|b)
root=ET.parse(library)
lib=next(x for x in root.getroot().findall("Item") if name(x)=="AlnairArtV05")
models=Counter()
colors=Counter()
miss=[]
for category in lib.findall("Item"):
    c=name(category)
    target=ROOT/("assets/vendor/ArtV05/BUNDLES/"+c+".glb")
    geo={}
    if target.exists():
        scene=trimesh.load(str(target),force="scene",process=False)
        for key,mesh in scene.geometry.items():
            material=getattr(mesh.visual,"material",None)
            v=rgb_from_linear(getattr(material,"main_color",None)) if material else None
            geo[key]=v
    for model in category.findall("Item"):
        mname=name(model)
        meshes=model.findall(".//Item[@class='MeshPart']")
        for i,mesh in enumerate(meshes):
            nm=name(mesh)
            rgb=geo.get(nm)
            if not rgb and c=="ACTORS":
                palette={
                    "orc":[(87,133,91),(54,69,49)],
                    "skeleton":[(209,207,173),(174,154,115)],
                    "witch":[(88,63,122),(162,133,182),(55,42,77)],
                    "warden":[(88,108,129),(51,73,89)],
                    "horse":[(159,113,68),(106,75,53),(64,51,48),(199,167,118)],
                    "dragon":[(161,68,59),(112,55,69),(85,35,55),(221,156,99)],
                }
                pal=palette.get(mname,[(163,143,121)])
                rgb=pal[i%len(pal)]
            if not rgb:
                miss.append((c,mname,nm))
                continue
            props=mesh.find("Properties")
            obj=props.find("./Color3uint8[@name='Color3uint8']")
            if obj is None:
                obj=ET.SubElement(props,"Color3uint8",{"name":"Color3uint8"})
            obj.text=argb(rgb)
            # Ensure PBR output isn't multiplied by an arbitrary grey tint.
            colors[rgb]+=1; models[c]+=1
treepath=library.with_suffix(".rbxmx.tmp")
root.write(treepath,encoding="utf-8",xml_declaration=True)
ET.parse(treepath)
treepath.replace(library)
print("MATERIAL_FIX",dict(models),"MESHES",sum(models.values()),"UNIQUE_PALETTE",len(colors),"NO_COLOR",miss[:12],"FILE_MB",round(library.stat().st_size/1e6,2))
print("PALETTE",colors.most_common(14))
