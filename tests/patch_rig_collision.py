from pathlib import Path
p=Path(r"C:\Users\bartk\Desktop\Alnair\src\server\RigAdapter.lua")
s=p.read_text("utf-8")
old='            instance.Anchored=false\n            instance.CanCollide=instance.Name=="HumanoidRootPart"'
new='            instance.Anchored=false\n            -- Manter a colisao original importada: so HRP em CanCollide afunda o avatar.'
assert old in s
p.write_text(s.replace(old,new,1),"utf-8",newline="\n")
print("RIG COLLISION FIX")
