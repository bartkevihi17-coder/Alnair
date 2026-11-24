from pathlib import Path
import xml.etree.ElementTree as ET,collections
r=ET.parse(r"C:\Users\bartk\Desktop\Alnair\src\shared\AlnairArtV05.rbxmx").getroot()
def n(item):
 y=item.find("./Properties/string[@name='Name']")
 return y.text if y is not None else ''
lib=next(i for i in r.findall("Item") if n(i)=="AlnairArtV05")
act=next(i for i in lib.findall("Item") if n(i)=="ACTORS")
for actor in act.findall("Item"):
 print("\nACTOR",n(actor))
 for klass in ("Bone","Motor6D","AnimationController","Animator","MeshPart","KeyframeSequence","Attachment"):
  a=[n(x) for x in actor.iter("Item") if x.get("class")==klass]
  print(klass,len(a),a[:55])
