#!/usr/bin/env python3
"""Post a Valor Intel update to the #valor-intel-playbook Slack channel.

Setup (one-time):
  1. Go to https://api.slack.com/apps -> Create New App -> From scratch.
     Pick "valor-promotions" as the workspace; name it "Valor Intel Bot".
  2. In the app, open "Incoming Webhooks" and toggle "Activate Incoming
     Webhooks" to On.
  3. Click "Add New Webhook to Workspace", pick #valor-intel-playbook,
     and click Allow.
  4. Copy the webhook URL (https://hooks.slack.com/services/T.../B.../...).
  5. Export it locally:
         export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/..."
     Or add the line to your shell rc file. Treat the URL as a secret;
     never commit it.

Usage:
  python valor_intel_slack.py --text "Q1 brief: 3 sales hooks, 1 compliance flag."
  python valor_intel_slack.py --file actionables.md --title "Week of 2026-05-11"
  cat brief.md | python valor_intel_slack.py --title "Q5: HIPAA marketing 2026"

Dependencies:
  Python 3.8+, standard library only.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import urllib.error
import urllib.request
from pathlib import Path

DEFAULT_CHANNEL_HINT = "#valor-intel-playbook"
MAX_BODY_CHARS = 2900  # Slack section text block hard limit is 3000.


def load_webhook_url() -> str:
    url = os.environ.get("SLACK_WEBHOOK_URL")
    if not url:
        sys.exit(
            "SLACK_WEBHOOK_URL is not set. See the docstring at the top of "
            "this file for setup instructions."
        )
    if not url.startswith("https://hooks.slack.com/"):
        sys.exit(
            "SLACK_WEBHOOK_URL doesn't look like a Slack webhook URL "
            f"(got: {url[:40]}...). Expected https://hooks.slack.com/..."
        )
    return url


def build_payload(body: str, title: str | None) -> dict:
    truncated = False
    if len(body) > MAX_BODY_CHARS:
        body = body[:MAX_BODY_CHARS]
        truncated = True
        body += "\n\n_…truncated; full brief in the Valor Intel Google Doc._"

    if title:
        payload = {
            "text": title,  # fallback for notifications
            "blocks": [
                {
                    "type": "header",
                    "text": {"type": "plain_text", "text": title[:150]},
                },
                {
                    "type": "section",
                    "text": {"type": "mrkdwn", "text": body},
                },
            ],
        }
    else:
        payload = {"text": body}

    if truncated:
        sys.stderr.write(
            f"warning: body truncated to {MAX_BODY_CHARS} chars to fit Slack block limit.\n"
        )
    return payload


def post(url: str, payload: dict) -> None:
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=data,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            body = resp.read().decode("utf-8")
            if resp.status != 200 or body.strip() != "ok":
                sys.exit(f"Slack rejected the message (status {resp.status}): {body}")
    except urllib.error.HTTPError as e:
        detail = e.read().decode("utf-8", errors="replace")
        sys.exit(f"Slack HTTP error {e.code}: {detail}")
    except urllib.error.URLError as e:
        sys.exit(f"Network error posting to Slack: {e.reason}")


def main() -> None:
    parser = argparse.ArgumentParser(
        description=(
            f"Post a Valor Intel message to {DEFAULT_CHANNEL_HINT} via an "
            "Incoming Webhook. Channel is fixed by the webhook URL."
        )
    )
    parser.add_argument("--title", help="Optional header line shown in bold above the body.")
    body_src = parser.add_mutually_exclusive_group()
    body_src.add_argument("--file", type=Path, help="Read the message body from a file.")
    body_src.add_argument("--text", help="Message body as a string.")
    args = parser.parse_args()

    if args.file:
        body = args.file.read_text()
    elif args.text:
        body = args.text
    else:
        body = sys.stdin.read()

    if not body.strip():
        sys.exit("No message body provided. Use --file, --text, or pipe to stdin.")

    post(load_webhook_url(), build_payload(body, args.title))
    print(f"Posted to Slack ({len(body)} chars).")


if __name__ == "__main__":
    main()
