import re, json, sys, os, yaml

"""Imports the basic lessons of go-lang.uz into assets/content/golang_uz.

Usage: python3 tool/import_golang_uz.py <path to go-lang.uz clone>

MkDocs-only syntax is converted for the app: front matter is dropped, admonitions
become blockquotes, code fence attributes (title, linenums) are removed and
links between lessons become plain text. Needs PyYAML. It rewrites the
"golang_uz" files and the "golang_uz" section of manifest.json.
"""
SRC = sys.argv[1] if len(sys.argv) > 1 else '../go-lang.uz'
DST = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'assets', 'content')
LABELS = {'info': "Ma'lumot", 'warning': 'Diqqat', 'note': 'Eslatma', 'tip': 'Maslahat'}
FENCE = re.compile(r'^(\s*)(`{3,}|~{3,})(.*)$')

def flatten(nav, out):
    for item in nav:
        for k, v in item.items():
            if isinstance(v, list):
                flatten(v, out)
            elif v.startswith('basic/') and v != 'basic/index.md':
                out.append((k, v))

def admonitions(text):
    lines = text.split('\n'); out = []; i = 0; fence = None
    while i < len(lines):
        ln = lines[i]
        m = FENCE.match(ln)
        if m:
            if fence is None: fence = m.group(2)
            elif m.group(2)[0] == fence[0] and len(m.group(2)) >= len(fence) and not m.group(3).strip(): fence = None
            out.append(ln); i += 1; continue
        am = re.match(r'^!!!\s*(\w+)?\s*(?:"([^"]*)")?\s*$', ln) if fence is None else None
        if not am:
            out.append(ln); i += 1; continue
        kind = (am.group(1) or 'note').lower()
        label = am.group(2) or LABELS.get(kind, kind.capitalize())
        i += 1; body = []
        while i < len(lines):
            l = lines[i]
            if l.startswith('    ') or l.startswith('\t'):
                body.append(l[4:] if l.startswith('    ') else l[1:]); i += 1
            elif l.strip() == '':
                j = i
                while j < len(lines) and lines[j].strip() == '': j += 1
                if j < len(lines) and (lines[j].startswith('    ') or lines[j].startswith('\t')):
                    body.extend([''] * (j - i)); i = j
                else: break
            else: break
        while body and body[-1] == '': body.pop()
        if sum(1 for b in body if FENCE.match(b)) % 2: body.append('```')  # source has an unclosed fence
        out.append('')
        if not body:
            out.append(f'**{label}**')
        elif any(FENCE.match(b) for b in body):
            out.append(f'**{label}**'); out.append(''); out.extend(body)
        else:
            out.append(f'> **{label}**'); out.append('>')
            out.extend(('> ' + b) if b else '>' for b in body)
        out.append('')
    return '\n'.join(out)

def clean(text):
    # outside fences: html + links; on fences: strip attributes
    lines = text.split('\n'); out = []; fence = None; buf = []
    def flush():
        if not buf: return
        t = '\n'.join(buf); buf.clear()
        t = re.sub(r'</?p>', '', t)
        t = re.sub(r'<a\s+href="([^"]+)"[^>]*>\s*(.*?)\s*</a>', lambda m: f'[{m.group(2)}]({m.group(1)})', t, flags=re.S)
        t = re.sub(r'\[([^\]]+)\]\((?!https?://|mailto:)[^)]*\.md(?:#[^)]*)?\)', r'\1', t)
        out.append(t)
    for ln in lines:
        m = FENCE.match(ln)
        if m:
            if fence is None:
                flush(); fence = m.group(2)
                lang = m.group(3).strip().split(' ')[0] if m.group(3).strip() else ''
                out.append(f'{m.group(1)}{m.group(2)}{lang}')
            elif m.group(2)[0] == fence[0] and len(m.group(2)) >= len(fence) and not m.group(3).strip():
                fence = None; out.append(ln)
            elif m.group(2)[0] == fence[0] and len(m.group(2)) >= len(fence) and m.group(3).strip():
                # source forgot to close the previous block: close it, open this one
                out.append(fence); out.append('')
                fence = m.group(2)
                lang = m.group(3).strip().split(' ')[0]
                out.append(f'{m.group(1)}{m.group(2)}{lang}')
            else: out.append(ln)
        elif fence is None: buf.append(ln)
        else: out.append(ln)
    flush()
    return re.sub(r'\n{3,}', '\n\n', '\n'.join(out)).strip() + '\n'

def main():
    class L(yaml.SafeLoader): pass
    L.add_multi_constructor('', lambda l, s, n: None)
    L.add_multi_constructor('tag:yaml.org,2002:python/', lambda l, s, n: None)
    cfg = yaml.load(open(f'{SRC}/mkdocs.yml'), Loader=L)
    lessons = []; flatten(cfg['nav'], lessons)
    os.makedirs(f'{DST}/golang_uz', exist_ok=True)
    entries = []
    for idx, (navtitle, path) in enumerate(lessons, 1):
        raw = open(f'{SRC}/docs/{path}', encoding='utf-8').read()
        desc = None
        fm = re.match(r'^---\n(.*?)\n---\n', raw, re.S)
        if fm:
            desc = (yaml.safe_load(fm.group(1)) or {}).get('description'); raw = raw[fm.end():]
        body = clean(admonitions(raw))
        if not re.match(r'^\s*#\s', body): body = f'# {navtitle}\n\n' + body
        slug = os.path.basename(path)[:-3].replace('-', '_')
        name = f'{idx:02d}_{slug}.md'
        open(f'{DST}/golang_uz/{name}', 'w', encoding='utf-8').write(body)
        odd = sum(1 for l in body.split('\n') if FENCE.match(l)) % 2
        if odd: print('ODD FENCES', path, file=sys.stderr)
        e = {'file': f'golang_uz/{name}', 'summary': desc or ''}
        entries.append(e)
    J = lambda x: json.dumps(x, ensure_ascii=False)
    lines = ',\n'.join(f'        {{ "file": {J(e["file"])}, "summary": {J(e["summary"])} }}' for e in entries)
    block = f'''    {{
      "id": "golang_uz",
      "title": "Go asoslari (go-lang.uz)",
      "subtitle": "Uzbek-language lessons from go-lang.uz: syntax, types, functions, concurrency and the standard library.",
      "icon": "book",
      "color": "#0EA5A4",
      "lessons": [
{lines}
      ]
    }},
'''
    path = f'{DST}/manifest.json'
    text = open(path, encoding='utf-8').read()
    text = re.sub(r'    \{\n      "id": "golang_uz".*?\n    \},\n', '', text, flags=re.S)
    marker = '    {\n      "id": "advanced"'
    open(path, 'w', encoding='utf-8').write(text.replace(marker, block + marker, 1))
    print(len(entries), 'lessons')

main()
