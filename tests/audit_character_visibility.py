from pathlib import Path
import xml.etree.ElementTree as ET
p=Path(r"C:\Users\bartk\Desktop\Alnair\src\shared\AlnairRiggedBody.rbxmx")
root=ET.parse(p).getroot()
for item in root.iter("Item"):
 if item.get("class")!="MeshPart":continue
 prop=item.find("Properties")
 name=prop.findtext("string[@name='Name']")
 print(name,"transp",prop.findtext("float[@name='Transparency']"),"RootPriority",prop.findtext("int[@name='RootPriority']"),"RenderFidelity",prop.findtext("token[@name='RenderFidelity']"),"CanCollide",prop.findtext("bool[@name='CanCollide']"),"Locked",prop.findtext("bool[@name='Locked']"))
