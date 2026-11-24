from pathlib import Path
import trimesh,xml.etree.ElementTree as ET
p=Path(r"C:\Users\bartk\Desktop\Alnair\assets\vendor\ArtV05")
for ff in ["nature_pack/BirchTree_1.glb","nature_pack/CommonTree_1.glb","medieval_village_pack/House_1.glb","modular_dungeon_pack/Column.glb","animals_pack/Horse.glb"]:
    s=trimesh.load(str(p/ff),force="scene",process=False)
    print("FILE",ff,"pieces",len(s.geometry))
    for n,m in list(s.geometry.items())[:12]:
        vis=m.visual
        mat=getattr(vis,"material",None)
        print(" --",n,"visual",type(vis).__name__,"material",type(mat).__name__,"main",(getattr(mat,"main_color",None)).tolist() if getattr(mat,"main_color",None) is not None else None,"base",(getattr(mat,"baseColorFactor",None)).tolist() if hasattr(getattr(mat,"baseColorFactor",None),"tolist") else getattr(mat,"baseColorFactor",None),"vertexClr",getattr(vis,"vertex_colors",None).shape if vis.kind in ('vertex',) else None)
rig=ET.parse(r"C:\Users\bartk\Desktop\Alnair\src\shared\AlnairRiggedBody.rbxmx").getroot()
m=next(x for x in rig.findall("Item") if x.get("class")=="Model")
print("RIG names",[(x.get("class"),x.findtext("./Properties/string[@name='Name']")) for x in m.findall("Item")])
for x in m.findall("Item"):
    if x.get("class")!="MeshPart":continue
    props=x.find("Properties")
    name=props.findtext("string[@name='Name']")
    cf=props.find("CoordinateFrame[@name='CFrame']")
    size=props.find("Vector3[@name='size']")
    if size is None: size=props.find("Vector3[@name='Size']")
    kids={y.get("class") for y in x.findall("Item")}
    print("PART",name,"xyz",tuple(round(float(cf.findtext(a)),2) for a in ("X","Y","Z")) if cf is not None else None,"size",tuple(round(float(size.findtext(a)),2) for a in ("X","Y","Z")) if size is not None else None,"kids",kids)
