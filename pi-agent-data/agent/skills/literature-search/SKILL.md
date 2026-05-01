---
name: literature-search
description: Systematic search strategies for academic databases — prioritizing peer-reviewed sources via Google Scholar, Scopus, Semantic Scholar, OpenAlex, CrossRef, and arXiv (last resort) — with API usage patterns, citation tracking, and source quality tiers.
globs:
  - "**/*"
alwaysApply: false
---

# Literature Search

## 1. Search Strategy Overview

Every search begins with a clearly defined research question. Skipping this produces noisy results and wasted effort.

**Process:**

1. **Define the research question** — Write it as a focused, answerable question. If you cannot state it in one sentence, it is too broad.
2. **Extract keywords** — Identify the core concepts (2–5 terms). For each concept, list synonyms, broader terms, narrower terms, and discipline-specific variants.
3. **Construct boolean queries** — Combine terms using operators (see §3). Start narrow, broaden only when results are sparse.
4. **Select databases** — Search databases in priority order (see §2). Always start with Google Scholar or Scopus for peer-reviewed coverage. arXiv is a last resort.
5. **Execute searches** — Run queries in priority order, log everything (see §5), assess relevance, mark peer-reviewed status for every result.
6. **Chain citations** — Follow the citation graph forward and backward from seed papers (see §4).
7. **Deduplicate** — Merge results across databases (see §6).
8. **Evaluate quality** — Apply source quality tiers (see §7).
9. **Check preprints** — For any arXiv result, always check if a peer-reviewed version exists (see §2.7).
10. **Document** — Record every paper in the catalog (see §8).
11. **Stop** — Apply saturation criteria (see §10).

**Never search without a logged query.** If you cannot reproduce your search later, it did not happen.

**Search workflow (Phase 2 — execution):**

For each research question, query databases in this strict priority order:

1. **Google Scholar** — broadest coverage of peer-reviewed literature. Use `scholarly` Python library (free, rate-limited). Log peer-reviewed status per result.
2. **Scopus** — if `ELSEVIER_API_KEY` is set, query for structured metadata including venue and citation counts. Skip silently if key is unavailable.
3. **Semantic Scholar** — API-driven, excellent for citation graphs and detecting peer-reviewed versions. Check `venue` and `externalIds.DOI` fields.
4. **OpenAlex** — open, comprehensive, good for filtering by type and open access.
5. **CrossRef** — DOI resolution and journal metadata. Use to verify venue and peer-reviewed status.
6. **arXiv** — **LAST RESORT ONLY.** Search only after all other databases have been exhausted for a given query. Mark every arXiv result as "preprint — not peer-reviewed" and immediately check for a published version (§2.7).

After each database query, record results in the search log grouped by that query. Count peer-reviewed vs. preprint results. Do not proceed to the next database for a different query until the current query has been fully logged.

---

## 2. Database-Specific Search Instructions

### 2.1 Google Scholar

**Priority:** 1 (highest) — broadest coverage of peer-reviewed literature across all domains.

Google Scholar has no official API. Use the `scholarly` Python library:

```bash
pip install scholarly

python3 -c "
from scholarly import scholarly
results = scholarly.search_pubs('transformer attention mechanism')
for i, r in enumerate(results):
    if i >= 10: break
    print(f\"Title: {r['bib']['title']}\")
    print(f\"  Year: {r['bib'].get('pub_year', 'N/A')}\")
    print(f\"  Citations: {r.get('num_citations', 0)}\")
    print(f\"  URL: {r.get('pub_url', 'N/A')}\")
    print()
"
```

**Option C: `read` tool** — For individual papers found via other databases, use the `read` tool on the Scholar URL to extract metadata. This avoids scraping.

**Important caveats for Google Scholar:**
- Rate limiting is aggressive. Use delays of 10–30 seconds between requests with `scholarly`.
- `scholarly` may trigger CAPTCHAs. Use a proxy or the `use_proxy` option.
- Scholar metadata is less structured than other sources — always cross-reference DOI with CrossRef or Semantic Scholar.
- Scholar does not expose a DOI directly; extract it from the snippet and verify.
- Scholar results include preprints (arXiv, SSRN) alongside peer-reviewed work — always verify venue.

---

### 2.2 Scopus

**Priority:** 2 — structured metadata with verified venue, citation counts, and peer-reviewed status.

**Base URL:** `https://api.elsevier.com/content/search/scopus`

**Rate limits:** 2 requests/second with API key. Skip entirely if `ELSEVIER_API_KEY` is not set.

**Search papers:**

```bash
# Requires ELSEVIER_API_KEY env var
curl -s -H "X-ELS-APIKey: $ELSEVIER_API_KEY" \
  "https://api.elsevier.com/content/search/scopus?query=TITLE-ABS-KEY(transformer+attention+mechanism)&count=10&sort=citedby-count" | jq .
```

