from pathlib import Path
import xml.etree.ElementTree as ET
p=Path(r"C:\Users\bartk\Desktop\Alnair\src\shared\AlnairRiggedBody.rbxmx")
root=ET.parse(p).getroot()
for a in root.iter("Item"):
 c=a.get("class")
 pr=a.find("Properties")
 if pr is None:continue
 name=pr.findtext("string[@name='Name']")
 if c=="Humanoid":
  print("HUMANOID",name)
  for tag in ["HipHeight","RigType","AutoRotate","AutomaticScalingEnabled"]:
   elems=pr.findall("./*[@name='"+tag+"']")
   print(tag,[(x.tag,x.text) for x in elems])
 if c in ("Part","MeshPart") and name in ["HumanoidRootPart","LowerTorso","UpperTorso","LeftFoot","RightFoot","LeftUpperLeg","Head"]:
  cf=pr.find("CoordinateFrame[@name='CFrame']")
  size=pr.find("Vector3[@name='Size']")
  pos=[cf.findtext(q) for q in ["X","Y","Z"]] if cf is not None else None
  scale=[size.findtext(q) for q in ["X","Y","Z"]] if size is not None else None
  print(name,"pos",pos,"size",scale,"anchored",pr.findtext("bool[@name='Anchored']"),"collide",pr.findtext("bool[@name='CanCollide']"))
