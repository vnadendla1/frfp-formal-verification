"""Figure 2: accessible dependency overview for Section 11.1."""
from pathlib import Path
import math,subprocess
from reportlab.pdfgen import canvas
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
OUT=Path(__file__).resolve().parents[1]/'standalone/figures'
for name,file in [('DV','DejaVuSans.ttf'),('DVB','DejaVuSans-Bold.ttf')]:
    pdfmetrics.registerFont(TTFont(name,'/usr/share/fonts/truetype/dejavu/'+file))
c=canvas.Canvas(str(OUT/'paper_iii_human_authority_overview.pdf'),pagesize=(720,860),invariant=1)
c.setTitle('Conditions for Human governing authority across Papers I–III')
c.setAuthor('Vijaya K. Nadendla')
INK='#172c3c';BLUE='#eaf2f8';GREEN='#eaf3ed';GOLD='#fff3df'
def text(x,y,value,size=14,bold=False):
    c.setFillColor(INK);c.setFont('DVB' if bold else 'DV',size);c.drawCentredString(x,y,value)
def box(x,y,w,h,title,lines,color=BLUE):
    c.setFillColor(color);c.setStrokeColor('#718391');c.setLineWidth(.9)
    c.roundRect(x,y,w,h,7,fill=1,stroke=1)
    top=y+h-23
    assert pdfmetrics.stringWidth(title,'DVB',14) <= w-16, title
    assert top-21-18*(len(lines)-1) >= y+8, title
    for line in lines: assert pdfmetrics.stringWidth(line,'DV',13.5) <= w-16, line
    text(x+w/2,top,title,14,True)
    for i,line in enumerate(lines):text(x+w/2,top-21-18*i,line,13.5)
def arrow(x1,y1,x2,y2,dashed=False):
    c.setStrokeColor('#435d71');c.setFillColor('#435d71');c.setLineWidth(1.5)
    c.setDash(4,3) if dashed else c.setDash();c.line(x1,y1,x2,y2);c.setDash()
    theta=math.atan2(y2-y1,x2-x1);p=c.beginPath();p.moveTo(x2,y2)
    for sign in (1,-1):p.lineTo(x2-8*math.cos(theta)+sign*3.5*math.sin(theta),y2-8*math.sin(theta)-sign*3.5*math.cos(theta))
    p.close();c.drawPath(p,fill=1,stroke=0)
text(360,837,'CONDITIONS FOR HUMAN GOVERNING AUTHORITY',17,True)
box(20,749,680,70,'Paper I identifies the authorization responsibility',[
    'Assessment and authorization are distinct under the specified contract conditions.',
    'This does not derive completion, valid-root grounding, or root identity.'])
text(360,735,'Fix the obligation and charter; identify the required authorization condition D.',13)
box(20,664,680,54,'Paper III defines a valid root',[
    'Nominal underived charter standing + competence to bear the contract (CanBear).'],GREEN)
text(181,646,'EXISTENCE',15,True);text(539,646,'MACHINE EXCLUSION',15,True)
box(20,540,322,90,'An actual valid decision',[
    'Valid governance has been realized.',
    'Completion extracts an actual',
    'authorization or closure occurrence.'],GREEN)
box(378,515,322,115,'Paper II: representation bridge',[
    'D is not represented by the basis.',
    'Spectral/modal discharge or full',
    'recovery establishes this premise.',
    'This does not establish confinement.'])
box(20,429,322,92,'Valid-root provenance',[
    'Valid occurrence standing traces through',
    'a permitted delegation path to a valid root.',
    'A rootless delegation cycle is insufficient.'],GREEN)
box(378,375,322,110,'Paper III: application premises',[
    'Faithful bearing must preserve D in',
    'the root’s independent information basis.',
    'Machine confinement is independently',
    'established for eligible candidates.'])
box(20,338,322,63,'Valid authority exists',[
    'At least one valid root (Theorem 9).'],GREEN)
box(378,298,322,63,'No Machine valid roots',[
    'Preservation is impossible (Theorem 10).'])
arrow(181,540,181,521);arrow(181,429,181,401)
arrow(539,515,539,485);arrow(539,375,539,361)
# The result takes both conclusions plus a separately supplied category premise.
arrow(181,338,181,278);arrow(539,298,539,278)
c.setFillColor('#dceee3');c.setStrokeColor('#50765f');c.roundRect(20,149,680,129,8,fill=1,stroke=1)
text(360,254,'Combine both branches with exhaustive classification:',14,True)
text(360,233,'Every eligible participant is Human or Machine.',14)
c.setStrokeColor('#90b69c');c.line(45,220,675,220)
text(360,197,'VALID AUTHORITY EXISTS',17,True)
text(360,175,'AND EVERY VALID ROOT IS HUMAN',17,True)
text(360,131,'Conditional Human Authority Theorem (Theorem 11).',13)
box(20,43,680,70,'Additional evidence for plural Human authority',[
    'At least two distinct valid roots must exist.',
    'One collective participant can be one root; institutional bearers need a charter mapping.'],GOLD)
text(360,28,'A Machine may execute a supplied Human decision without becoming a valid root.',12)
text(360,10,'Nominal Machine roots remain possible.',11.5)
c.save()
alt=('Overview of Section 11.1. Paper I identifies a separate authorization responsibility under its contract conditions; '
     'it does not derive completion or root identity. Machine confinement is an independently established Paper III application premise, not a result of Paper II. Paper III defines a valid root as nominal charter standing plus CanBear. '
     'The existence branch uses an actual authorization or closure occurrence, extracted by Completion, and valid-root-grounded '
     'permitted delegation to prove at least one valid root. The exclusion branch uses Paper II applicable spectral/modal nonrepresentation conditions, an independently '
     'selected Tacit authorization condition and a qualifying complete Machine basis, together with faithful bearing and independent '
     'Machine basis confinement, to exclude Machine valid roots. Combining both branches with an independently justified exhaustive '
     'Human/Machine interpretation gives nonempty valid Human authority. At least two distinct valid roots are additional evidence '
     'for plural authority. A collective may be one root, and institutional sources require a bearer mapping. '
     'Machines may execute supplied Human decisions without becoming valid roots; nominal Machine designation remains possible. '
)
(OUT/'paper_iii_human_authority_overview_alt.txt').write_text(alt+'\n')
subprocess.run(['pdftoppm','-singlefile','-scale-to','2000','-png',str(OUT/'paper_iii_human_authority_overview.pdf'),str(OUT/'paper_iii_human_authority_overview')],check=True)