**Query syntax:**
- `TITLE` — title field
- `ABS` — abstract field
- `KEY` — keywords
- `TITLE-ABS-KEY` — all three combined
- Boolean: `AND`, `OR`, `ANDNOT`, `W/n` (within n words)
- Phrase: `{transformer architecture}` (curly braces for exact phrase)

```bash
# Exact phrase in title
curl -s -H "X-ELS-APIKey: $ELSEVIER_API_KEY" \
  "https://api.elsevier.com/content/search/scopus?query=TITLE(%7Battention+is+all+you+need%7D)&count=5" | jq .

# Date range filter
curl -s -H "X-ELS-APIKey: $ELSEVIER_API_KEY" \
  "https://api.elsevier.com/content/search/scopus?query=TITLE-ABS-KEY(neural+networks)+AND+PUBYEAR+AFT+2020+AND+PUBYEAR+BEF+2024&count=10&sort=citedby-count" | jq .

# Document type filter (only articles and reviews)
curl -s -H "X-ELS-APIKey: $ELSEVIER_API_KEY" \
  "https://api.elsevier.com/content/search/scopus?query=TITLE-ABS-KEY(machine+learning)&doctype=ar,re&count=10" | jq .
```

**Retrieve paper details by Scopus EID or DOI:**

```bash
# By DOI
curl -s -H "X-ELS-APIKey: $ELSEVIER_API_KEY" \
  "https://api.elsevier.com/content/search/scopus?query=DOI(10.1038/nature12373)" | jq .

# By Scopus ID
curl -s -H "X-ELS-APIKey: $ELSEVIER_API_KEY" \
  "https://api.elsevier.com/content/abstract/scopus_id/84941681268" | jq .
```

**Key response fields:** `dc:identifier` (Scopus ID), `dc:title`, `dc:creator`, `prism:publicationName` (venue), `prism:doi`, `citedby-count`, `prism:coverDate`, `subtype` (article type: `ar`=article, `re`=review, `cp`=conference paper, `ch`=book chapter).

**Important:** Scopus explicitly tracks peer-reviewed status via venue metadata. Results from Scopus-indexed journals and conferences are peer-reviewed by default. Use `subtype` and `prism:publicationName` to confirm.

---

### 2.3 Semantic Scholar

**Priority:** 3 — API-driven, excellent for citation graphs and metadata enrichment. Key strength: detecting peer-reviewed versions of arXiv preprints.

**Base URL:** `https://api.semanticscholar.org/graph/v1`

**Rate limits:** 100 requests/5 min (unauthenticated). Register for API key at https://www.semanticscholar.org/product/api#api-key for higher limits.

**Search papers:**

```bash
curl -s "https://api.semanticscholar.org/graph/v1/paper/search?query=transformer+attention+mechanism&limit=10&fields=title,authors,year,abstract,citationCount,externalIds,url,venue,publicationTypes" | jq .
```

**Paper details by Semantic Scholar ID:**

```bash
curl -s "https://api.semanticscholar.org/graph/v1/paper/649def34f8be52c8b66281af98ae884c09aef38b?fields=title,authors,year,abstract,citationCount,references,citations,externalIds,venue,publicationTypes" | jq .
```

**Paper details by DOI:**

```bash
curl -s "https://api.semanticscholar.org/graph/v1/paper/DOI:10.1038/nature12373?fields=title,authors,year,abstract,citationCount,externalIds,venue,publicationTypes" | jq .
```

**Paper details by arXiv ID:**

```bash
curl -s "https://api.semanticscholar.org/graph/v1/paper/ARXIV:1706.03762?fields=title,authors,year,abstract,citationCount,externalIds,venue,publicationTypes" | jq .
```

**Backward citations (references — who this paper cites):**

```bash
curl -s "https://api.semanticscholar.org/graph/v1/paper/649def34f8be52c8b66281af98ae884c09aef38b/references?fields=title,authors,year,citationCount,externalIds,venue&limit=100" | jq .
```

**Forward citations (who cites this paper):**

```bash
curl -s "https://api.semanticscholar.org/graph/v1/paper/649def34f8be52c8b66281af98ae884c09aef38b/citations?fields=title,authors,year,citationCount,externalIds,venue&limit=100" | jq .
```

**Author search:**

```bash
curl -s "https://api.semanticscholar.org/graph/v1/author/search?query=Ashish+Vaswani&limit=5" | jq .
```

**Author details and papers:**

```bash
curl -s "https://api.semanticscholar.org/graph/v1/author/1741102?fields=name,paperCount,hIndex,papers.title,papers.year,papers.citationCount" | jq .
```

**Bulk search (for systematic reviews):**

