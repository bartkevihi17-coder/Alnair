import xml.etree.ElementTree as E
r=E.parse(r"C:\Users\bartk\Desktop\Alnair\src\shared\AlnairArtV05.rbxmx").getroot()
lib=next(x for x in r.findall("Item") if x.get("class")=="Folder")
actors=next(x for x in lib.findall("Item") if x.findtext("./Properties/string[@name='Name']")=="ACTORS")
for m in actors.findall("Item"):
    name=m.findtext("./Properties/string[@name='Name']")
    b=[x.findtext("./Properties/string[@name='Name']") for x in m.iter("Item") if x.get("class")=="Bone"]
    motors=[x.findtext("./Properties/string[@name='Name']") for x in m.iter("Item") if x.get("class")=="Motor6D"]
    print(name,"bones",len(b),b[:90],"motors",motors[:25])
