from pathlib import Path
import xml.etree.ElementTree as ET,collections
r=Path(r"C:\Users\bartk\Desktop\Alnair")
for p in [r/"build/Alnair-v05-asset-library.rbxlx",r/"src/shared/AlnairArtV05.rbxmx",r/"src/shared/AlnairRiggedBody.rbxmx"]:
    print("\nSOURCE",p.name,p.stat().st_size)
    root=ET.parse(p).getroot()
    cnt=collections.Counter(e.attrib.get("class") for e in root.iter("Item"))
    print("items",len(list(root.iter("Item"))),"important",[(a,cnt[a]) for a in ("MeshPart","SurfaceAppearance","Animation","AnimationController","Animator","Bone","Motor6D","KeyframeSequence","SkinningFolder")])
    mesh=list(root.iter("Item"))
    num=0;colors=collections.Counter();textures=collections.Counter();meshids=collections.Counter()
    for m in mesh:
        if m.get("class")!="MeshPart":continue
        num+=1
        pr=m.find("Properties")
        colors.update([(pr.findtext("Color3uint8[@name='Color3uint8']") or "?")])
        node=pr.find("Content[@name='TextureContent']/uri")
        textures.update([(node.text if node is not None else "none")])
        n=pr.find("Content[@name='MeshContent']/uri")
        meshids.update([(n.text if n is not None else "none")])
        if num<=3:
            print("sample",pr.findtext("string[@name='Name']"),"Texture",node.text if node is not None else "none","Color",pr.findtext("Color3uint8[@name='Color3uint8']"),"children",[(z.get("class"),z.findtext("Properties/string[@name='Name']")) for z in m.findall("Item")])
    print("COLOR DISTINCT",len(colors),colors.most_common(7))
    print("TEXTURES DISTINCT",len(textures),textures.most_common(7))
