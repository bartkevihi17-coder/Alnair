from pathlib import Path
import xml.etree.ElementTree as ET
p=Path(r"C:\Users\bartk\Desktop\Alnair\src\shared\AlnairRiggedBody.rbxmx")
root=ET.parse(p).getroot()
parents={}
refs={}
for item in root.iter("Item"):
    if item.get("referent"):refs[item.get("referent")]=item
    for child in item.findall("Item"):parents[id(child)]=item
def n(x):
 if x is None:return "-"
 z=x.find("./Properties/string[@name='Name']")
 return z.text if z is not None else "?"
for child in root.iter("Item"):
 if child.get("class")=="AnimationConstraint":
    p=child.find("Properties")
    a=refs.get(p.findtext("Ref[@name='Attachment0']"))
    b=refs.get(p.findtext("Ref[@name='Attachment1']"))
    print(n(child),"from",n(parents.get(id(a))),n(a),"to",n(parents.get(id(b))),n(b))
