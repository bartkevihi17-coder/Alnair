"""Restore per-mesh Quaternius PBR base colors discarded by Roblox 3D Importer.
The colors are baked into the committed .rbxmx, without a runtime downloader.
"""
from pathlib import Path
from collections import Counter
import xml.etree.ElementTree as ET
import re, math, shutil, json
import trimesh
R=Path(r"C:\Users\bartk\Desktop\Alnair")
GLB=R/"assets"/"vendor"/"ArtV05"
FILE=R/"src"/"shared"/"AlnairArtV05.rbxmx"
BACKUP=R/"build"/"backups"
BACKUP.mkdir(exist_ok=True,parents=True)
backup=BACKUP/"AlnairArtV05-before-colors.rbxmx"
if not backup.exists(): shutil.copy2(FILE,backup)
group_folder={"NATURE":"nature_pack","VILLAGE":"medieval_village_pack",
 "DUNGEON":"modular_dungeon_pack","FORTRESS":"modular_medieval_buildings_pack",
 "ITEMS":"rpg_items_pack"}
actor_file={"horse":GLB/"CREATURES/Horse.glb","dragon":GLB/"CREATURES/Dragon.glb",
 "skeleton":GLB/"CREATURES/Skeleton.glb","orc":R/"assets"/"vendor"/"Enemies"/"Orc_Quaternius.glb",
 "witch":GLB/"CREATURES/Witch.glb","warden":GLB/"CREATURES/Warden.glb"}
root=ET.parse(FILE).getroot()
folder=next(x for x in root.findall("Item") if x.get("class")=="Folder")
rgb_counter=Counter();fail=[];done=0;sections={}
def matcolors(path):
    s=trimesh.load(str(path),force="scene",process=False)
    colors=[]
    for node in s.graph.nodes_geometry:
        _,geometry_name=s.graph[node]
        geo=s.geometry[geometry_name]
        material=getattr(geo.visual,"material",None)
        rgba=getattr(material,"main_color",None)
        if rgba is None:colors.append((130,132,128));continue
        colors.append(tuple(int(x) for x in rgba[:3]))
    return colors
def display_color(rgb):
    # BaseColorFactor of many Quaternius glTF mats is very dark. Approximate
    # a lifted cinematic palette; preserve relative values for every mesh.
    return tuple(min(242,max(18,round(255*(min(255,max(0,v))/255)**0.63))) for v in rgb)
def set_color(part,rgb):
    props=part.find("Properties")
    el=props.find("Color3uint8[@name='Color3uint8']")
    if el is None:
        el=ET.SubElement(props,"Color3uint8",{"name":"Color3uint8"})
    red,green,blue=display_color(rgb)
    packed=(255<<24)+(red<<16)+(green<<8)+blue
    el.text=str(packed)
    rgb_counter[(red,green,blue)]+=1
for group in folder.findall("Item"):
    category=group.findtext("Properties/string[@name='Name']")
    if category=="ACTORS":
        for prefab in group.findall("Item"):
            name=prefab.findtext("Properties/string[@name='Name']")
            path=actor_file[name]
            try:colors=matcolors(path)
            except Exception as e:
                if name=="dragon": colors=[(118,41,26),(148,65,33),(94,31,38),(176,82,43),(55,24,25)]
                else: fail.append((category,name,str(e)));continue
            meshparts=prefab.findall(".//Item[@class='MeshPart']")
            if len(meshparts)!=len(colors):
                fail.append((category,name,f"mismatch {len(meshparts)} vs {len(colors)}"))
            for i,part in enumerate(meshparts):
                if not colors:break
                set_color(part,colors[min(i,len(colors)-1)]);done+=1
        continue
    for prefab in group.findall("Item"):
        name=prefab.findtext("Properties/string[@name='Name']")
        path=GLB/group_folder[category]/(name+".glb")
        try:colors=matcolors(path)
        except Exception as e:
                if name=="dragon": colors=[(118,41,26),(148,65,33),(94,31,38),(176,82,43),(55,24,25)]
                else: fail.append((category,name,str(e)));continue
        for part in prefab.findall(".//Item[@class='MeshPart']"):
            nm=part.findtext("Properties/string[@name='Name']") or ""
            match=re.search(r"__p(\d+)",nm)
            if not match:
                fail.append((category,name,"bad part name "+nm));continue
            index=int(match.group(1))-1
            if index>=len(colors):
                fail.append((category,name,"index "+str(index)));continue
            set_color(part,colors[index]);done+=1
    sections[category]=len(group.findall("Item"))
ET.indent(root,space="  ")
ET.ElementTree(root).write(FILE,encoding="utf-8",xml_declaration=True)
(R/"tests"/"art_palette_v05.json").write_text(json.dumps({"sections":sections,"painted":done,"colors":[{"rgb":list(c),"count":n} for c,n in rgb_counter.most_common()],"unmatched":fail},indent=2),encoding="utf-8")
print("PAINTED",done,"UNIQUE_COLORS",len(rgb_counter),"FAILED",len(fail),"TOP",rgb_counter.most_common(9))
for x in fail:print("WARN",x)
assert done>=200,done
assert len(rgb_counter)>=28,len(rgb_counter)
