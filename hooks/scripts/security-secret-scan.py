#!/usr/bin/env python3
"""Pattern-scan a unified diff (read from stdin) for secret-shaped strings.
Prints a short finding description if something looks real (not a placeholder);
prints nothing and exits 0 if clean. Mirrors the pattern table in
~/.claude/knowledge/obs-security-protocol.md.
"""
import re
import sys

PATTERNS = {
    "GitHub PAT": r"gh[pousr]_[A-Za-z0-9]{20,}",
    "AWS Access Key": r"AKIA[0-9A-Z]{16}",
    "Private key header": r"-----BEGIN (RSA |EC |OPENSSH |)PRIVATE KEY-----",
    "Supabase key": r"sb(p|_secret|_publishable)_[A-Za-z0-9_]{10,}",
    "Vercel token": r"vc[ar]_[A-Za-z0-9]{20,}",
    "Render key": r"rnd_[A-Za-z0-9]{20,}",
    "OpenAI-style key": r"sk-[A-Za-z0-9]{20,}",
    "Generic key/secret/password/token assignment": (
        r"(?i)(api[_-]?key|secret|password|token)[\"']?\s*[:=]\s*[\"']?[A-Za-z0-9+/_\-]{16,}"
    ),
}

PLACEHOLDER_HINTS = re.compile(
    r"(x{6,}|\.\.\.|<[^>]+>|your[_-]?key|example|placeholder|redacted|dummy|changeme|fill[_-]?in)",
    re.IGNORECASE,
)


def added_lines(diff_text: str):
    for line in diff_text.splitlines():
        if line.startswith("+") and not line.startswith("+++"):
            yield line[1:]


def main():
    diff_text = sys.stdin.read()
    findings = []
    for line in added_lines(diff_text):
        for name, pattern in PATTERNS.items():
            m = re.search(pattern, line)
            if m and not PLACEHOLDER_HINTS.search(line):
                findings.append(name)
                break
    if findings:
        # de-dupe, keep order
        seen = []
        for f in findings:
            if f not in seen:
                seen.append(f)
        print(", ".join(seen))


if __name__ == "__main__":
    main()
