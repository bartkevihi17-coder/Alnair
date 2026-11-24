from pathlib import Path
from PIL import Image, ImageOps, ImageDraw
root=Path(r"C:\Users\bartk\Desktop\Alnair\tests\captures")
names=["race_human","race_witch","race_undead","race_elf","class_warrior","class_assassin","class_mage","class_fighter","class_samurai"]
w,h=400,260
sheet=Image.new("RGB",(w*3,h*3),(28,29,35))
draw=ImageDraw.Draw(sheet)
for idx,name in enumerate(names):
    p=root/(name+".jpg")
    if not p.exists(): continue
    im=Image.open(p).convert("RGB")
    im=ImageOps.fit(im,(w,h-28))
    x=(idx%3)*w
    y=(idx//3)*h
    sheet.paste(im,(x,y+28))
    draw.text((x+12,y+7),name,fill=(255,255,255))
out=root/"contact_sheet_before.jpg"
sheet.save(out,quality=83)
print(out)
