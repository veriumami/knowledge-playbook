#!/usr/bin/env python3
"""Audit the playbook by its own standard: every internal link and every
GitHub blob citation must resolve to a real file in the repo. Prints a
VERIFIED / MISMATCH ledger. No hand-typed pass/fail — derived from the tree."""
import os, re, sys

PB = "/Users/school/Documents/Knowledge/playbook"
SITE = "/Users/school/Documents/Knowledge/portfolio-site"
GH_PREFIX = "https://github.com/veriumami/knowledge-playbook/blob/main/"

def repo_files(root):
    out = set()
    for dp, dn, fn in os.walk(root):
        if ".git" in dp:
            continue
        for f in fn:
            rel = os.path.relpath(os.path.join(dp, f), root)
            out.add(rel)
    return out

pb_files = repo_files(PB)
rows = []           # (kind, source_doc, target, status)

md_link = re.compile(r"\]\(([^)]+)\)")

# 1) internal markdown links inside the playbook docs (relative paths + GH blob)
for f in sorted(pb_files):
    if not f.endswith(".md"):
        continue
    p = os.path.join(PB, f)
    with open(p, encoding="utf-8") as fh:
        text = fh.read()
    for m in md_link.finditer(text):
        link = m.group(1).strip()
        if link.startswith("http"):
            if link.startswith(GH_PREFIX):
                target = link[len(GH_PREFIX):].split("#")[0]
                ok = target in pb_files
                rows.append(("gh-cite", f, target, "VERIFIED" if ok else "MISMATCH"))
            # other external URLs (fonts, columbia, etc.) not repo-audited
            continue
        # relative link — strip anchor
        target = link.split("#")[0]
        if target == "" or target.startswith("mailto:"):
            continue
        norm = os.path.normpath(os.path.join(os.path.dirname(f), target))
        ok = norm in pb_files or os.path.isdir(os.path.join(PB, norm))
        rows.append(("internal", f, norm, "VERIFIED" if ok else "MISMATCH"))

# 2) GitHub blob citations embedded in the site HTML must resolve too
for f in sorted(os.listdir(SITE)):
    if not f.endswith(".html"):
        continue
    with open(os.path.join(SITE, f), encoding="utf-8") as fh:
        text = fh.read()
    for link in re.findall(r'href="(' + re.escape(GH_PREFIX) + r'[^"]+)"', text):
        target = link[len(GH_PREFIX):].split("#")[0]
        ok = target in pb_files
        rows.append(("site-cite", f, target, "VERIFIED" if ok else "MISMATCH"))

# 3) every file named in sources/README.md manifest table must exist
man = os.path.join(PB, "sources", "README.md")
with open(man, encoding="utf-8") as fh:
    for line in fh:
        m = re.match(r"\|\s*`([^`]+)`\s*\|", line)
        if m:
            fn = "sources/" + m.group(1)
            ok = fn in pb_files
            rows.append(("manifest", "sources/README.md", fn, "VERIFIED" if ok else "MISMATCH"))

mism = [r for r in rows if r[3] == "MISMATCH"]
by_kind = {}
for k, _, _, st in rows:
    by_kind.setdefault(k, [0, 0])
    by_kind[k][0 if st == "VERIFIED" else 1][0] if False else None
    idx = 0 if st == "VERIFIED" else 1
    by_kind[k][idx] += 1

print("=== PLAYBOOK SELF-AUDIT LEDGER ===")
for k in sorted(by_kind):
    v, m = by_kind[k]
    print(f"  {k:12s}  VERIFIED={v:3d}  MISMATCH={m:3d}")
print(f"  {'TOTAL':12s}  VERIFIED={sum(1 for r in rows if r[3]=='VERIFIED'):3d}  MISMATCH={len(mism):3d}")
print()
if mism:
    print("MISMATCHES:")
    for kind, doc, tgt, _ in mism:
        print(f"  [{kind}] {doc} -> {tgt}  NOT FOUND")
    sys.exit(1)
else:
    print("ALL LINKS + CITATIONS RESOLVE. No MISMATCH.")
