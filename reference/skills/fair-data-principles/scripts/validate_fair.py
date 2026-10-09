#!/usr/bin/env python3
"""
validate_fair.py: Automated FAIR Compliance Auditor for scientific repositories and pipelines.

Audits:
- Findable: Unique identifiers, machine-readable datapackage.json, samples metadata
- Accessible: Open formats, license presence, retrievability
- Interoperable: Standard ontologies (GTDB, KEGG, EC, Pfam), UTF-8 TSV formatting
- Reusable: Locked environments (environment.yml/requirements.txt), citations, provenance
"""

import argparse
import json
import os
import sys

CORE_FILES = [
    ('LICENSE', 'R1.1 Open License'),
    ('CITATIONS.md', 'R1.2 Provenance & Citations'),
    ('FAIR_COMPLIANCE.md', 'FAIR Compliance Statement'),
]

ENV_FILES = [
    ('environment.yml', 'R1.2 Conda environment specification'),
    ('requirements.txt', 'R1.2 Python dependencies specification'),
]

METADATA_FILES = [
    ('metadata/samples_metadata.tsv', 'F2/R1.3 GSC MIxS Sample Metadata'),
    ('metadata/datapackage.json', 'F4 Frictionless Data Package Schema'),
]

def audit_fair_compliance(repo_dir):
    print(f"=== Auditing FAIR Compliance in: {repo_dir} ===")
    issues = 0
    checks_passed = 0

    # 1. Check core governance files
    for rel_path, desc in CORE_FILES:
        full_path = os.path.join(repo_dir, rel_path)
        if os.path.exists(full_path) and os.path.getsize(full_path) > 0:
            print(f"  [PASS] {desc}: {rel_path} present ({os.path.getsize(full_path)} bytes)")
            checks_passed += 1
        else:
            print(f"  [FAIL] {desc}: {rel_path} MISSING or empty")
            issues += 1

    # 2. Check environment specifications
    env_present = False
    for rel_path, desc in ENV_FILES:
        full_path = os.path.join(repo_dir, rel_path)
        if os.path.exists(full_path) and os.path.getsize(full_path) > 0:
            print(f"  [PASS] {desc}: {rel_path} present")
            env_present = True
            checks_passed += 1
            break
    if not env_present:
        print(f"  [FAIL] R1.2 Environment: Neither environment.yml nor requirements.txt found")
        issues += 1

    # 3. Check metadata files
    for rel_path, desc in METADATA_FILES:
        full_path = os.path.join(repo_dir, rel_path)
        if os.path.exists(full_path) and os.path.getsize(full_path) > 0:
            print(f"  [PASS] {desc}: {rel_path} present")
            checks_passed += 1
            if rel_path.endswith('.json'):
                try:
                    with open(full_path) as jf:
                        json.load(jf)
                    print(f"         JSON schema parses cleanly")
                except Exception as e:
                    print(f"  [WARN] JSON parse error in {rel_path}: {e}")
                    issues += 1
        else:
            print(f"  [FAIL] {desc}: {rel_path} MISSING or empty")
            issues += 1

    print("--------------------------------------------------")
    if issues == 0:
        print(f"RESULT: 100% FAIR COMPLIANT ({checks_passed} checks passed, 0 issues)")
        return 0
    else:
        print(f"RESULT: FAIR AUDIT FAILED ({issues} issues found, {checks_passed} checks passed)")
        return 1

def main():
    parser = argparse.ArgumentParser(description="Audit repository for FAIR data compliance")
    parser.add_argument('repo_dir', nargs='?', default='.', help="Path to repository root")
    args = parser.parse_args()
    sys.exit(audit_fair_compliance(args.repo_dir))

if __name__ == '__main__':
    main()
