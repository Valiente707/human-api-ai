---
name: valor-intel
description: Run the Valor Promotions weekly intel routine — execute the active 5-query last30days set, tag every item with Valor's four lenses (Sales/Competitor/Content/Compliance), synthesize the Top 3 actionables, return HTML suitable for the Valor Intel Google Doc, and offer to post the Top 3 to #valor-intel-playbook on Slack. Use when the user says "run Valor Intel", "weekly intel", "Top 3 actionables", "valor-intel-playbook brief", or asks for community-signal research scoped to healthcare-AI / dental / private-practice marketing through Valor's four lenses. Composes with the upstream `last30days-skill` (must be loaded in the same project) and the Slack MCP.
---

# Valor Intel — Weekly Routine

A lightweight wrapper around `last30days-skill` that operationalizes the Valor Promotions weekly intel motion: 5 queries, four-lens tagging, Top 3 actionables, HTML output, optional Slack post.

## Prerequisites

- The upstream `last30days-skill` is loaded in the same claude.ai project (you'll invoke it as `/last30days <query>`).
- The Slack MCP is available with `slack_send_message`. Channel `#valor-intel-playbook` in `valor-promotions.slack.com` has channel ID `C0B2KJAUMQT`.
- Operator context: Valor Promotions Agents — veteran-owned AI growth engine for healthcare practices (medical, dental, private), led by Mike Gilbert.

## Query catalog

**Set A** (run on odd-numbered ISO weeks):

| # | Query | Default lenses |
|---|---|---|
| 1 | `AI marketing platforms for medical and dental practices` | Competitor, Category |
| 3 | `patient reactivation and no-show recovery for private practices` | Sales |
| 5 | `HIPAA marketing and patient data privacy 2026` | Compliance |
| 7 | `independent medical practice growth challenges and staffing` | Sales, Content |
| 9 | `dental practice marketing and patient acquisition` | Sales, Content |

**Set B** (run on even-numbered ISO weeks):

| # | Query | Default lenses |
|---|---|---|
| 2 | `PatientPop OR Tebra OR Weave OR NexHealth OR Doctible` | Competitor |
| 4 | `website visitor identification and identity resolution healthcare` | Sales, Competitor |
| 6 | `FTC healthcare advertising rules and patient testimonials` | Compliance |
| 8 | `AI chatbots and voice agents for patient intake` | Content, Competitor |
| 10 | `telehealth regulation state-by-state changes` | Compliance, Content |

If the operator doesn't specify a set, infer from the current ISO week number (odd → Set A, even → Set B).

## The four lenses

Tag every item with one or more bracketed labels:

- **[Sales]** — outreach angle: pain point trending now, quotable stat, lead-with story for healthcare prospects.
- **[Competitor]** — feature, pricing, hire, partnership, funding, or controversy from a named competitor (PatientPop / Tebra, Doctible, Weave, Solutionreach, NexHealth, Dialog Health) or new category challenger.
- **[Content]** — fuel for LinkedIn, blog, newsletter, sales-enablement.
- **[Compliance]** — HIPAA, FTC healthcare-advertising, state telehealth, or patient-data-privacy change.

## Routine

When invoked:

1. **Determine the set.** From the current ISO week (odd → A, even → B) unless the operator specifies otherwise. State which set is running and why before kicking off.
2. **Run the 5 queries.** For each query, call `/last30days <query>` and capture the returned brief.
3. **Tag inline.** After each brief, append bracketed lens labels to every item, e.g. `[Sales] [Content]`. Dedupe stories that appear on multiple platforms — cite the highest-engagement source.
4. **Synthesize Top 3.** After all 5 briefs are in, write a single "Top 3 actionables for Valor this week" block — three single-sentence bullets, each stating: the actionable, the owner (Mike / sales / content / compliance), and the source link.
5. **Assemble HTML output.** Use this exact structure:

   ```html
   <h2>Valor Intel — Week of YYYY-MM-DD (Set A|B)</h2>
   <h3>Top 3 actionables for Valor this week</h3>
   <ol>
     <li>[owner] — actionable. <a href="...">source</a></li>
     <li>...</li>
     <li>...</li>
   </ol>
   <hr/>
   <h3>Q# · query title — [lens] [lens]</h3>
   <ul><li>... [Sales]</li> ...</ul>
   <!-- repeat per query -->
   ```

6. **Print** the HTML for the operator to paste into the *Valor Intel — Brief Archive* Google Doc.
7. **Offer to post.** Ask: *"Post the Top 3 actionables to #valor-intel-playbook now?"* On yes, call the Slack MCP's `slack_send_message` with `channel_id="C0B2KJAUMQT"` and a message body containing only the Top 3 block (Slack mrkdwn formatting, not HTML), titled `Valor Intel — Week of YYYY-MM-DD`. For any item tagged `[Compliance]` that the operator flags as material, post it as a separate message titled `Compliance flag: <topic>`.

## Single-query mode

If the operator asks for one specific query (e.g., `run valor-intel for HIPAA marketing`), skip the set logic, run that query, return a single HTML block with lens-tagged items. Skip the Top 3 synthesis (it requires a full set); offer to post the single most-actionable item to Slack instead.

## Style

- Plain prose. No marketing fluff. Don't recap the methodology — get to the items.
- Quote real numbers (engagement counts, percentages, dollar figures) when sources include them.
- If a query returns thin signal, say so and suggest 1–2 alternate queries (specialty-specific: derm / ortho / vet; or topical: Medicare Advantage marketing, AI scribe vendors) instead of padding.
- Skip pure-consumer health content (general wellness, recipes, fitness influencers) unless it directly informs a marketing or compliance angle for independent practices.

## Failure modes

- **`/last30days` not available** → tell the operator the upstream skill must be loaded in this project; do not substitute generic web search.
- **Slack MCP not available** → print the formatted Slack message body so the operator can paste it manually into `#valor-intel-playbook`.
- **Query returns zero items** → note it in the HTML output and suggest a swap query for next week.

## Related files

- `../valor-intel-playbook.md` — full operator playbook (setup, runbook, KPIs, appendices with Custom instructions and Google Doc template).
- `../valor_intel_slack.py` — fallback webhook-based Slack notifier for headless automation.
