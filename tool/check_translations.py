"""Checks that lesson translations match their originals in structure.

Usage: python3 tool/check_translations.py [language ...]

For every file in assets/content/i18n/<language>/ it compares with the
original: the number of headings of each level, the number of code blocks and
their languages, and the shape of the Go code (keywords and punctuation):
translations change prose, comments, printed text and names, never code.
Prints the problems found and exits with 1 if there are any; missing
translations are listed but are not errors (the app shows the original).
"""
import json, os, re, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'assets', 'content')
FENCE = re.compile(r'^\s*(`{3,}|~{3,})(\S*)')


def blocks(text):
    """Returns (headings per level, [(language, code)])."""
    heads, out, fence, lang, code = {}, [], None, '', []
    for line in text.split('\n'):
        m = FENCE.match(line)
        if fence is None:
            if m:
                fence, lang, code = m.group(1), m.group(2), []
            elif re.match(r'^#{1,6}\s', line):
                level = len(line) - len(line.lstrip('#'))
                heads[level] = heads.get(level, 0) + 1
        elif m and m.group(1)[0] == fence[0] and len(m.group(1)) >= len(fence) and not m.group(2):
            out.append((lang, '\n'.join(code)))
            fence = None
        else:
            code.append(line)
    return heads, out


KEYWORDS = set(
    'break case chan const continue default defer else fallthrough for func go goto '
    'if import interface map package range return select struct switch type var'.split()
)


def skeleton(code):
    """The shape of Go code: keywords and punctuation only. Comments, string
    literals and names are dropped (translations may rename an Uzbek
    identifier to an English one, but never change the code itself)."""
    code = re.sub(r'/\*.*?\*/', '', code, flags=re.S)
    code = re.sub(r'`[^`]*`', '``', code)
    code = re.sub(r'"(\\.|[^"\\\n])*("|$)', '""', code, flags=re.M)
    code = re.sub(r"'(\\.|[^'\\\n])+'", "''", code)
    code = re.sub(r'//.*', '', code)
    code = re.sub(r'[^\W\d]\w*', lambda m: m.group() if m.group() in KEYWORDS else 'x', code)
    return [l.strip() for l in code.split('\n') if l.strip()]


def main():
    manifest = json.load(open(f'{ROOT}/manifest.json', encoding='utf-8'))
    files = [l['file'] for s in manifest['sections'] for l in s['lessons']]
    languages = sys.argv[1:] or sorted(os.listdir(f'{ROOT}/i18n'))
    problems = 0
    for lang in languages:
        missing = []
        for f in files:
            path = f'{ROOT}/i18n/{lang}/{f}'
            if not os.path.exists(path):
                missing.append(f)
                continue
            oh, ob = blocks(open(f'{ROOT}/{f}', encoding='utf-8').read())
            th, tb = blocks(open(path, encoding='utf-8').read())
            issues = []
            if oh != th:
                issues.append(f'headings {oh} != {th}')
            if [l for l, _ in ob] != [l for l, _ in tb]:
                issues.append(f'code blocks {len(ob)} != {len(tb)} or languages differ')
            else:
                for i, ((l, a), (_, b)) in enumerate(zip(ob, tb)):
                    if l == 'go' and skeleton(a) != skeleton(b):
                        first = next(
                            (x, y) for x, y in zip(skeleton(a) + [''], skeleton(b) + [''])
                            if x != y
                        )
                        issues.append(f'go block {i + 1} differs: {first}')
            for issue in issues:
                print(f'{lang}/{f}: {issue}')
            problems += len(issues)
        print(f'{lang}: {len(files) - len(missing)}/{len(files)} translated')
    sys.exit(1 if problems else 0)


main()
