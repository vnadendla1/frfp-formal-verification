#!/usr/bin/env python3
"""Reproduce Paper III build, input provenance, claim coverage and axiom audit."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[1]
REPORTS = ROOT / 'reports'
ALLOWED = {'propext', 'Classical.choice', 'Quot.sound'}
LAKE = shutil.which('lake') or str(Path.home() / '.elan/bin/lake')

def run(args):
    p = subprocess.run([LAKE, *args], cwd=ROOT, text=True,
                       stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if p.returncode:
        raise RuntimeError(p.stdout)
    return p.stdout

def code(text):
    return re.sub(r'/\-.*?\-/|--[^\n]*', '', text, flags=re.S)

def main():
    manifest = json.loads((REPORTS / 'paper_iii_source_manifest.json').read_text())
    for entry in manifest['inputs']:
        if hashlib.sha256(Path(entry['path']).read_bytes()).hexdigest() != entry['sha256']:
            raise RuntimeError('Changed reviewed input: ' + entry['path'])
    snapshot = ROOT / 'papers/PaperIII/Paper_III_Human_Principalhood_Draft.pdf'
    assert hashlib.sha256(snapshot.read_bytes()).hexdigest() == manifest['inputs'][0]['sha256']
    pending, seen = ['PaperIII'], set()
    while pending:
        module = pending.pop()
        if module in seen:
            continue
        seen.add(module)
        if module == 'Frfp' or module.startswith(('Frfp.', 'FRFPMerge', 'BeyondSpecification')):
            raise RuntimeError('Forbidden dependency: ' + module)
        path = ROOT / (module.replace('.', '/') + '.lean')
        if path.exists():
            clean = code(path.read_text())
            if re.search(r'\b(sorry|admit|axiom)\b', clean):
                raise RuntimeError('Placeholder or global axiom: ' + str(path))
            pending.extend(re.findall(r'^import\s+(\S+)', clean, re.M))
    names = []
    for path in sorted((ROOT / 'PaperIII').glob('*.lean')):
        stack = []
        for line in code(path.read_text()).splitlines():
            m = re.match(r'^namespace (\S+)', line)
            if m:
                stack.append(m.group(1))
            elif re.match(r'^end(?: |$)', line):
                if stack:
                    stack.pop()
            else:
                m = re.match(r'^theorem (\S+)', line)
                if m:
                    names.append('.'.join(stack + [m.group(1)]))
    names += ['AlgebraOfHumanAiCollaboration.factorsThrough_iff_kernelIncluded']
    claims = json.loads((REPORTS / 'paper_iii_claim_map.json').read_text())
    for label, required in claims.items():
        if set(required) - set(names):
            raise RuntimeError('Uncovered claim: ' + label)
    (REPORTS / 'paper_iii_build.log').write_text(run(['build', 'PaperIII']))
    audit = ROOT / 'scripts/AuditPaperIII.lean'
    audit.write_text('import PaperIII\n\n' + ''.join('#print axioms ' + n + '\n' for n in names))
    output = run(['env', 'lean', str(audit)])
    (REPORTS / 'paper_iii_axioms.log').write_text(output)
    entries = re.findall(r"'([^']+)' (?:depends on axioms: (\[[^\]]*\])|does not depend on any axioms)", output)
    if set(n for n, _ in entries) != set(names) or len(entries) != len(names):
        raise RuntimeError('Audit inventory mismatch')
    for name, deps in entries:
        if set(re.findall(r'[A-Za-z_][A-Za-z0-9_.]*', deps)) - ALLOWED:
            raise RuntimeError('Unexpected axiom dependency: ' + name + ': ' + deps)
    result = {'status': 'PASS', 'toolchain': run(['env', 'lean', '--version']).strip(),
              'audited_declarations': len(entries), 'paper_iii_theorems': len(names)-1,
              'reused_factorization_theorems': 1, 'mapped_claim_groups': len(claims),
              'main_frfp_imports': False, 'project_axioms': False,
              'allowed_foundations': sorted(ALLOWED), 'source_hashes_verified': True,
              'scope': 'Conditional actor-neutral theory and scoped FRFP charter specialization; no application premises established',
              'declarations': names}
    (REPORTS / 'paper_iii_validation.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k != 'declarations'}, indent=2))

if __name__ == '__main__':
    main()
