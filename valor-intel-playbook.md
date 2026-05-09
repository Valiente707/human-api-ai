# Valor Intel Playbook

A repeatable routine for Valor Promotions Agents to use the [`last30days-skill`](https://github.com/mvanhorn/last30days-skill) on claude.ai to stay updated on the topics that matter — patient-acquisition signal, competitor moves, healthcare-AI advances, and regulatory changes — and convert them into sales hooks, content, and compliance flags.

**Owner:** Mike Gilbert / Valor Promotions
**Cadence:** Weekly (≈30 min) + monthly synthesis
**Output:** Single Google Doc — *Valor Intel — Brief Archive*

---

## Why this skill

`last30days` aggregates the last 30 days of community signal across Reddit, X, YouTube, TikTok, Hacker News, Polymarket, GitHub, Bluesky, Instagram, Threads, and Pinterest. It ranks by real engagement, dedupes across platforms, and emits an HTML/text research brief. It bypasses SEO-gamed search and surfaces what real practitioners and patients are actually saying — exactly the ground truth Valor needs.

Four lenses Valor applies to every brief:

1. **Sales hook** — fresh outreach angles for medical/dental prospects
2. **Competitor move** — feature, pricing, or positioning changes from PatientPop/Tebra, Doctible, Weave, NexHealth, Solutionreach, Dialog Health, etc.
3. **Content angle** — fuel for blog, LinkedIn, newsletter
4. **Compliance flag** — HIPAA, FTC, state telehealth changes that affect Valor or its clients

---

## 1. One-time setup (claude.ai)

1. **Get the skill file.** Download the latest `.skill` build from <https://github.com/mvanhorn/last30days-skill> (releases page or repo root — README documents the path). MIT-licensed, no auth needed for Reddit / HN / Polymarket / GitHub / Bluesky.
2. **Create a claude.ai Project** named **"Valor Intel"**. In Project knowledge / system prompt, paste:

   > Valor Promotions Agents is a veteran-owned, AI-driven growth engine for healthcare practices (medical, dental, private practices), led by Mike Gilbert. Six precision systems: lead identification, patient reactivation, CRM management, lead scoring/nurturing, real-time analytics, anonymous-visitor capture. Competitors to watch by name: PatientPop / Tebra, Doctible, Weave, Solutionreach, NexHealth, Dialog Health.
   >
   > For every research brief in this project, tag each item with one or more of these four lenses — **Sales hook · Competitor move · Content angle · Compliance flag** — and pull a "Top 3 actionables for Valor this week" block to the top of the brief.

3. **Upload the `.skill`** to the project via claude.ai's skill upload UI.
4. **(Optional, +signal)** Provide browser tokens / API keys for X, YouTube, TikTok, Instagram per the skill README. Without them the skill still works on the free sources.
5. **Create the Google Doc** "Valor Intel — Brief Archive" with the template in §4. Share with Mike + content/sales leads.

---

## 2. Query catalog

10 curated queries. Run each as `/last30days <query>` inside the Valor Intel project.

| # | Query | Primary lens | Cadence |
|---|---|---|---|
| 1 | `AI marketing platforms for medical and dental practices` | Competitor / category | Weekly |
| 2 | `PatientPop OR Tebra OR Weave OR NexHealth OR Doctible` | Competitor (named) | Weekly |
| 3 | `patient reactivation and no-show recovery for private practices` | Sales hook | Weekly |
| 4 | `website visitor identification and identity resolution healthcare` | Sales hook + competitor | Biweekly |
| 5 | `HIPAA marketing and patient data privacy 2026` | Compliance | Biweekly |
| 6 | `FTC healthcare advertising rules and patient testimonials` | Compliance | Monthly |
| 7 | `independent medical practice growth challenges and staffing` | Sales hook + content | Weekly |
| 8 | `AI chatbots and voice agents for patient intake` | Content + competitor | Biweekly |
| 9 | `dental practice marketing and patient acquisition` | Sales hook + content | Biweekly |
| 10 | `telehealth regulation state-by-state changes` | Compliance + content | Monthly |

**Rotation:** split into Set A (odd #s) and Set B (even #s); alternate weeks. Run all 10 once a month for a synthesis pass.

---

## 3. Weekly runbook (≈30 min)

1. Open the Valor Intel project on claude.ai.
2. Run this week's 5 queries — **one per chat** to keep citations clean. Ask for HTML format.
3. For each brief, prompt Claude in the same chat:

   > Tag each item with Sales / Competitor / Content / Compliance lenses, and write the Top 3 actionables for Valor at the top in plain prose.

4. Paste the HTML + the actionables block into the Google Doc under this week's date heading.
5. **Triage pass (10 min):**
   - **Sales** items → drop into a "Hooks this week" note for Mike / sales (one-liner + link each).
   - **Competitor** items → log to a competitors tab/sheet (date, source, what changed).
   - **Content** items → add to LinkedIn / blog / newsletter idea queue.
   - **Compliance** items → flag in a #compliance Slack-or-email thread; if material, ping Mike same-day.
6. **Monthly synthesis:** ask the project to read the last 4 weeks of the Google Doc and produce a *"State of Valor's Market — Month X"* summary (~500 words) for leadership.

---

## 3a. Slack delivery (`#valor-intel-playbook`)

The Google Doc is the system of record. Slack is the **alert layer** — short, scannable pings so Mike and the team see actionables without opening the doc.

**One-time setup:**
1. In `valor-promotions.slack.com`, go to <https://api.slack.com/apps> → **Create New App** → **From scratch**. Name it "Valor Intel Bot" and pick the valor-promotions workspace.
2. Open **Incoming Webhooks** → toggle **Activate Incoming Webhooks** on.
3. Click **Add New Webhook to Workspace**, pick `#valor-intel-playbook`, click Allow.
4. Copy the webhook URL (`https://hooks.slack.com/services/...`) and store it in your shell rc:
   ```
   export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/..."
   ```
   Treat it as a secret. Never commit it.

**Send a message** (uses `valor_intel_slack.py` at the repo root, stdlib only — no `pip install`):

```bash
# One-liner sales hook
python valor_intel_slack.py --text "Sales hook: 67% of dental practices report no-show rates >15% (Reddit r/Dentistry, 412 upvotes). Story for Mike's outreach."

# Weekly actionables block, from a file
python valor_intel_slack.py --title "Valor Intel — Week of 2026-05-11" --file weekly-actionables.md

# Pipe a brief in
cat q1-brief.md | python valor_intel_slack.py --title "Q1: AI marketing platforms"
```

**Recommended Slack cadence:**
- After step 5 of the weekly runbook, post a single message titled `Valor Intel — Week of YYYY-MM-DD` with the **Top 3 actionables** block (link out to the Google Doc for the full briefs).
- For any **[Compliance]** item the operator judges material, post immediately as its own message titled `Compliance flag: <topic>` so it doesn't get buried in the weekly summary.

## 4. Google Doc template

```
# Valor Intel — Brief Archive

## Week of YYYY-MM-DD
### Top 3 actionables for Valor this week
1. …
2. …
3. …

### [Query 1 title] — Sales · Competitor · Content · Compliance
<paste HTML brief>

### [Query 2 title] — …
…

---
## Week of YYYY-MM-DD
…
```

Single doc, append-only — easy to Ctrl-F across months.

---

## 5. Iteration & success criteria

- **Week 4 review:** retire queries that produced zero actionables in 4 weeks; swap in alternates (specialty-specific: derm, ortho, vet; or topical: Medicare Advantage marketing, AI scribe vendors).
- **Month 3 review:** evaluate whether to graduate to scheduled runs (Claude Code on the web on a cron, or GitHub Actions piping briefs into Slack). Only do this if the manual workflow has proven valuable — don't automate noise.
- **KPIs:**
  - # of sales hooks used in outreach
  - # of content pieces sourced from briefs (LinkedIn / blog / email)
  - # of compliance flags caught before they bit a client

---

## Verification (week-1 smoke test)

1. Complete §1 setup; confirm the `.skill` is uploaded.
2. Run query #1 (`AI marketing platforms for medical and dental practices`) in HTML format.
3. Confirm the brief returns with 5+ items, sources, and engagement counts.
4. Apply the four-lens tagging + top-3 actionables prompt.
5. Paste into the Google Doc using the §4 template.

**Pass condition:** at least one item maps to each of the four lenses across the week-1 5-query set, and the doc renders cleanly with working links. If not, swap a low-signal query (e.g., replace #10 with `Medicare Advantage marketing rules 2026`) and re-run next week.
