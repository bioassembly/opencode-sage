#!/usr/bin/env python3
"""Check bundled skill metadata and local resource links without dependencies."""
from pathlib import Path
import re
import sys
from urllib.parse import unquote, urlsplit


def outside_fences(text: str) -> str:
    lines = []
    fence = None
    for line in text.splitlines():
        marker = re.match(r'^\s{0,3}(`{3,}|~{3,})', line)
        if marker:
            if fence is None:
                fence = marker[1]
            elif marker[1][0] == fence[0] and len(marker[1]) >= len(fence):
                fence = None
            continue
        if fence is None:
            lines.append(line)
    return '\n'.join(lines)


def validate(root: Path) -> list[str]:
    errors = []
    skills = sorted(root.glob('*/SKILL.md'))
    if not skills:
        return [f'{root}: no skills found']
    for skill in skills:
        text = skill.read_text(encoding='utf-8')
        frontmatter = re.match(r'\A---\s*\n(.*?)\n---(?:\n|$)', text, re.S)
        if not frontmatter:
            errors.append(f'{skill}: missing YAML frontmatter')
            continue
        for key in ('name', 'description'):
            match = re.search(rf'^{key}:\s*(\S.*)$', frontmatter[1], re.M)
            if not match:
                errors.append(f'{skill}: missing {key}')
            elif key == 'name' and match[1].strip().strip('\"\'') != skill.parent.name:
                errors.append(f'{skill}: name must match directory')
        for document in sorted(skill.parent.rglob('*.md')):
            content = outside_fences(document.read_text(encoding='utf-8'))
            targets = re.findall(r'\]\(([^\s)]+)(?:\s+[^)]*)?\)', content)
            # Inline guide paths are instructions to read a bundled resource too.
            targets += re.findall(r'`((?:\./)?references?/[^`\s]+\.md)`', content)
            for target in sorted(set(targets)):
                url = urlsplit(target.strip('<>'))
                if url.scheme or url.netloc or not url.path or url.path.startswith(('~', '/')):
                    continue
                path = document.parent / unquote(url.path)
                if not path.exists():
                    errors.append(f'{document}: missing local resource {target}')
    return errors


def main() -> int:
    repo = Path(__file__).resolve().parent.parent
    default = repo / 'reference' / 'skills'
    if not default.exists():
        default = repo / 'skills'
    root = Path(sys.argv[1]) if len(sys.argv) > 1 else default
    errors = validate(root)
    for error in errors:
        print(error, file=sys.stderr)
    if errors:
        return 1
    print(f'Validated {len(list(root.glob("*/SKILL.md")))} skills: metadata and local resources present.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
