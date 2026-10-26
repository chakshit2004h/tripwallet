"""Render store artwork from the existing launcher vector shapes and brand fonts."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
ROOT = Path(__file__).resolve().parent
CLIENT = ROOT.parent
OUT = ROOT / "graphics"
OUT.mkdir(exist_ok=True)
# Same vector geometry as tool/generate_launcher_icon.py; no launcher files changed.
icon = Image.new("RGB", (1024, 1024), "#0F1B2C")
d = ImageDraw.Draw(icon)
d.rounded_rectangle((150,265,874,795),130,fill="#FF6B4A")
d.rounded_rectangle((150,245,735,670),110,fill="#F4EFE4")
d.rounded_rectangle((150,335,874,795),115,fill="#FF6B4A")
d.rounded_rectangle((552,454,916,647),80,fill="#0F1B2C")
d.arc((252,449,614,681),207,333,fill="#F4EFE4",width=36)
d.ellipse((277,584,333,640),fill="#F4EFE4")
d.ellipse((667,527,735,595),fill="#F4EFE4")
icon.resize((512,512),Image.Resampling.LANCZOS).save(OUT / "app-icon-512.png",optimize=True)
S=2
im=Image.new("RGB",(1024*S,500*S),"#123D38")
d=ImageDraw.Draw(im)
def font(size, family="SpaceGrotesk"):
 f = ImageFont.truetype(str(CLIENT / "assets/fonts" / (family+".ttf")),size*S)
 if family == "SpaceGrotesk":
  f.set_variation_by_axes([700])
 return f
def text(x,y,value,size,color="#F4EFE4",family="SpaceGrotesk"):
 d.text((x*S,y*S),value,font=font(size,family),fill=color)
def box(coords,color,r=0):
 d.rounded_rectangle(tuple(int(v*S) for v in coords),r*S,fill=color)
d.ellipse((660*S,-130*S,1160*S,370*S),fill="#1C5148")
d.ellipse((780*S,250*S,1110*S,580*S),outline="#326759",width=2*S)
text(44,36,"TripWallet",48,"#D2EF8B")
text(40,129,"Great trips.",84)
text(40,224,"Clear splits.",84)
text(46,365,"Split expenses.",30,"#DCE8DF","Inter")
text(46,407,"Enjoy the journey.",30,"#DCE8DF","Inter")
# A large illustrative shared-expense card, not an app screenshot.
box((669,78,994,442),"#092C27",28)
box((655,64,980,428),"#F4EFE4",28)
text(683,95,"TRIP EXPENSES",23,"#43665A")
text(680,148,"Split together.",33,"#123D38")
text(680,194,"Travel lighter.",33,"#123D38")
d.line((682*S,257*S,951*S,257*S),fill="#CDD5C6",width=2*S)
for i,(letter,c) in enumerate([("A","#D2EF8B"),("M","#FFB199"),("K","#D4DFEF")]):
 x=683+i*88
 box((x,283,x+70,353),c,35)
 text(x+22,295,letter,31,"#123D38")
text(682,375,"One shared view.",27,"#43665A")
im.resize((1024,500),Image.Resampling.LANCZOS).save(OUT / "feature-graphic-1024x500.png",optimize=True)
im.save(OUT / "feature-graphic-preview-2048x1000.png",optimize=True)
for path in OUT.glob("*.png"):
 with Image.open(path) as image:
  print(path.name,image.size,image.mode,path.stat().st_size,"bytes")
