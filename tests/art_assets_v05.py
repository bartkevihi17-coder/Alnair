from pathlib import Path
import xml.etree.ElementTree as ET
r=Path(__file__).resolve().parents[1]
p=r/"src/shared/AlnairArtV05.rbxmx"
root=ET.parse(p).getroot()
items=root.findall("Item")
assert len(items)==1,"Biblioteca deve ter uma unica instancia raiz"
lib=items[0]
def n(x):
 y=x.find("./Properties/string[@name='Name']")
 return y.text if y is not None else ""
assert n(lib)=="AlnairArtV05"
groups={n(g):g for g in lib.findall("Item")}
expected={"NATURE":20,"VILLAGE":18,"DUNGEON":14,"FORTRESS":7,"ITEMS":7,"ACTORS":6}
assert set(groups)==set(expected),(set(groups),set(expected))
meshes=0
names=[]
for name,count in expected.items():
 models=groups[name].findall("Item")
 assert len(models)==count,(name,len(models),count)
 for model in models:
  names.append(n(model))
  parts=model.findall(".//Item[@class='MeshPart']")
  assert parts,(name,n(model))
  for part in parts:
   mid=part.find("./Properties/Content[@name='MeshContent']/uri")
   assert mid is not None and mid.text and mid.text.startswith("rbxassetid://"),(name,n(model),"Missing MeshContent")
   meshes+=1
assert meshes>=210,meshes
actors={n(x) for x in groups["ACTORS"].findall("Item")}
assert actors=={"horse","dragon","skeleton","orc","witch","warden"},actors
assert not lib.findall(".//Item[@class='Script']") and not lib.findall(".//Item[@class='LocalScript']")
print("PASS ART: {} prefab models, {} Studio-uploaded meshparts, 6 actors, valid model hierarchy".format(sum(expected.values()),meshes))