```bash
curl -s -X POST "https://api.semanticscholar.org/graph/v1/paper/search/bulk" \
  -H "Content-Type: application/json" \
  -d '{"query":"neural machine translation","fields":"title,authors,year,abstract,citationCount,externalIds,venue,publicationTypes"}' | jq .
```

**Key fields to request:** `title`, `authors`, `year`, `abstract`, `citationCount`, `externalIds` (contains DOI, arXivId, PubMedId), `url`, `venue`, `publicationTypes`.

**Peer-reviewed detection:** A paper is peer-reviewed if `venue` is non-empty and not "arXiv" / "CoRR", or if `publicationTypes` includes `"JournalArticle"` or `"Conference"`. An arXiv paper with both an `arXivId` and a `DOI` in `externalIds` likely has a published version.

---

### 2.4 OpenAlex

**Priority:** 4 — open, comprehensive, good for filtering by work type and open access status.

**Base URL:** `https://api.openalex.org`

**Rate limits:** 10 requests/second. Include `mailto` parameter for the polite pool (faster, more reliable).

**Search works:**

```bash
curl -s "https://api.openalex.org/works?search=transformer+attention+mechanism&per_page=10&mailto=your-email@example.com" | jq .
```

**Filter syntax** — Use `filter` parameter with comma-separated `key:value` pairs:

```bash
# Filter by concept/level
curl -s "https://api.openalex.org/works?filter=concepts.id:C154945302,from_publication_date:2020-01-01&per_page=10&mailto=your-email@example.com" | jq .

# Filter by author
curl -s "https://api.openalex.org/works?filter=author.id:A5023848391&per_page=10&mailto=your-email@example.com" | jq .

# Filter by type and open access — article is peer-reviewed, posted_content is not
curl -s "https://api.openalex.org/works?filter=type:article,is_oa:true&search=machine+learning&per_page=10&mailto=your-email@example.com" | jq .

# Citation count filter
curl -s "https://api.openalex.org/works?filter=cited_by_count:>100,from_publication_date:2022-01-01&per_page=10&mailto=your-email@example.com" | jq .
```

**Concept IDs** — Find concept IDs by searching:

```bash
curl -s "https://api.openalex.org/concepts?search=machine+learning&per_page=5&mailto=your-email@example.com" | jq '.results[] | {id, display_name, level, works_count}'
```

**Author search:**

```bash
curl -s "https://api.openalex.org/authors?search=Ashish+Vaswani&per_page=5&mailto=your-email@example.com" | jq '.results[] | {id, display_name, works_count, cited_by_count, h_index}'
```

**Citation chaining — backward (referenced works):**

```bash
curl -s "https://api.openalex.org/works/W4242298634?select=id,title,referenced_works&mailto=your-email@example.com" | jq .
# Then fetch the referenced works in bulk
curl -s "https://api.openalex.org/works?filter=openalex:W4242298634|W1234567890|W9876543210&per_page=50&mailto=your-email@example.com" | jq .
```

**Citation chaining — forward (citing works):**

```bash
curl -s "https://api.openalex.org/works?filter=cites:W4242298634&per_page=25&mailto=your-email@example.com" | jq .
```

**Key fields:** `id` (OpenAlex ID), `doi`, `title`, `authorships`, `concepts`, `cited_by_count`, `referenced_works`, `cited_by_api_url`, `type`, `publication_year`, `open_access`.

**Peer-reviewed detection:** `type` values `"article"`, `"book-chapter"`, `"book"`, or `"peer-review"` indicate peer-reviewed works. `type: "posted-content"` typically indicates preprints.

---

### 2.5 CrossRef

**Priority:** 5 — DOI resolution and journal metadata. Use to verify venue and peer-reviewed status.

**Base URL:** `https://api.crossref.org`

**Rate limits:** 50 requests/second (with polite pool header). Without the header: heavily rate-limited. **Always include the `mailto` parameter.**

**Search works:**

```bash
curl -s "https://api.crossref.org/works?query=transformer+attention+mechanism&rows=10&mailto=your-email@example.com" | jq .
```

**DOI lookup:**

```bash
curl -s "https://api.crossref.org/works/10.1038/nature12373?mailto=your-email@example.com" | jq .
```

**Filter syntax** — Separate multiple filters with commas. Use `funders`, `from-pub-date`, `type`, `has-abstract`, etc.

```bash
# Filter by publication date range and type — journal-article is peer-reviewed
curl -s "https://api.crossref.org/works?query=neural+networks&filter=from-pub-date:2020,type:journal-article&rows=20&mailto=your-email@example.com" | jq .

# Filter by funder (e.g., NSF)
curl -s "https://api.crossref.org/works?filter=funder:10.13039/100000001&rows=10&mailto=your-email@example.com" | jq .

# Only works with abstracts
curl -s "https://api.crossref.org/works?query=transformer&filter=has-abstract:true&rows=10&mailto=your-email@example.com" | jq .
```

