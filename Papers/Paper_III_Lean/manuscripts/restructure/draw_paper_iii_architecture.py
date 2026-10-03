"""Vector architecture figure with premise-labeled and possible-transition arrows."""
from pathlib import Path
import subprocess
from reportlab.pdfgen import canvas
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
OUT=Path(__file__).resolve().parents[1]/'standalone/figures';OUT.mkdir(exist_ok=True)
for name,file in [('DV','DejaVuSans.ttf'),('DVB','DejaVuSans-Bold.ttf')]:
    pdfmetrics.registerFont(TTFont(name,'/usr/share/fonts/truetype/dejavu/'+file))
c=canvas.Canvas(str(OUT/'paper_iii_architecture.pdf'),pagesize=(760,680))
c.setTitle('Paper III: representation, standing, and criterion revision')
def txt(x,y,s,size=12,bold=False):
    c.setFillColorRGB(.08,.13,.18);c.setFont('DVB' if bold else 'DV',size);c.drawCentredString(x,y,s)
def box(x,y,w,h,lines,color='#eef3f7'):
    c.setFillColor(color);c.setStrokeColor('#63717d');c.roundRect(x,y,w,h,6,fill=1,stroke=1)
    start=y+h/2+(len(lines)-1)*7
    for i,line in enumerate(lines):txt(x+w/2,start-i*14,line,12)
def arrow(x1,y1,x2,y2,label='',dashed=False):
    import math
    c.setStrokeColor('#475766');c.setFillColor('#475766');c.setLineWidth(1.2)
    c.setDash(4,3) if dashed else c.setDash()
    c.line(x1,y1,x2,y2);c.setDash()
    theta=math.atan2(y2-y1,x2-x1);p=c.beginPath();p.moveTo(x2,y2)
    for sign in (1,-1):p.lineTo(x2-7*math.cos(theta)+sign*3*math.sin(theta),y2-7*math.sin(theta)-sign*3*math.cos(theta))
    p.close();c.drawPath(p,fill=1,stroke=0)
    if label:txt((x1+x2)/2,(y1+y2)/2+9,label,10)
txt(380,657,'REPRESENTATION AND ADEQUACY',14,True)
box(25,567,195,62,['Problem state x','Fixed comparison domain'])
box(282,567,195,62,['Representation R(x)','Preserved distinctions'])
box(540,567,195,62,['Adequacy A(x)','Decoder only if A ≼ R'])
arrow(220,598,282,598,'R');arrow(477,598,540,598,'decoder')
txt(380,533,'CONSTITUTIVE STANDING',14,True)
for x,lines in [(25,['Charter χ','Supplied authority rules']),(210,['Roots(χ,o)','Primitive root relation']),(395,['Derived standing','Permitted delegation']),(580,['Valid closure','Settlement policy'])]:box(x,449,155,62,lines,'#eaf0e9')
arrow(180,480,210,480);arrow(365,480,395,480);arrow(550,480,580,480)
txt(380,419,'REVISION BRIDGE: POSSIBLE EPISODE TRANSITIONS',14,True)
for x,lines in [(25,['Discovery','Candidate distinction']),(210,['Proposal','May be deferred']),(395,['Valid admission','Policy and standing']),(580,['Criterion change','New governing family'])]:box(x,336,155,62,lines,'#fff3e4')
for x in (180,365,550):arrow(x,367,x+30,367,dashed=True)
box(580,251,155,56,['Reassess R','New criterion family'],'#fff3e4')
box(300,251,230,56,['Possible representation revision','Restoration needs all criteria'],'#fff3e4')
arrow(657,336,657,307,dashed=True);arrow(580,279,530,279,dashed=True)
txt(380,222,'GROUNDING INTERFACE: RULES AND UNIQUENESS ARE PREMISES',14,True)
box(25,138,280,58,['Constitutive origin','+ adopted Origin Grounding rule'],'#eef3f7')
box(25,68,280,58,['GovInd + realization','+ adopted epistemic-grounding rule'],'#eef3f7')
box(376,104,140,58,['Root membership','For obligation o'],'#eaf0e9')
box(579,104,156,58,['Principalhood','Unique root'],'#eaf0e9')
arrow(305,165,376,142);arrow(305,96,376,123);arrow(516,133,579,133,'no co-root')
txt(380,40,'Solid arrows: consequences under displayed premises. Dashed arrows: possible transitions.',11)
txt(380,20,'Neither discovery nor an informational certificate alone supplies constitutive authority.',11)
c.save()
subprocess.run(['pdftoppm','-singlefile','-scale-to','2600','-png',str(OUT/'paper_iii_architecture.pdf'),str(OUT/'paper_iii_architecture')],check=True)
