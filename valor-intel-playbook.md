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

## 1. One-time setup (Claude Code on your laptop)

> **Why local, not claude.ai web?** `last30days-skill` hits Reddit's public JSON API directly, and Reddit returns `403 Forbidden` to anonymous requests from datacenter IP ranges (which is what claude.ai's cloud sandbox uses). Running from your residential IP via Claude Code on your laptop is the path the skill was built for. The claude.ai upload path (`make-skill-bundle.sh` + `valor-intel.skill`) stays in the repo as a fallback for sharing with team members later, but the primary runtime is local.

**Steps:**

1. **Install Claude Code** if you don't have it (<https://docs.anthropic.com/en/docs/claude-code>) and confirm Python 3.12+ (`python3 --version`). On macOS: `brew install python@3.12`.
2. **Clone this repo** (the strategy repo) somewhere convenient on your machine, e.g. `~/code/human-api-ai`. Check out branch `claude/valor-promotions-strategy-ILhNy`.
3. **Run the installer:**
   ```bash
   ./install-skills.sh
   ```
   This clones `last30days-skill` to `~/.claude/skills/last30days/` and symlinks `valor-intel/` to `~/.claude/skills/valor-intel/`. Re-run anytime to update.
4. **(Optional, +signal)** Set up richer sources per the installer's printed hints — `brew install yt-dlp` for YouTube, stay logged into x.com in a browser, etc. Reddit / HN / Polymarket / GitHub work with zero config from your residential IP.
5. **Create the Google Doc** "Valor Intel — Brief Archive" using the template in §4. Share with your content/sales leads.
6. **Confirm the Slack MCP is connected** in your local Claude Code (the same one that posted the test message to `#valor-intel-playbook`). The `/valor-intel` skill will use it to post Top 3 actionables.

**Verify your environment** before Week 1:
```bash
./verify-setup.sh
```
Checks Python ≥3.12, that both skills are installed, that Reddit returns 200 from your IP (the cloud-block test that matters most), and prints a summary of optional source readiness (yt-dlp, Bluesky env vars, `INCLUDE_SOURCES`). Exits non-zero if any critical check fails.

**End-to-end smoke test:** open Claude Code in any directory and run:
```
/last30days "AI marketing platforms for medical and dental practices"
```
You should get a brief with Reddit/HN items. If you get an empty brief or 403 errors, you're on a cloud/datacenter IP — switch to your laptop's normal network.

---

## 1a. Day 0 source setup checklist (15 min, materially better briefs)

`last30days` works out of the box on Reddit / HN / Polymarket / GitHub from a residential IP, but those alone won't surface **competitor moves on X** or **product demos on YouTube** — exactly the signals Valor cares about most. The 15 minutes below makes the difference between a thin Week 1 brief and a useful one.

| Source | Why it matters for Valor | Setup | Time |
|---|---|---|---|
| **X / Twitter** | Where competitor exec posts, product launches, pricing announcements, and healthcare-AI hot takes live. PatientPop / Tebra / Weave / NexHealth all post here. Drives the **[Competitor]** lens. | Open Chrome/Safari/Firefox and log into <https://x.com>. Stay logged in — the skill picks up the browser session automatically. No API key. | 1 min |
| **YouTube** | Product demos for voice agents, patient-intake chatbots, AI scribes — the "is this real or vaporware?" check on competitors. Drives the **[Content]** and **[Competitor]** lenses. | macOS: `brew install yt-dlp` &nbsp;·&nbsp; other: `pipx install yt-dlp` | 2 min |
| **Bluesky** | Smaller volume but high signal post-Twitter exodus; some healthcare-marketing voices have moved here. Drives the **[Sales]** and **[Content]** lenses. | Generate an app password at <https://bsky.app/settings/app-passwords>, then `export BLUESKY_HANDLE=you.bsky.social` and `export BLUESKY_APP_PASSWORD=xxxx-xxxx-xxxx-xxxx`. | 3 min |

**Skip for v1:** TikTok / Instagram / Threads / Pinterest (ScrapeCreators API — useful for patient-facing content, less relevant for B2B Valor sales) and Perplexity Sonar / Brave Search (paid, mostly redundant with the four lenses). Revisit only if the briefs feel thin after a month.