**Faceted search** — Get breakdown of results by a facet (year, journal, funder):

```bash
curl -s "https://api.crossref.org/works?query=transformer&facet=container-title:*,published-date:*&rows=0&mailto=your-email@example.com" | jq '.message.facets'
```

**Sort options:** `score` (relevance), `published-date`, `is-referenced-by-count` (citations), `deposited-date`.

```bash
curl -s "https://api.crossref.org/works?query=deep+learning&sort=is-referenced-by-count&order=desc&rows=10&mailto=your-email@example.com" | jq .
```

**Key response fields:** `DOI`, `title`, `author`, `published-print`, `published-online`, `container-title` (journal), `is-referenced-by-count` (citations received), `references` (if available), `link` (URLs to full text), `type`.

**Peer-reviewed detection:** `type` values `journal-article`, `proceedings-article`, `book-chapter` indicate peer-reviewed works. `type: posted-content` or `type: report` typically indicate non-peer-reviewed.

---

### 2.6 arXiv

**Priority:** 6 (LAST RESORT) — Search arXiv only after all other databases have been exhausted for a given query. arXiv papers are preprints and are **not peer-reviewed**.

> **WARNING: arXiv papers are not peer-reviewed.**
>
> arXiv is a preprint server. Papers on arXiv have not undergone formal peer review. Every arXiv result must be:
> 1. Clearly marked as "preprint — not peer-reviewed" in your search log and catalog.
> 2. Cross-referenced against Semantic Scholar or Google Scholar to check if a published, peer-reviewed version exists (see §2.7).
> 3. Assigned to Tier 3 by default unless a peer-reviewed version is found (see §7).
>
> Do not cite an arXiv preprint when a peer-reviewed version of the same paper exists. Always prefer the published version.

**Base URL:** `http://export.arxiv.org/api/query`

**Rate limits:** 1 request per 3 seconds. Respect this strictly — arXiv will block aggressive clients.

**Search papers:**

```bash
curl -s "http://export.arxiv.org/api/query?search_query=all:transformer+AND+all:attention&start=0&max_results=10&sortBy=relevance&sortOrder=descending" | xmllint --format -
```

**Query syntax:**
- Prefixes: `ti` (title), `au` (author), `abs` (abstract), `cat` (category), `all` (all fields)
- Operators: `AND`, `OR`, `ANDNOT`
- Grouping: parentheses

```bash
# Title search
curl -s "http://export.arxiv.org/api/query?search_query=ti:%22attention+is+all+you+need%22&max_results=5" | xmllint --format -

# Author search
curl -s "http://export.arxiv.org/api/query?search_query=au:Vaswani&max_results=10" | xmllint --format -

# Category filter (cs.CL = Computation and Language)
curl -s "http://export.arxiv.org/api/query?search_query=cat:cs.CL+AND+ti:transformer&max_results=10" | xmllint --format -

# Complex boolean
curl -s "http://export.arxiv.org/api/query?search_query=(ti:transformer+OR+ti:attention)+ANDNOT+cat:physics&max_results=10" | xmllint --format -
```

**Common arXiv categories:**
- `cs.AI` — Artificial Intelligence
- `cs.CL` — Computation and Language
- `cs.CV` — Computer Vision
- `cs.LG` — Machine Learning
- `cs.NE` — Neural and Evolutionary Computing
- `stat.ML` — Machine Learning (Statistics)

**Parsing XML responses** — Use `jq` after converting with `xq` (from `yq` package) or parse directly:

```bash
curl -s "http://export.arxiv.org/api/query?search_query=ti:transformer&max_results=5" | \
  xq '.feed.entry[] | {id: .id, title: .title, summary: .summary, authors: [.author[].name], published: .published}'
```

**Get paper by arXiv ID:**

```bash
curl -s "http://export.arxiv.org/api/query?id_list=1706.03762" | xmllint --format -
```

**Pagination:** Use `start` and `max_results`. Maximum `max_results` is 2000 per request. Total results in `<opensearch:totalResults>`.

---

### 2.7 Finding Peer-Reviewed Versions of Preprints

When you find a paper on arXiv (or any preprint source), **always check if a peer-reviewed version exists** before adding it to your catalog. This is mandatory, not optional.

**Step 1: Check Semantic Scholar for a published version.**

Semantic Scholar indexes both arXiv preprints and their published versions. The `externalIds` field reveals if an arXiv paper has a DOI (indicating formal publication). The `venue` field reveals if the paper appeared in a journal or conference.

