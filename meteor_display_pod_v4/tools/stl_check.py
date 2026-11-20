#!/usr/bin/env python3
# Mesh sanity check for ASCII STL exports: shell count (separate pieces) and
# non-manifold edges. Every printable part should report shells=1 bad_edges=0.
# Usage: python3 tools/stl_check.py exports/*.stl
import sys, collections
def load(p):
    tris=[];cur=[]
    for line in open(p):
        t=line.split()
        if t and t[0]=='vertex':
            cur.append(tuple(round(float(x),4) for x in t[1:4]))
            if len(cur)==3: tris.append(tuple(cur)); cur=[]
    return tris
for p in sys.argv[1:]:
    tris=load(p)
    vid={};parent=[]
    def f(i):
        while parent[i]!=i: parent[i]=parent[parent[i]]; i=parent[i]
        return i
    edges=collections.Counter()
    for t in tris:
        ids=[]
        for v in t:
            if v not in vid: vid[v]=len(parent); parent.append(len(parent))
            ids.append(vid[v])
        for a,b in ((ids[0],ids[1]),(ids[1],ids[2]),(ids[2],ids[0])):
            ra,rb=f(a),f(b)
            if ra!=rb: parent[ra]=rb
            edges[tuple(sorted((a,b)))]+=1
    comps=collections.defaultdict(list)
    for v,i in vid.items(): comps[f(i)].append(v)
    nonmani=sum(1 for c in edges.values() if c!=2)
    xs=[v[0] for v in vid];ys=[v[1] for v in vid];zs=[v[2] for v in vid]
    print(f"{p}: tris={len(tris)} bbox X[{min(xs):.2f},{max(xs):.2f}] Y[{min(ys):.2f},{max(ys):.2f}] Z[{min(zs):.2f},{max(zs):.2f}] shells={len(comps)} bad_edges={nonmani}")
    for c in sorted(comps.values(),key=len)[:-1]:
        cx=[v[0] for v in c];cy=[v[1] for v in c];cz=[v[2] for v in c]
        print(f"   small shell: X[{min(cx):.1f},{max(cx):.1f}] Y[{min(cy):.1f},{max(cy):.1f}] Z[{min(cz):.1f},{max(cz):.1f}]")
