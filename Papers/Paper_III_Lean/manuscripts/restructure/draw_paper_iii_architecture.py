"""Vector diagram of nominal/valid roots, occurrence provenance, and revision."""
from pathlib import Path
import subprocess, math
from reportlab.pdfgen import canvas
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
OUT=Path(__file__).resolve().parents[1]/'standalone/figures';OUT.mkdir(exist_ok=True)
for name,file in [('DV','DejaVuSans.ttf'),('DVB','DejaVuSans-Bold.ttf')]:
    pdfmetrics.registerFont(TTFont(name,'/usr/share/fonts/truetype/dejavu/'+file))
c=canvas.Canvas(str(OUT/'paper_iii_architecture.pdf'),pagesize=(760,770),invariant=1)
c.setTitle('Paper III: nominal roots, valid roots, and occurrence provenance')
def txt(x,y,s,size=11,bold=False):
    c.setFillColorRGB(.08,.13,.18);c.setFont('DVB' if bold else 'DV',size);c.drawCentredString(x,y,s)
def box(x,y,w,h,lines,color='#eef3f7'):
    c.setFillColor(color);c.setStrokeColor('#63717d');c.roundRect(x,y,w,h,6,fill=1,stroke=1)
    start=y+h/2+(len(lines)-1)*7
    for i,line in enumerate(lines):txt(x+w/2,start-i*14,line)
def arrow(x1,y1,x2,y2,label='',dashed=False):
    c.setStrokeColor('#475766');c.setFillColor('#475766');c.setLineWidth(1.2)
    c.setDash(4,3) if dashed else c.setDash();c.line(x1,y1,x2,y2);c.setDash()
    theta=math.atan2(y2-y1,x2-x1);p=c.beginPath();p.moveTo(x2,y2)
    for sign in (1,-1):p.lineTo(x2-7*math.cos(theta)+sign*3*math.sin(theta),y2-7*math.sin(theta)-sign*3*math.cos(theta))
    p.close();c.drawPath(p,fill=1,stroke=0)
    if label:txt((x1+x2)/2,(y1+y2)/2+9,label,9)
txt(380,747,'REPRESENTATION AND ADEQUACY',14,True)
box(25,661,195,62,['Problem state x','Fixed comparison domain'])
box(282,661,195,62,['Representation R(x)','Preserved distinctions'])
box(540,661,195,62,['Adequacy A(x)','Decoder only if A ≼ R'])
arrow(220,692,282,692,'R');arrow(477,692,540,692,'decoder')
txt(380,625,'VALID AUTHORITY AND ACTUAL OCCURRENCE PROVENANCE',14,True)
box(25,541,200,60,['Nominal charter root','Roots(χ,o) membership'],'#eaf0e9')
box(25,460,200,60,['Contract competence','CanBear(a,o)'],'#eaf0e9')
box(300,505,180,62,['Valid root','Nominal root + CanBear'],'#eaf0e9')
arrow(225,566,300,547);arrow(225,490,300,523)
txt(259,537,'both',9)
box(555,505,180,62,['Permitted delegation','Supplied root decision'],'#eaf0e9')
arrow(480,536,555,536)
box(555,397,180,62,['Actual valid occurrence','Authorization or closure'],'#eaf0e9')
arrow(645,505,645,459,'valid standing')
box(300,397,180,62,['Machine may execute','without valid-root status'],'#fff3e4')
arrow(555,429,480,429)
box(25,359,200,62,['Optional principalhood','Nominal singleton root'],'#eef3f7')
# Mask the vertical principal route behind the competence box and annotate it at the side.
c.setFillColorRGB(1,1,1);c.rect(2,428,22,101,fill=1,stroke=0)
# A separate routed arrow avoids passing through competence.
c.setStrokeColor('#475766');c.line(25,571,12,571);c.line(12,571,12,390);arrow(12,390,25,390)
txt(123,342,'Requires no distinct nominal co-root',9)
txt(380,311,'REVISION: POSSIBLE EPISODE TRANSITIONS',14,True)
for x,lines in [(25,['Discovery','Candidate distinction']),(210,['Proposal','May be deferred']),(395,['Valid admission','Policy and standing']),(580,['Criterion change','New governing family'])]:box(x,228,155,62,lines,'#fff3e4')
for x in (180,365,550):arrow(x,259,x+30,259,dashed=True)
box(580,147,155,56,['Reassess R','New criterion family'],'#fff3e4')
box(285,147,245,56,['Possible representation revision','Restoration needs all criteria'],'#fff3e4')
arrow(657,228,657,203,dashed=True);arrow(580,175,530,175,dashed=True)
txt(380,110,'Origin / GovInd + realization + an adopted rule can supply nominal membership.',11)
txt(380,85,'Solid arrows show defined dependencies or permitted provenance; occurrence validity is supplied.',10)
txt(380,64,'Dashed arrows show possible transitions. Nominal Machine designation remains possible.',10)
txt(380,43,'Completion extracts an actual valid occurrence; it does not prove liveness for pending obligations.',10)
c.save()
subprocess.run(['pdftoppm','-singlefile','-scale-to','2200','-png',str(OUT/'paper_iii_architecture.pdf'),str(OUT/'paper_iii_architecture')],check=True)