```bash
# Look up an arXiv paper on Semantic Scholar
ARXIV_ID="1706.03762"
curl -s "https://api.semanticscholar.org/graph/v1/paper/ARXIV:$ARXIV_ID?fields=title,authors,year,abstract,citationCount,externalIds,venue,publicationTypes,influentialCitationCount" | jq .
```

**What to check in the response:**

```bash
# Extract peer-reviewed indicators
curl -s "https://api.semanticscholar.org/graph/v1/paper/ARXIV:$ARXIV_ID?fields=externalIds,venue,publicationTypes" | \
  jq '{
    doi: .externalIds.DOI,
    arxiv_id: .externalIds.ArXiv,
    venue: .venue,
    publication_types: .publicationTypes,
    is_peer_reviewed: ((.venue != null and .venue != "" and .venue != "arXiv" and .venue != "CoRR") or (.externalIds.DOI != null and .externalIds.DOI != ""))
  }'
```

**Interpretation:**
- If `externalIds.DOI` is present **and** `venue` is a recognized journal/conference name (not "arXiv", "CoRR", or empty) → the paper has been published in a peer-reviewed venue. Use the DOI version.
- If `externalIds.DOI` is present but `venue` is empty → check the DOI on CrossRef to confirm (see Step 2).
- If `publicationTypes` includes `"JournalArticle"` or `"Conference"` → peer-reviewed.
- If only `ArXiv` is in `externalIds` and `venue` is empty or "arXiv" → no published version found. Paper remains Tier 3.

**Step 2: Verify DOI on CrossRef.**

```bash
# If a DOI was found, verify it on CrossRef for venue and peer-reviewed status
DOI="10.5555/3454283"
curl -s "https://api.crossref.org/works/$DOI?mailto=your-email@example.com" | \
  jq '.message | {title: .title[0], container_title: .container-title[0], type: .type, published: .published-print}'
```

**Step 3: Check Google Scholar for a published version.**

If Semantic Scholar does not show a DOI or venue, search Google Scholar by title:

```bash
# Using scholarly library
python3 -c "
from scholarly import scholarly
results = scholarly.search_pubs('Attention Is All You Need')
for i, r in enumerate(results):
    if i >= 5: break
    bib = r.get('bib', {})
    print(f'Title: {bib.get(\"title\", \"N/A\")}')
    print(f'Venue: {bib.get(\"venue\", \"N/A\")}')
    print(f'Year: {bib.get(\"pub_year\", \"N/A\")}')
    print()
"
```

Check `pub_info` for a journal or conference name (not just "arXiv").

**Step 4: Update the catalog entry.**

When a peer-reviewed version is found:
- Set `peer_reviewed: true` in the catalog.
- Set `peer_reviewed_version` to the DOI or URL of the published version.
- Update `source` to the published venue name.
- Update `source_type` to `journal-article` or `conference-paper`.
- Re-tier the paper based on venue quality (see §7).

When no peer-reviewed version is found:
- Set `peer_reviewed: false`.
- Set `peer_reviewed_version: "N/A"`.
- Keep `source_type: preprint`.
- Paper remains at Tier 3 (or Tier 2 if citation count is high enough per §7).

---

## 3. Boolean Query Construction

| Operator | Meaning | Example |
|----------|---------|---------|
| `AND` | Both terms must appear | `transformer AND attention` |
| `OR` | Either term appears | `neural OR deep learning` |
| `NOT` | Exclude term | `apple NOT fruit` |
| `"..."` | Exact phrase | `"attention is all you need"` |
| `*` | Wildcard (varies by DB) | `transform*` (transform, transformers, transformation) |
| `NEAR/n` | Within n words (CrossRef) | `machine NEAR/3 learning` |

**Database-specific syntax:**

| Database | AND | OR | NOT | Phrase | Wildcard |
|----------|-----|----|-----|--------|----------|
| Google Scholar (scholarly) | space | `OR` | `-` (hyphen prefix) | `"..."` | `*` |
| Scopus | `AND` | `OR` | `ANDNOT` | `{...}` (curly braces) | `*` |
| Semantic Scholar | `+` (space-separated) | `+OR+` | N/A | `"..."` | `*` |
| arXiv | `AND` | `OR` | `ANDNOT` | `"..."` | `*` (limited) |
| CrossRef | space (implicit AND) | `|` (in filters) | N/A | `"..."` | `*` |
| OpenAlex | space (implicit AND) | `|` (in filter values) | `-` (exclude) | `"..."` | `*` |

**Query refinement pattern:**

1. Start with the core terms: `transformer AND attention`
2. If too many results: add specificity: `transformer AND "attention mechanism" AND "neural network"`
3. If too few: broaden with synonyms: `(transformer OR "self-attention") AND (neural OR deep)`
4. If still too few: remove the least important term or use OR extensively
5. If off-topic noise: add NOT terms: `transformer AND attention NOT power NOT electrical`

---

## 4. Citation Chaining Strategy

