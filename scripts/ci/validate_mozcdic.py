#!/usr/bin/env python3
# coding: utf-8

import re
import sys
from pathlib import Path

RE_HIRAGANA = re.compile(r'^[ぁ-ゔー]+$')


def validate(path: Path, min_lines: int) -> None:
    errors: list[str] = []
    line_count = 0

    with open(path, encoding='utf-8') as file:
        for line_no, line in enumerate(file, start=1):
            line = line.rstrip('\n')
            if not line:
                errors.append(f'line {line_no}: empty line')
                continue

            fields = line.split('\t')
            if len(fields) != 5:
                errors.append(
                    f'line {line_no}: expected 5 tab-separated fields, got {len(fields)}')
                continue

            yomi, _id1, _id2, cost, hyouki = fields
            line_count += 1

            if not RE_HIRAGANA.match(yomi):
                errors.append(f'line {line_no}: invalid yomi {yomi!r}')
            if not cost.isdigit():
                errors.append(f'line {line_no}: invalid cost {cost!r}')
            if len(hyouki) < 2 or len(hyouki) > 25:
                errors.append(f'line {line_no}: hyouki length out of range')

            if len(errors) >= 20:
                break

    if line_count < min_lines:
        errors.append(f'line count {line_count} < minimum {min_lines}')

    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        sys.exit(1)

    print(f'OK: {line_count} entries validated')


def main() -> None:
    if len(sys.argv) not in (2, 3):
        print('Usage: validate_mozcdic.py <mozcdic-ut.txt> [min_lines]', file=sys.stderr)
        sys.exit(2)

    path = Path(sys.argv[1])
    min_lines = int(sys.argv[2]) if len(sys.argv) == 3 else 1_000_000
    validate(path, min_lines)


if __name__ == '__main__':
    main()