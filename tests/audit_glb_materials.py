from pathlib import Path
import trimesh,collections,numpy as np,json
r=Path(r"C:\Users\bartk\Desktop\Alnair\assets\vendor\ArtV05")
for p in [r/"BUNDLES/NATURE.glb",r/"BUNDLES/VILLAGE.glb",r/"BUNDLES/DUNGEON.glb",r/"BUNDLES/ITEMS.glb",r/"BUNDLES/ACTORS.glb",r/"nature_pack/BirchTree_1.glb",r/"rpg_items_pack/Armor_Metal.glb"]:
  s=trimesh.load(str(p),force="scene",process=False)
  print("\nFILE",p.name,"geometry",len(s.geometry),"nodes",len(s.graph.nodes_geometry))
  for name,m in list(s.geometry.items())[:12]:
    v=m.visual
    mat=getattr(v,'material',None)
    fields={x:getattr(mat,x,None) for x in ['name','baseColorFactor','main_color','diffuse','image'] if mat is not None}
    fields['image']=type(fields.get('image')).__name__
    if isinstance(fields.get("baseColorFactor"),np.ndarray):fields['baseColorFactor']=fields['baseColorFactor'].tolist()
    if isinstance(fields.get("main_color"),np.ndarray):fields['main_color']=fields['main_color'].tolist()
    if isinstance(fields.get("diffuse"),np.ndarray):fields['diffuse']=fields['diffuse'].tolist()
    verts=getattr(v,"vertex_colors",None)
    if verts is not None:fields["vertex_colors_sample"]=np.asarray(verts)[:2].tolist()
    print(name,"v",v.kind,"mat",fields)
