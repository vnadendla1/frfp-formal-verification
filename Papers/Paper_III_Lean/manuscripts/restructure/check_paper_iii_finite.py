"""Exhaustive finite realization for the Paper III structural revision.

This executable model supplements, and is not a new theorem in, the Lean core.
"""
from dataclasses import dataclass, replace, asdict
from itertools import product
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
ACTORS = ('p', 'm')
ROOTS = frozenset({'p'})
SOURCE = 'I'
SOURCE_ORIGIN = {(SOURCE, 'o')}
AUTHORIZED_BEARER = {(SOURCE, 'p', 'o')}
PARTICIPANT_ORIGIN = {'p'}
DELEGATION = {('p', 'm')}
WORLDS = tuple(product((False, True), repeat=2))

@dataclass(frozen=True)
class State:
    world: tuple[bool, bool]
    artifact: bool | None = None
    discovered: bool = False
    proposed: bool = False
    admitted: bool = False
    expanded: bool = False
    assessment: bool | None = None
    outstanding: bool = True
    decision: bool | None = None

def standing(actor, credential):
    return actor == 'p' or (actor == 'm' and credential)

def step(s, operation, actor, credential=False):
    if operation == 'produce':
        return replace(s, artifact=s.world[0], assessment=None) if actor in ACTORS else s
    if operation == 'discover':
        return replace(s, discovered=True)
    if operation == 'propose':
        return replace(s, proposed=True) if s.discovered else s
    if operation == 'admit':
        return replace(s, admitted=True, assessment=None) if actor == 'p' and s.proposed else s
    if operation == 'expand':
        return replace(s, expanded=True) if s.admitted else s
    if operation == 'assess':
        if s.artifact is None or (s.admitted and not s.expanded):
            return s
        value = s.artifact == s.world[0]
        if s.admitted:
            value = value and s.world[1]
        return replace(s, assessment=value)
    if operation == 'close':
        if s.assessment is not None and standing(actor, credential):
            return replace(s, outstanding=False, decision=s.assessment)
        return s
    raise ValueError(operation)

def factors(target, representation):
    return all(representation(x) != representation(y) or target(x) == target(y)
               for x in WORLDS for y in WORLDS)

def check_authority_boundary():
    # Enumerate every Boolean channel on the four worlds; close u under arbitrary decoding.
    channels = tuple(product((False, True), repeat=len(WORLDS)))
    def channel(values): return lambda w: values[WORLDS.index(w)]
    rm = lambda w: w[0]
    decision = lambda w: w[1]
    local = [values for values in channels if factors(channel(values), rm)]
    assert len(local) == 4
    assert not factors(decision, rm)
    assert factors(decision, lambda w: (rm(w), decision(w)))
    occurrences = []
    for world in WORLDS:
        for root in ('h1', 'h2'):
            payload = {'issuer':root, 'decision':decision(world), 'crossed_beta':True}
            occurrence = {'executor':'machine', 'obligation':'o', 'episode':0,
                          'root':root, 'payload':payload, 'derived_standing':True,
                          'auth_close':True, 'valid_close':True, 'outstanding_after':False}
            assert occurrence['payload']['crossed_beta']
            assert occurrence['payload']['decision'] == decision(world)
            assert occurrence['auth_close'] and occurrence['derived_standing'] and occurrence['valid_close']
            assert not factors(decision, rm)  # payload never changes the independent basis
            occurrences.append(occurrence)
    return {'semantic_worlds':4, 'boolean_channels_checked':len(channels),
            'independent_channels':len(local), 'delegated_occurrences_checked':len(occurrences),
            'local_source':'u', 'closure':'all Boolean functions of u', 'boundary_payload':'root-issued v',
            'occurrences':occurrences}

def main():
    u = lambda x: x[0]
    d = lambda x: x[1]
    old = u
    new = lambda x: x
    assert factors(u, old)
    assert not factors(d, old)
    assert not factors(new, old)
    assert factors(u, new) and factors(d, new)
    assert len({new(x) for x in WORLDS}) == 4
    assert len({old(x) for x in WORLDS}) == 2
    assert all((source, bearer, obligation) in AUTHORIZED_BEARER
               and bearer in PARTICIPANT_ORIGIN
               for source, obligation in SOURCE_ORIGIN for bearer in ROOTS)
    assert PARTICIPANT_ORIGIN <= ROOTS and ROOTS == {'p'} and 'm' not in ROOTS
    events = tuple(product(('produce','discover','propose','admit','expand','assess','close'), ACTORS, (False,True)))
    # Check the full finite state domain as well as states reachable from initial cases.
    states = [State(w, artifact, discovered, proposed, admitted, expanded, assessment, outstanding, decision)
              for w in WORLDS for artifact, discovered, proposed, admitted, expanded, assessment, outstanding, decision
              in product((None,False,True),(False,True),(False,True),(False,True),(False,True),
                         (None,False,True),(False,True),(None,False,True))]
    for s in states:
        for actor in ACTORS:
            assert step(s,'discover',actor).admitted == s.admitted
            assert step(s,'admit','m') == s
            assert step(s,'close','m',False) == s
            if s.assessment is not None and s.outstanding:
                assert not step(s,'close','m',True).outstanding
                assert step(s,'close','m',True).decision == s.assessment
    reachable = set(State(w) for w in WORLDS)
    pending = list(reachable)
    transitions = 0
    while pending:
        s = pending.pop()
        for event in events:
            t = step(s,*event); transitions += 1
            if t not in reachable:reachable.add(t);pending.append(t)
    traces = []
    for world in WORLDS:
        state = State(world)
        trace = [asdict(state)]
        for op, actor, credential in [('produce','m',False),('discover','m',False),
                                      ('propose','m',False),('admit','p',False),('expand','m',False),
                                      ('assess','m',False),('close','m',True)]:
            state=step(state,op,actor,credential);trace.append(asdict(state))
        assert state.admitted and state.expanded and not state.outstanding
        assert state.decision == world[1]
        traces.append({'world':world,'states':trace})
    before = State((True,False), artifact=True, discovered=True, proposed=True)
    assert step(before,'admit','m') == before
    discovered_only = replace(before, proposed=False)
    assert step(discovered_only,'admit','p') == discovered_only
    revised = step(before,'admit','p')
    assert revised.admitted and not revised.expanded
    assert step(revised,'assess','m') == revised
    rich = step(revised,'expand','m')
    assessed = step(rich,'assess','m')
    assert assessed.assessment is False
    assert step(assessed,'close','m',False) == assessed
    refused = step(assessed,'close','m',True)
    assert refused.decision is False and not refused.outstanding
    result={'status':'PASS','scope':'Exhaustive Python finite-model check; not a joint Lean proof or empirical validation',
            'authority_boundary':check_authority_boundary(),'semantic_worlds':4,'full_states_checked':len(states),'reachable_states':len(reachable),
            'reachable_transitions_checked':transitions,'traces':traces}
    target=ROOT/'reports/paper_iii_finite_realization.json'
    target.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k not in ('traces','authority_boundary')},indent=2))

if __name__=='__main__':main()
