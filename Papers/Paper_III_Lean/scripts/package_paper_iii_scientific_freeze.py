"""Regenerate the synchronized Paper III core and structural supplement."""
from pathlib import Path
import hashlib,json,zipfile
ROOT=Path(__file__).resolve().parents[1]
def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def write_json(path,value):path.write_text(json.dumps(value,indent=2)+'\n')
def archive(path,files,extra):
 with zipfile.ZipFile(path,'w',zipfile.ZIP_DEFLATED) as z:
  for name in files:
   entry=zipfile.ZipInfo(name,(2026,10,5,0,0,0));entry.compress_type=zipfile.ZIP_DEFLATED
   z.writestr(entry,(ROOT/name).read_bytes())
  for name,data in extra.items():
   entry=zipfile.ZipInfo(name,(2026,10,5,0,0,0));entry.compress_type=zipfile.ZIP_DEFLATED
   z.writestr(entry,data)
manifest_path=ROOT/'SOURCE_MANIFEST.json'
if not manifest_path.exists(): manifest_path=ROOT/'reports/paper_iii_publication_source_manifest.json'
old=json.loads(manifest_path.read_text())
files={name:digest(ROOT/name) for name in old['files']}
source_id=hashlib.sha256(json.dumps(files,sort_keys=True,separators=(',',':')).encode()).hexdigest()
manifest={'source_id':source_id,'files':files};write_json(manifest_path,manifest)
core=ROOT/'reports/paper_iii_reproduction_scientific_freeze_20261005.zip'
archive(core,files,{'SOURCE_MANIFEST.json':json.dumps(manifest,indent=2)+'\n','README.md':(ROOT/'PaperIII/README.md').read_text()})
artifact={'source_id':source_id,'archive':core.name,'archive_sha256':digest(core),'audited_declarations':95,'claim_groups':36,'distributed_source_files':33,'status':'Synchronized occurrence-based valid-root artifact','files':files}
write_json(ROOT/'reports/paper_iii_scientific_freeze_artifact.json',artifact)
names=['manuscripts/restructure/check_paper_iii_finite.py','reports/paper_iii_finite_realization.json','manuscripts/restructure/draw_paper_iii_architecture.py','manuscripts/standalone/figures/paper_iii_architecture.pdf','manuscripts/standalone/figures/paper_iii_architecture.png','manuscripts/standalone/figures/paper_iii_architecture_alt.txt','reports/paper_iii_reproduction_scientific_freeze_20261005.zip','reports/paper_iii_scientific_freeze_artifact.json']
supp_files={n:digest(ROOT/n) for n in names}
supp=ROOT/'reports/paper_iii_structural_supplement_scientific_freeze_20261005.zip'
archive(supp,names,{'SUPPLEMENT_MANIFEST.json':json.dumps({'files':supp_files},indent=2)+'\n','README.md':'Extract reports/paper_iii_reproduction_scientific_freeze_20261005.zip into a fresh directory and follow its README. Run python3 manuscripts/restructure/check_paper_iii_finite.py from this supplement root. Clean reproduction may reuse pinned third-party dependencies; no PaperIII build outputs are reused.\n'})
write_json(ROOT/'reports/paper_iii_structural_supplement_scientific_freeze_manifest_20261005.json',{'archive':str(supp.relative_to(ROOT)),'sha256':digest(supp),'contents':supp_files,'finite_model_check':'Separate exhaustive Python realization, not a joint Lean proof'})
print(source_id)