**Enable the optional sources at runtime** by setting `INCLUDE_SOURCES` before invoking the skill (or add the line to your shell rc so it's always on):
```
export INCLUDE_SOURCES=x,youtube,bluesky
/last30days "AI marketing platforms for medical and dental practices"
```

**Minimum viable for Week 1:** X login + yt-dlp. Bluesky is the cheap third add-on. Everything else can wait.

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

## 3a. Slack delivery — `#valor-intel-playbook`

The Google Doc is the system of record. Slack is the **alert layer** — short, scannable pings so Mike and the team see actionables without opening the doc.

**Channel:** `#valor-intel-playbook` in `valor-promotions.slack.com` (channel ID `C0B2KJAUMQT`).

### Primary path — Slack MCP (use this)

The Slack MCP is already connected in your Claude Code environment — that's the same connection that posted the channel-test message in `#valor-intel-playbook`. No webhook, no env var, no script to run. The `/valor-intel` skill calls `slack_send_message` directly when it asks "Post the Top 3 to #valor-intel-playbook?"

If you ever want to post manually, just tell Claude in any session:

> Post this to #valor-intel-playbook: <paste content>

**Slack cadence (MCP):**
- After step 5 of the weekly runbook, post a single message titled `Valor Intel — Week of YYYY-MM-DD` with the Top 3 actionables (link to the Google Doc for the full briefs).
- For any `[Compliance]` item the operator judges material, post immediately as its own message titled `Compliance flag: <topic>` so it doesn't get buried in the weekly summary.

### Fallback path — `valor_intel_slack.py` (only if MCP is unavailable or you automate)

The repo has a stdlib-only Python script that posts via an Incoming Webhook. Use it only if (a) the Slack MCP isn't connected on the machine you're running from, or (b) you graduate to a scheduled/headless run (cron, GitHub Action) where no Claude session is involved.

One-time setup:
1. Create a Slack app at <https://api.slack.com/apps> → **From scratch** → workspace = valor-promotions.
2. **Incoming Webhooks** → on → **Add New Webhook to Workspace** → pick `#valor-intel-playbook` → Allow.
3. Copy the webhook URL and `export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/..."`.

Send a message:
```bash
python valor_intel_slack.py --title "Valor Intel — Week of 2026-05-11" --file weekly-actionables.md
```

Full setup steps and CLI flags are also in the docstring at the top of `valor_intel_slack.py`. Don't bother setting this up until you actually need it — the MCP path above covers every manual scenario.

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

---

## Appendix A — claude.ai Project: Custom instructions

Paste this verbatim into the **Custom instructions** field of the Valor Intel project on claude.ai. It tells Claude how to behave on every research run.

```
You are the research analyst for Valor Promotions Agents — a veteran-owned, AI-driven growth engine for healthcare practices (medical, dental, private practices), founded by Mike Gilbert. Valor's product is six precision systems: lead identification, anonymous-visitor capture, patient reactivation, lead scoring/nurturing, CRM management, and real-time analytics. Pitch is "AI tech from the heart, human service from the soul" — affordable, scalable growth for independent practices.

## Competitors to track by name
PatientPop / Tebra, Doctible, Weave, Solutionreach, NexHealth, Dialog Health. Also flag any new entrant targeting the same buyer (independent medical or dental practice owner, office manager, practice administrator).

## The four lenses
Tag every item in every research brief with one or more:
- [Sales] — a fresh outreach angle: a pain point trending right now, a stat we can quote, a story we can lead with.
- [Competitor] — a feature, pricing, positioning, hire, partnership, funding, or controversy from a named competitor or category challenger.
- [Content] — fuel for a LinkedIn post, blog, newsletter, or sales-enablement asset.
- [Compliance] — HIPAA, FTC healthcare-advertising, state telehealth, or patient-data-privacy change that could affect Valor or its clients.

## Default behavior on every /last30days run
1. Run the query and produce the standard brief.
2. Tag each item inline with one or more lens labels in brackets, e.g. "[Sales] [Content]".
3. At the TOP of the brief, before the items, write:
   "Top 3 actionables for Valor this week" — three single-sentence bullets, each stating: the actionable, the owner (Mike / sales / content / compliance), and the source link.
4. Output the full brief in HTML so it pastes cleanly into the "Valor Intel — Brief Archive" Google Doc.

## Style
- Plain prose. No marketing fluff, no "as an AI."
- Don't recap the query or the methodology — get to the items.
- If a story appears on multiple platforms, dedupe and cite the highest-engagement source.
- If a query returns thin signal, say so and suggest 1–2 alternate queries instead of padding.
- Quote real numbers (engagement counts, percentages, dollar figures) when sources include them.

## Out of scope
Skip pure-consumer health content (general wellness, recipes, fitness influencers) unless it directly informs a marketing or compliance angle for independent practices.
```

---

## Appendix B — claude.ai Project: Description

Paste this into the project's **Description** field (the short blurb shown at the top of the project page).

```
Valor Intel — weekly community-signal research for Valor Promotions Agents
(veteran-owned AI growth engine for healthcare practices, led by Mike
Gilbert). Runs the last30days-skill across a 10-query catalog covering
healthcare-AI trends, named competitors (PatientPop/Tebra, Doctible, Weave,
NexHealth, Solutionreach, Dialog Health), patient-acquisition signal, and
HIPAA/FTC/telehealth changes. Every brief is tagged with four lenses —
[Sales] [Competitor] [Content] [Compliance] — and topped with a "Top 3
actionables for Valor this week" block. Full HTML briefs go into the Valor
Intel — Brief Archive Google Doc; the Top 3 actionables get posted to
#valor-intel-playbook in valor-promotions.slack.com via the Slack MCP.
Weekly cadence ≈ 30 min: run /last30days for this week's 5-query set (Set A:
1/3/5/7/9 alternating with Set B: 2/4/6/8/10), paste briefs, ask Claude to
post the actionables to Slack. Full playbook in valor-intel-playbook.md.
```

---

## Appendix C — Google Doc: pre-filled first month

Drop this block into the *Valor Intel — Brief Archive* Google Doc; weeks are pre-anchored to the upcoming Mondays.

```
Valor Intel — Brief Archive
Owner: Mike Gilbert · Updated weekly · Source: last30days-skill on claude.ai (Valor Intel project)

How this doc works
- Each week, append a new "Week of …" section below.
- For each query, paste the HTML brief returned by claude.ai under its heading.
- Write the Top 3 actionables at the top of the week (one sentence each: actionable · owner · link).
- Append-only — never delete past weeks. Use Ctrl-F to find recurring themes across months.
- Sets rotate: Set A = queries 1, 3, 5, 7, 9 · Set B = queries 2, 4, 6, 8, 10.

────────────────────────────────────────────────────────────

Week of 2026-05-11 — Set A

Top 3 actionables for Valor this week
1. [owner: __] — __ (source: __)
2. [owner: __] — __ (source: __)
3. [owner: __] — __ (source: __)

Q1 · AI marketing platforms for medical and dental practices
Lenses: [Competitor] [Category]
Run on: 2026-05-11
<paste HTML brief>

Q3 · Patient reactivation and no-show recovery for private practices
Lenses: [Sales]
Run on: 2026-05-11
<paste HTML brief>

Q5 · HIPAA marketing and patient data privacy 2026
Lenses: [Compliance]
Run on: 2026-05-11
<paste HTML brief>

Q7 · Independent medical practice growth challenges and staffing
Lenses: [Sales] [Content]
Run on: 2026-05-11
<paste HTML brief>

Q9 · Dental practice marketing and patient acquisition
Lenses: [Sales] [Content]
Run on: 2026-05-11
<paste HTML brief>

Triage log
- Sales hooks sent to Mike: __
- Competitor moves logged to sheet: __
- Content ideas added to queue: __
- Compliance flags raised: __

────────────────────────────────────────────────────────────

Week of 2026-05-18 — Set B

Top 3 actionables for Valor this week
1. [owner: __] — __ (source: __)
2. [owner: __] — __ (source: __)
3. [owner: __] — __ (source: __)

Q2 · PatientPop OR Tebra OR Weave OR NexHealth OR Doctible
Lenses: [Competitor]
Run on: 2026-05-18
<paste HTML brief>

Q4 · Website visitor identification and identity resolution healthcare
Lenses: [Sales] [Competitor]
Run on: 2026-05-18
<paste HTML brief>

Q6 · FTC healthcare advertising rules and patient testimonials
Lenses: [Compliance]
Run on: 2026-05-18
<paste HTML brief>

Q8 · AI chatbots and voice agents for patient intake
Lenses: [Content] [Competitor]
Run on: 2026-05-18
<paste HTML brief>

Q10 · Telehealth regulation state-by-state changes
Lenses: [Compliance] [Content]
Run on: 2026-05-18
<paste HTML brief>

Triage log
- Sales hooks sent to Mike: __
- Competitor moves logged to sheet: __
- Content ideas added to queue: __
- Compliance flags raised: __

────────────────────────────────────────────────────────────

Week of 2026-05-25 — Set A
[duplicate the Week of 2026-05-11 block above; bump dates]

────────────────────────────────────────────────────────────

Week of 2026-06-01 — Set B + monthly synthesis
[duplicate Week of 2026-05-18 block]

End-of-month synthesis — May 2026
Prompt to paste into the Valor Intel project:
"Read the four weeks above (2026-05-11, 05-18, 05-25, 06-01) and produce
the State of Valor's Market — May 2026 summary in ~500 words. Organize by
the four lenses. Pull the top theme per lens and 2–3 specific actionables
for next month."

<paste synthesis here>
```
