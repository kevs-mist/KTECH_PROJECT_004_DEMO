#!/usr/bin/env python3
"""Fail when LCOV line coverage for lib/ is below the requested threshold."""

import argparse
import sys
from pathlib import Path


def library_line_coverage(lcov_path: Path) -> tuple[int, int]:
    covered = 0
    total = 0
    include_file = False

    for line in lcov_path.read_text(encoding="utf-8").splitlines():
        if line.startswith("SF:"):
            source = line[3:].replace("\\", "/")
            while source.startswith("./"):
                source = source[2:]
            include_file = source.startswith("lib/")
        elif include_file and line.startswith("DA:"):
            fields = line[3:].split(",", maxsplit=2)
            if len(fields) < 2:
                continue
            try:
                hits = int(fields[1])
            except ValueError:
                continue
            total += 1
            covered += hits > 0

    return covered, total


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("lcov", type=Path, help="Path to the LCOV info file")
    parser.add_argument("--threshold", type=float, default=80.0)
    args = parser.parse_args()

    if not args.lcov.is_file():
        print(f"Coverage file not found: {args.lcov}", file=sys.stderr)
        return 2

    covered, total = library_line_coverage(args.lcov)
    if total == 0:
        print("No lib/ line records found in coverage file.", file=sys.stderr)
        return 2

    percentage = covered * 100 / total
    print(f"lib/ line coverage: {covered}/{total} ({percentage:.2f}%), required: {args.threshold:.2f}%")
    return 0 if percentage >= args.threshold else 1


if __name__ == "__main__":
    raise SystemExit(main())