### Backward Chaining (who does this paper cite?)

Start with a seed paper and trace its references. This finds foundational work.

```bash
# Semantic Scholar
SEED_ID="649def34f8be52c8b66281af98ae884c09aef38b"
curl -s "https://api.semanticscholar.org/graph/v1/paper/$SEED_ID/references?fields=title,authors,year,citationCount,externalIds,venue&limit=100" | jq '.data[].citedPaper | select(.citationCount > 100) | {title, year, citationCount, doi: .externalIds.DOI, venue}'

# OpenAlex
SEED_OA="W4242298634"
curl -s "https://api.openalex.org/works?filter=cites:$SEED_OA&per_page=25&mailto=your-email@example.com" | jq '.results[] | {title, doi, cited_by_count}'
```

### Forward Chaining (who cites this paper?)

Find recent work that builds on the seed. This finds state-of-the-art.

```bash
# Semantic Scholar
curl -s "https://api.semanticscholar.org/graph/v1/paper/$SEED_ID/citations?fields=title,authors,year,citationCount,externalIds,venue&limit=100" | jq '.data[].citingPaper | select(.year > 2022) | {title, year, citationCount, venue}'

# OpenAlex
curl -s "https://api.openalex.org/works?filter=cites:$SEED_OA&per_page=25&sort=cited_by_count:desc&mailto=your-email@example.com" | jq '.results[] | {title, publication_year, cited_by_count}'
```

### Snowball Search Pattern

1. Start with 3–5 seed papers from initial keyword search.
2. For each seed: backward chain → collect high-citation references.
3. For each seed: forward chain → collect recent high-citation citing works.
4. Add newly discovered papers as seeds. Repeat.
5. Stop when new iterations yield <5 novel papers not already in your database.

---

## 5. Search Documentation

**Always log searches.** Create a search log alongside your catalog.

**Format** — append to `literature/search-log.md`:

```markdown
## Search: [YYYY-MM-DD HH:MM]

**Research question:** [your question]
**Database:** [Google Scholar | Scopus | Semantic Scholar | OpenAlex | CrossRef | arXiv]
**Query:** [exact query string used]
**Filters:** [any filters applied]
**Results:** [count] total, [count] peer-reviewed, [count] preprints
**Top finds:**
  1. [CitationKey] — [Title] ([Venue], [Year]) — Citations: N — Peer-reviewed: ✅/❌
  2. [CitationKey] — [Title] ([Venue], [Year]) — Citations: N — Peer-reviewed: ✅/❌
  3. ...
**Notes:** [observations about result quality, gaps, adjustments needed]
```

**Result grouping:** Results must be grouped by search query. Each database query gets its own entry. Do not combine results from different queries or databases into a single entry.

**Why this matters:**
- Systematic reviews require reproducible search strategies.
- You will forget what you searched and what you missed.
- Future-you (or a reviewer) needs to verify coverage.
- Peer-reviewed vs. preprint counts reveal how much of your evidence base is formally reviewed.

---

## 6. Deduplication

When aggregating across databases, deduplicate before screening.

**Priority order for deduplication keys:**

1. **DOI** — most reliable. Normalize by lowercasing and removing `https://doi.org/` prefix.
2. **Semantic Scholar paper ID** — stable, unique, covers papers without DOI.
3. **arXiv ID** — stable for preprints. Combine with DOI when both exist.
4. **Title similarity** — last resort. Use fuzzy matching (Levenshtein ratio > 0.85). Normalize first: lowercase, strip punctuation, collapse whitespace.

```bash
# Deduplicate by DOI from a JSON results file
cat results.json | jq -s '[.[][] | {doi: .externalIds.DOI, s2id: .paperId, title: .title}] | unique_by(.doi // .s2id // .title)'
```

**Workflow:**
1. Collect all results into a single JSON file.
2. Sort by deduplication key priority.
3. For each paper, check if a matching key already exists in the catalog.
4. If exists: merge metadata (keep richer abstract, add missing fields, prefer peer-reviewed version over preprint).
5. If new: add to catalog.

**Preprint vs. published deduplication:** When the same paper appears as both an arXiv preprint and a peer-reviewed publication (matching DOI or title), always keep the peer-reviewed version. Merge metadata from both, but set `peer_reviewed: true`, use the published venue as `source`, and record the arXiv ID in `arxiv_id` for reference.

---

## 7. Source Quality Tiers

Every paper in the catalog must be assigned a quality tier. The tier determines how much weight to give the paper in your literature review and which papers to prioritize.

### Tier 1 — Peer-reviewed (strong evidence)

- Journal articles in peer-reviewed journals (verified via CrossRef or Scopus venue metadata)
- Conference proceedings from selective venues (acceptance rate < 30%)
- Book chapters in scholarly edited volumes from academic publishers

