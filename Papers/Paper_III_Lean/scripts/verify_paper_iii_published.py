"""Verify the current distributed sources, build, claim coverage and axiom audit."""
from pathlib import Path
import hashlib, json, re, subprocess
ROOT = Path(__file__).resolve().parents[1]
def main():
    mpath = ROOT/'SOURCE_MANIFEST.json'
    if not mpath.exists(): mpath=ROOT/'reports/paper_iii_publication_source_manifest.json'
    m=json.loads(mpath.read_text())
    canonical=json.dumps(m['files'],sort_keys=True,separators=(',',':')).encode()
    assert hashlib.sha256(canonical).hexdigest()==m['source_id']
    for name,h in m['files'].items(): assert hashlib.sha256((ROOT/name).read_bytes()).hexdigest()==h,name
    for p in [ROOT/'PaperIII.lean',*(ROOT/'PaperIII').glob('*.lean')]:
        code=re.sub(r'/\-.*?\-/|--[^\n]*','',p.read_text(),flags=re.S)
        assert not re.search(r'\b(sorry|admit|axiom|native_decide)\b',code),p
        assert not any(n.startswith(('Frfp','FRFPMerge','BeyondSpecification')) for n in re.findall(r'^import\s+(\S+)',code,re.M)),p
    subprocess.run(['lake','build','PaperIII'],cwd=ROOT,check=True)
    log=subprocess.check_output(['lake','env','lean','scripts/AuditPaperIII.lean'],cwd=ROOT,text=True)
    entries=re.findall(r"'([^']+)' (?:depends on axioms: (\[[^\]]*\])|does not depend on any axioms)",log)
    expected=re.findall(r'^#print axioms (\S+)',(ROOT/'scripts/AuditPaperIII.lean').read_text(),re.M)
    assert len(entries)==len(expected) and {n for n,_ in entries}==set(expected)
    for n,d in entries: assert set(re.findall(r'[A-Za-z_][A-Za-z0-9_.]*',d))<={'propext','Classical.choice','Quot.sound'},n
    claims=json.loads((ROOT/'reports/paper_iii_claim_map.json').read_text())
    for label,names in claims.items(): assert set(names)<=set(expected),label
    result={'status':'PASS','source_id':m['source_id'],'source_files':len(m['files']),'audited_declarations':len(entries),'claim_groups':len(claims),'scope':'Conditional consequences; application bridges are premises; no historical snapshot claim'}
    (ROOT/'reports/paper_iii_current_axioms.log').write_text(log)
    (ROOT/'reports/paper_iii_current_validation.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))
if __name__=='__main__': main()
