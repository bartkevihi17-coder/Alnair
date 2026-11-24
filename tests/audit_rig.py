from pathlib import Path
import xml.etree.ElementTree as ET,collections
r=Path(r"C:\Users\bartk\Desktop\Alnair")
p=r/"src/shared/AlnairRiggedBody.rbxmx"
root=ET.parse(p).getroot()
items=root.findall("Item")
print("TOP",len(items))
for item in items:
  print("CLASS",item.get("class"),"NAME",item.findtext("Properties/string[@name='Name']"))
  keys=collections.Counter(x.get("class") for x in item.iter("Item"))
  print("NODES",keys.most_common(16))
  print("ANIMATION EXAMPLES")
  for a in item.iter("Item"):
    if a.get("class") in ["Animation","AnimationConstraint","Animator","Motor6D","Humanoid"]:
      print(a.get("class"),a.findtext("Properties/string[@name='Name']"), "asset",a.findtext("Properties/Content[@name='AnimationId']/uri"),"enabled",a.findtext("Properties/bool[@name='IsPlaying']"))
      if a.get("class")=="AnimationConstraint":continue