**Verification:** Confirm via `venue` field (Semantic Scholar), `container-title` (CrossRef), or `prism:publicationName` (Scopus). A non-empty venue that is not "arXiv" or "CoRR" indicates peer review.

### Tier 2 — Cited preprints and technical reports (moderate evidence)

- Preprints with significant citation counts: >50 for CS/AI, >20 for niche fields
- Industry technical reports from established research labs (e.g., Google Research, Meta AI, DeepMind)
- Workshop papers with some community validation
- Preprints from Tier 1 venues that are under review (check for "submitted to" or "under review" in abstract)

**Note:** A preprint can be Tier 2 only if it has accumulated enough citations to suggest community vetting. Citation count alone is not peer review, but it is a signal of scrutiny.

### Tier 3 — Uncited or low-citation preprints (use with caution)

- Uncited preprints older than 6 months
- Preprints with very few citations (<10 for CS/AI, <5 for niche)
- Non-reviewed reports, white papers, blog posts
- arXiv papers **default to Tier 3** unless a peer-reviewed version is found

**Exception:** Preprints less than 6 months old from known research labs may be acceptable as Tier 3 if they address a directly relevant topic and no peer-reviewed alternative exists. Flag them clearly.

### Tier promotion rules

- An arXiv paper with a confirmed peer-reviewed version is promoted to **Tier 1** (if journal article or top conference) or **Tier 2** (if workshop or lower-selectivity venue), based on the published venue.
- A Tier 3 preprint that accumulates sufficient citations may be promoted to **Tier 2**. Re-evaluate periodically.
- No paper is ever promoted to Tier 1 without verified peer review.

### Evaluation checklist per paper

| Criterion | How to check |
|-----------|-------------|
| Peer-reviewed status | `venue` (Semantic Scholar), `container-title` + `type` (CrossRef), `prism:publicationName` + `subtype` (Scopus) |
| Citation count | Semantic Scholar `citationCount`, CrossRef `is-referenced-by-count`, OpenAlex `cited_by_count`, Scopus `citedby-count` |
| Venue quality | CrossRef `container-title`, look up JCR/SJR, Scopus `source_id` metrics |
| Author h-index | Semantic Scholar author endpoint, OpenAlex author `h_index` |
| Recency | `publication_year` or `year` field |
| Methodology rigor | Read abstract/methods section — check for controlled experiments, sample size, reproducibility |
| Reproducibility | Check for code/data availability, registered reports |
| Published version exists | §2.7 workflow — check `externalIds.DOI` and `venue` on Semantic Scholar |

---

## 8. Literature Directory and Catalog

### Directory structure

```
literature/
  papers/          # Downloaded PDFs
  notes/           # Reading notes (one per paper)
  catalog.md       # Central tracking file (replaces citations.md)
  search-log.md    # Search reproducibility log
```

### Catalog format

Store paper entries in `literature/catalog.md` using the following template. Each entry is a subsection with a heading. This replaces the old `citations.md` with YAML frontmatter.

**Template:**

```markdown
### [AuthorYear_Keyword]

- **citation_key**: AuthorYear_Keyword
- **authors**: Full author list
- **title**: Full paper title
- **year**: YYYY
- **source**: Venue name (journal, conference, or "arXiv" for preprints)
- **source_type**: journal-article | conference-paper | book-chapter | preprint | thesis | report
- **peer_reviewed**: true | false
- **doi**: 10.xxxx/xxxxx (or "N/A")
- **url**: Direct link
- **arxiv_id**: XXXX.XXXXX (or "N/A")
- **abstract**: Full abstract
- **citation_count**: N (as of date)
- **influential_citation_count**: N
- **cited_because**: Why this paper matters for the project
- **relevance_score**: 1-5
- **used_in_sections**: Which thesis sections this supports
- **search_query**: The query and database that found this paper
- **date_added**: YYYY-MM-DD
- **download_status**: downloaded | pending | unavailable | needs_manual
- **local_file**: papers/AuthorYear_Keyword.pdf (or "N/A" if not downloaded)
- **key_findings**: 2-4 bullet points
- **methodology_notes**: Brief method notes
- **personal_notes**: Connections, questions, ideas
- **peer_reviewed_version**: DOI/URL of published version if original was preprint (or "N/A")
```

**Example entry:**

