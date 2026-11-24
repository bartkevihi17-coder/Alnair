from pathlib import Path
from PIL import Image,ImageOps,ImageDraw
root=Path(r"C:\Users\bartk\Desktop\Alnair\tests\captures")
names=["qa_race_human_2106","qa_race_witch_2106","qa_race_undead_2106","qa_race_elf_2106","qa_class_warrior_2107","qa_class_assassin_2107","qa_class_mage_2107","qa_class_fighter_2107","qa_class_samurai_2107"]
w,h=310,345
out=Image.new("RGB",(3*w,3*h),(26,28,34))
d=ImageDraw.Draw(out)
for i,name in enumerate(names):
    p=root/(name+".jpg")
    if not p.exists():
        print("MISSING",p)
        continue
    im=Image.open(p).convert("RGB")
    im=im.crop((430,322,650,528)).resize((w,h-28),Image.Resampling.LANCZOS)
    x=i%3*w
    y=i//3*h
    out.paste(im,(x,y+28))
    d.text((x+10,y+7),name,fill="white")
p=root/"qa_contact_2107.jpg"
out.save(p,quality=86)
print(p)
