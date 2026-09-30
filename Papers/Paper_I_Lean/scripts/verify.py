#!/usr/bin/env python3
"""Build and audit the published standalone Paper I package."""
from pathlib import Path
import hashlib,json,re,subprocess
ROOT=Path(__file__).resolve().parents[1]
REPORTS=ROOT/'reports'
ALLOWED={'propext','Classical.choice','Quot.sound'}
def run(args):
    result=subprocess.run(args,cwd=ROOT,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    if result.returncode: raise RuntimeError(result.stdout)
    return result.stdout

def main():
    for rel,digest in json.loads((ROOT/'source_sha256.json').read_text()).items():
        if hashlib.sha256((ROOT/rel).read_bytes()).hexdigest()!=digest:
            raise RuntimeError('Source hash mismatch: '+rel)
    seen=set();todo=['FirstPrinciplesRevision']
    while todo:
        module=todo.pop()
        if module in seen:continue
        seen.add(module)
        if module=='Frfp' or module.startswith(('Frfp.','FRFPMerge')):
            raise RuntimeError('Unexpected main FRFP dependency: '+module)
        path=ROOT/(module.replace('.','/')+'.lean')
        if path.exists():todo.extend(re.findall(r'^import\s+(\S+)',path.read_text(),re.M))
        elif not module.startswith(('Mathlib','Lean','Std','Init')):
            raise RuntimeError('Missing local module: '+module)
    REPORTS.mkdir(exist_ok=True)
    (REPORTS/'build.log').write_text(run(['lake','build']))
    audit=run(['lake','env','lean','scripts/AuditSemanticRoles.lean'])
    (REPORTS/'semantic_axioms.log').write_text(audit)
    entries=re.findall(r"'([^']+)' (?:depends on axioms: (\[[^\]]*\])|does not depend on any axioms)",audit)
    if len(entries)!=42:raise RuntimeError(f'Expected 42 declarations; got {len(entries)}')
    for name,deps in entries:
        if set(re.findall(r'[A-Za-z_][A-Za-z0-9_.]*',deps))-ALLOWED:
            raise RuntimeError('Unexpected axioms: '+name+': '+deps)
    dependency=run(['lake','env','lean','scripts/CheckSemanticDependencies.lean'])
    (REPORTS/'semantic_dependencies.log').write_text(dependency)
    if dependency.count('SEMANTIC_DEPENDENCY_PASS')!=2:raise RuntimeError('Incomplete dependency check')
    result={'status':'PASS','toolchain':(ROOT/'lean-toolchain').read_text().strip(),
        'semantic_declarations_audited':len(entries),'semantic_dependency_roots_checked':2,
        'source_hashes_verified':True,'main_frfp_imports':False,'allowed_foundations':sorted(ALLOWED)}
    (REPORTS/'validation.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))
if __name__=='__main__':main()