```markdown
### Vaswani2017_Attention

- **citation_key**: Vaswani2017_Attention
- **authors**: Vaswani, Ashish; Shazeer, Noam; Parmar, Niki; Uszkoreit, Jakob; Jones, Llion; Gomez, Aidan N.; Kaiser, Lukasz; Polosukhin, Illia
- **title**: "Attention Is All You Need"
- **year**: 2017
- **source**: NeurIPS
- **source_type**: conference-paper
- **peer_reviewed**: true
- **doi**: "N/A"
- **url**: "https://papers.nips.cc/paper/2017/hash/3f5ee243547dee91fbd053c1c4a845aa-Abstract.html"
- **arxiv_id**: "1706.03762"
- **abstract**: The dominant sequence transduction models are based on complex recurrent or convolutional neural networks. We propose a new simple network architecture, the Transformer, based solely on attention mechanisms...
- **citation_count**: 120000
- **influential_citation_count**: 4500
- **cited_because**: Foundation paper for transformer architecture; essential background for any work on attention mechanisms.
- **relevance_score**: 5
- **used_in_sections**: background, methodology
- **search_query**: "transformer attention mechanism" — Google Scholar
- **date_added**: 2025-01-15
- **download_status**: downloaded
- **local_file**: papers/Vaswani2017_Attention.pdf
- **key_findings**:
  - Self-attention can replace recurrence for sequence modeling
  - Multi-head attention enables capturing different representation subspaces
  - Transformer achieves SOTA on WMT 2014 EN-DE and EN-FR
- **methodology_notes**: Encoder-decoder architecture, multi-head attention, positional encoding. Training: 8 P100 GPUs, 3.5 days.
- **personal_notes**: The core reference for our transformer variant. Key equations: scaled dot-product attention (Eq 1), multi-head attention (Eq 2).
- **peer_reviewed_version**: "N/A" (already peer-reviewed at NeurIPS)
```

**Rules for citation keys:** `AuthorYYYYKeyword` — first author last name, year, first meaningful word from title. PascalCase. Example: `Vaswani2017Attention` or `Vaswani2017_Attention`.

---

## 9. Rate Limiting and API Etiquette

| Service | Rate Limit | Polite Pool | Notes |
|---------|-----------|-------------|-------|
| Google Scholar | Aggressive anti-bot | N/A | Use `scholarly` with delays (10–30 sec). No API alternative. |
| Scopus | 9 req/s throttle, 20k/week quota (API key) | API key required | Use conservative 1 req/2s to avoid flagging. Check `X-RateLimit-Remaining` headers. |
| Semantic Scholar | 100 req/5 min (no key) | API key → 1 req/sec | Use conservative 1 req/2s to avoid flagging |
| OpenAlex | 10 req/sec | Add `mailto` param | Use conservative 1 req/3s to avoid flagging |
| CrossRef | ~50 req/sec | Add `mailto` param | Without `mailto`: throttled to slower pool |
| arXiv | 1 req/3 sec | N/A | Use conservative 1 req/5s to avoid flagging |

**General rules:**

1. **Always identify yourself.** Use `mailto` or `User-Agent` headers where supported.
2. **Cache aggressively.** Never re-fetch a paper you already have. Check your catalog first.
3. **Batch when possible.** Semantic Scholar bulk endpoint, OpenAlex `|`-separated filter values, arXiv `id_list`.
4. **Respect `Retry-After` headers.** If you get a 429, stop and wait.
5. **Never parallelize beyond rate limits.** A script that spawns 20 concurrent curl processes against arXiv will get your IP blocked.

```bash
# Proper rate-limited arXiv search loop
for i in $(seq 0 10 200); do
  curl -s "http://export.arxiv.org/api/query?search_query=cat:cs.CL&start=$i&max_results=10"
  sleep 5
done
```

---

## 10. When to Stop Searching

**Saturation criteria — stop when all of these are true:**

1. **No new relevant papers in the last 2 search iterations.** If the last 20 results contain zero papers you would add to your catalog, you are saturated.
2. **Citation chains converge.** Forward and backward chaining from your seed papers keeps returning papers already in your catalog.
3. **Key authors exhausted.** The most-cited authors in your results have had their recent work checked.
4. **All major databases covered.** You have searched at least 3 of the 6 databases for your core query. arXiv is only required if no other database returned sufficient results.

**Quantitative check:**

```bash
# Count unique papers in your catalog
grep -c "^- \*\*citation_key\*\*:" literature/catalog.md

# Count new papers from latest search batch
# If this number is <5% of total, consider stopping
```

**Diminishing returns threshold:**

| Database results screened | Expected relevant papers |
|--------------------------|------------------------|
| First 50 | ~15–25 (30–50%) |
| 50–200 | ~5–15 (3–8%) |
| 200–500 | ~1–5 (0.5–2%) |
| 500+ | <1 per 100 screened |

If you have screened 200+ results and the inclusion rate has dropped below 2%, stop. Document the stopping decision in your search log with the criteria that triggered it.

**Exceptions — do not stop if:**
- A new concept or methodology has emerged that changes the search space
- A reviewer or advisor has identified a gap in your coverage
- You are preparing for a systematic review (pre-registered protocol) — follow PRISMA guidelines instead