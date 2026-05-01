---
name: literature-retrieval
description: Retrieve and download academic papers from Anna's Archive (JSON API), arXiv, Semantic Scholar, Unpaywall, and other open access sources. Organize into a project literature library with download status tracking.
globs:
  - "**/*"
alwaysApply: false
---

# Literature Retrieval Skill

Retrieve and download academic papers from open access sources. Organize them into a project's `literature/` directory with consistent naming, verified integrity, and status tracking in `catalog.md`.

## Directory Structure

```
literature/
  papers/          # Downloaded PDFs
  notes/           # Reading notes (one per paper)
  catalog.md       # Central tracking file (download status, metadata)
  search-log.md    # Search reproducibility log
```

## Prerequisites

- `curl` — HTTP client for all downloads and API calls
- Internet access — all sources are remote
- `literature/papers/` directory — must exist before downloads begin; create if missing:

```bash
mkdir -p literature/papers literature/notes
```

- `ANNAS_SECRET_KEY` environment variable — required for Anna's Archive JSON API (obtained by donating)
- `ELSEVIER_API_KEY` environment variable — optional, for Scopus metadata verification

Optional but recommended:
- `pdftotext` (poppler-utils) — extract text from PDFs for verification
- `exiftool` (libimage-exiftool-perl) — read PDF metadata
- `python3` — parse JSON API responses, URL-encode queries

## Download Source Priority

Try sources in this order for each paper:

| Priority | Source | When to Use | Reliability | CAPTCHA Risk |
|----------|--------|-------------|-------------|--------------|
| 1 | **Local check** | File already downloaded | N/A | None |
| 2 | **Anna's Archive JSON API** | Books, papers, widest catalog (requires donor key) | Very high | None |
| 3 | **Anna's Archive HTML** | Fallback when JSON API unavailable | High | Yes (Cloudflare) |
| 4 | **arXiv** | Only when arXiv ID is known | Very high | None |
| 5 | **Semantic Scholar** | Papers with `openAccessPdf` | High | None |
| 6 | **Unpaywall** | When DOI is known (legal OA) | Medium | None |
| 7 | **Publisher Direct** | Only confirmed open access | Low | Varies |
| 8 | **Report unavailable** | All sources exhausted | N/A | N/A |

## 1. Anna's Archive

General-purpose shadow library aggregator. Best for books and many papers. **Primary download source — try this first for every paper.**

### JSON API (Recommended — requires donor membership)

If you have an Anna's Archive secret key (obtained by donating), use the JSON API for reliable, CAPTCHA-free downloads.

**Environment variable:** `ANNAS_SECRET_KEY` — your donor secret key.

**Domain fallback:** Try `annas-archive.gl` → `annas-archive.gd` → `annas-archive.pk`

**Step 1: Find the MD5 hash by searching**

```bash
# Search by title
curl -s -L "https://annas-archive.gl/search?q=$(python3 -c "import urllib.parse; print(urllib.parse.quote('bayesian data analysis gelman'))")" \
  -o /tmp/anna-search.html

# Search by ISBN
curl -s -L "https://annas-archive.gl/search?q=9781431997824" \
  -o /tmp/anna-isbn.html

# Search by DOI
curl -s -L "https://annas-archive.gl/search?q=10.1016/j.jml.2011.08.004" \
  -o /tmp/anna-doi.html
```

Extract MD5 hashes from result links (pattern: `/md5/<32-char-hex>`).

**Step 2: Get fast download URL via JSON API**

```bash
MD5="<32-char-md5-hash>"
ANNAS_KEY="${ANNAS_SECRET_KEY}"

for DOMAIN in annas-archive.gl annas-archive.gd annas-archive.pk; do
  # Get fast download URL via JSON API
  HTTP_CODE=$(curl -s -o /tmp/anna-fast-dl.json -w "%{http_code}" \
    -H "X-Annas-Secret-Key: ${ANNAS_KEY}" \
    "https://${DOMAIN}/dyn/api/fast_download.json?md5=${MD5}")

  if [ "$HTTP_CODE" = "200" ]; then
    # Extract download URL from JSON response
    python3 -c "
import json, sys
with open('/tmp/anna-fast-dl.json') as f:
    data = json.load(f)
for key in ['download_url', 'url', 'fast_download']:
    if key in data:
        print(data[key])
        sys.exit(0)
print('NO_URL_FOUND')
"
    break
  elif [ "$HTTP_CODE" = "401" ]; then
    echo "AUTH_FAILED: Invalid ANNAS_SECRET_KEY on ${DOMAIN}"
    break
  elif [ "$HTTP_CODE" = "404" ]; then
    echo "MD5 not found on ${DOMAIN}, trying next domain"
  fi
done
```

**Step 3: Download from the fast download URL**

```bash
curl -L -o "literature/papers/<author>-<year>-<key>.pdf" "<fast_download_url>"
```

If `ANNAS_SECRET_KEY` is not set, fall back to the HTML method below.

### HTML Search (Fallback — no API key required)

Use only when the JSON API is unavailable (no donor key).

```bash
# By title keywords
curl -s -L "https://annas-archive.gl/search?q=$(python3 -c "import urllib.parse; print(urllib.parse.quote('bayesian data analysis gelman'))")" \
  -o /tmp/anna-search.html

# By ISBN
curl -s -L "https://annas-archive.gl/search?q=9781431997824" \
  -o /tmp/anna-isbn.html

# By DOI
curl -s -L "https://annas-archive.gl/search?q=10.1016/j.jml.2011.08.004" \
  -o /tmp/anna-doi.html
```

### CAPTCHA Check

After every HTML request to Anna's Archive, check for CAPTCHA before proceeding:

```bash
grep -qi "captcha\|cloudflare\|challenge" /tmp/anna-search.html && echo "CAPTCHA: manual intervention required"
```

If a CAPTCHA is detected, **stop automated retrieval for this source** and proceed to the next source. Do NOT attempt automated bypass.

### Parse Results (HTML method)

Extract MD5 hashes from result links (pattern: `/md5/<32-char-hex>`). Visit the MD5 detail page to get mirror download links.

```bash
# Get detail page for a specific MD5
curl -s -L "https://annas-archive.gl/md5/<md5hash>" \
  -o /tmp/anna-detail.html

# Extract mirror links from the detail page
grep -oP 'href="(/fast_download/[^"]+|https?://[^"]*libgen[^"]*|https?://[^"]*z-lib[^"]*)"' /tmp/anna-detail.html
```

### Download from Mirror

```bash
# Follow redirects; mirror links often redirect through several hops
curl -L -o "literature/papers/<author>-<year>-<key>.pdf" "<mirror_url>"
```

### Verify Download is a PDF

Anna's Archive mirror responses can return HTML error pages instead of PDFs. Always verify:

```bash
FILE="literature/papers/<author>-<year>-<key>.pdf"
head -c 5 "$FILE" | grep -q '%PDF' || { echo "FAIL: not a valid PDF"; rm "$FILE"; }
```

## 2. arXiv

Direct PDF access for all arXiv preprints. Most reliable source when an arXiv ID is available.

**Note:** arXiv papers are preprints — not peer-reviewed. Always check Semantic Scholar for a published version.

```bash
# Standard arXiv ID format: YYMM.NNNNN or arch-ive/YYMMNNN
curl -L -o "literature/papers/<author>-<year>-<key>.pdf" \
  "https://arxiv.org/pdf/2301.01234"

# Metadata via arXiv API
curl -s "http://export.arxiv.org/api/query?id_list=2301.01234" \
  -o /tmp/arxiv-meta.xml
```

## 3. Semantic Scholar

Academic search engine with open access PDF links for many papers.

```bash
# Search by title for open access PDF
curl -s "https://api.semanticscholar.org/graph/v1/paper/search?query=$(python3 -c "import urllib.parse; print(urllib.parse.quote('latent dirichlet allocation blei'))")&limit=5&fields=title,authors,year,externalIds,openAccessPdf" \
  -o /tmp/semantic-search.json

# Extract open access PDF URL
python3 -c "
import json
with open('/tmp/semantic-search.json') as f:
    data = json.load(f)
for paper in data.get('data', []):
    pdf = paper.get('openAccessPdf')
    if pdf and pdf.get('url'):
        print(f\"{paper.get('title', 'N/A')}\t{pdf['url']}\")
"
```

## 4. Unpaywall

Open access locator using DOI. Finds legally available open access copies.

```bash
curl -s "https://api.unpaywall.org/v2/<doi>?email=research@example.com" \
  -o /tmp/unpaywall-result.json

# Extract best OA location
python3 -c "
import json
with open('/tmp/unpaywall-result.json') as f:
    data = json.load(f)
best = data.get('best_oa_location')
if best:
    pdf_url = best.get('url_for_pdf') or best.get('url')
    if pdf_url:
        print(f'BEST: {pdf_url}')
for loc in data.get('oa_locations', []):
    url = loc.get('url_for_pdf') or loc.get('url')
    host = loc.get('host_type', 'unknown')
    if url:
        print(f'{host}: {url}')
"
```

## 5. Scopus Verification

When a DOI is available, verify paper metadata against the Scopus API using the Elsevier API key.

**Note:** Elsevier's Scopus API has a weekly quota of 20,000 requests (reset every 7 days) and a throttle of 9 req/s. Use conservatively (1 req/2s) to avoid flagging. Check `X-RateLimit-Remaining` and `X-RateLimit-Reset` response headers after each call. Permitted use: academic, non-commercial research only. Skip if `ELSEVIER_API_KEY` is not set.

```bash
DOI="<doi>"
API_KEY="${ELSEVIER_API_KEY}"

# Search Scopus by DOI
curl -s "https://api.elsevier.com/content/search/scopus?query=DOI(${DOI})&apiKey=${API_KEY}" \
  -o /tmp/scopus-result.json
```

## 6. Publisher Open Access

Some publishers provide direct PDF access. Common patterns:

```
# PLOS
https://journals.plos.org/plosone/article/file?id=<doi>&type=printable

# ACM (open access papers)
https://dl.acm.org/doi/pdf/<doi>

# Springer / Nature (open access)
https://link.springer.com/content/pdf/<doi>.pdf
```

Only use these when the paper is confirmed open access via Unpaywall or the publisher's OA indicator.

## 7. CrossRef (DOI Resolution Only)

Use CrossRef to resolve a DOI to publisher metadata and potential open access links. Does not provide PDFs directly.

```bash
curl -s "https://api.crossref.org/works/<doi>" \
  -o /tmp/crossref.json

# Extract title and author for verification
python3 -c "
import json
with open('/tmp/crossref.json') as f:
    data = json.load(f)
msg = data.get('message', {})
title = msg.get('title', ['N/A'])[0]
authors = ', '.join(a.get('family', '') for a in msg.get('author', []))
print(f'{authors}: {title}')
"
```

## File Naming Convention

Format: `<author1surname>-<year>-<short-key>.pdf`

Rules:
- Author surname: lowercase, ASCII-only. Replace non-ASCII characters with closest ASCII equivalent (ü→u, ö→o, etc.). Hyphens for compound names.
- Year: 4-digit publication year (use the year from the DOI record, not the online-first year)
- Short key: 2-4 words from the title, hyphenated, lowercase. Drop stop words (the, a, an, of, in, on, for, and, with).
- Max total filename length: 80 characters (truncate short-key if needed)

Examples:

| Paper | Filename |
|---|---|
| Gelman et al. (2013) "Bayesian Data Analysis, Third Edition" | `gelman-2013-bayesian-data.pdf` |
| Blei, Ng, Jordan (2003) "Latent Dirichlet Allocation" | `blei-2003-latent-dirichlet.pdf` |
| Pearl (2009) "Causality: Models, Reasoning, and Inference" | `pearl-2009-causality-models.pdf` |
| Vaswani et al. (2017) "Attention Is All You Need" | `vaswani-2017-attention-is.pdf` |

## Verification Checklist

After every download, verify ALL of the following:

```bash
FILE="literature/papers/<author>-<year>-<key>.pdf"

# 1. File exists and has non-zero size
[ -s "$FILE" ] || { echo "FAIL: file is empty or missing"; exit 1; }

# 2. File size > 1KB (reject error pages masquerading as PDFs)
SIZE=$(stat -c%s "$FILE" 2>/dev/null || stat -f%z "$FILE" 2>/dev/null)
[ "$SIZE" -gt 1024 ] || { echo "FAIL: file too small ($SIZE bytes)"; exit 1; }

# 3. PDF header check
head -c 5 "$FILE" | grep -q '%PDF' || { echo "FAIL: not a valid PDF"; exit 1; }

# 4. File type confirmation
file "$FILE"  # Should report "PDF document"

# 5. Extract first page text to verify correct paper
if command -v pdftotext &>/dev/null; then
    pdftotext "$FILE" - 2>/dev/null | head -n 30
fi

# 6. EXIF metadata if available
if command -v exiftool &>/dev/null; then
    exiftool "$FILE" | grep -iE "title|author|subject|pages"
fi
```

If verification fails:
- Delete the file: `rm "$FILE"`
- Try the next source in the fallback chain
- If all sources fail, report the failure honestly

## Catalog Update Workflow

After a successful download and verification, update `literature/catalog.md`:

```markdown
### [AuthorYear_Keyword]

- **citation_key**: AuthorYear_Keyword
- **authors**: Full author list
- **title**: Full paper title
- **year**: YYYY
- **source**: Venue name
- **source_type**: journal-article | conference-paper | book-chapter | preprint | thesis | report
- **peer_reviewed**: true | false
- **doi**: DOI or "N/A"
- **arxiv_id**: XXXX.XXXXX or "N/A"
- **download_status**: downloaded
- **local_file**: papers/AuthorYear_Keyword.pdf
- **retrieved_from**: annas-archive | arxiv | semantic-scholar | unpaywall | publisher | manual
- **retrieved_date**: YYYY-MM-DD
- **key_findings**: 2-4 bullet points (to be filled by reviewer)
- **peer_reviewed_version**: DOI/URL of published version or "N/A"
```

If `catalog.md` does not exist, create it with a header:

```markdown
# Literature Catalog

Papers retrieved and stored in the local library.

<!-- entry format:
### [AuthorYear_Keyword]
- **citation_key**: AuthorYear_Keyword
- **authors**: ...
- **title**: ...
- **download_status**: downloaded | pending | unavailable | needs_manual
- **local_file**: papers/AuthorYear_Keyword.pdf or "N/A"
-->
```

## Manual Download Guide

When a paper cannot be automatically retrieved, produce a structured guide for the user:

```markdown
## Manual Download Required: AuthorYear_Keyword

- **Title:** Full Paper Title
- **Authors:** Author1, Author2, Author3
- **Year:** 2024
- **DOI:** 10.xxxx/xxxxx
- **Publisher URL:** https://doi.org/10.xxxx/xxxxx
- **Source type:** journal-article
- **Peer-reviewed:** true

### Suggested Manual Search

1. Try institutional access via your university library
2. Search Google Scholar for the title: "Full Paper Title"
3. Search Anna's Archive manually: https://annas-archive.gl/search?q=<url-encoded-title>
4. Check if the author has a preprint on their personal page
5. Contact the corresponding author for a copy

### After Manual Download

Place the file at: `literature/papers/AuthorYear_Keyword.pdf`
Then update the catalog entry:
- Set `download_status: downloaded`
- Set `local_file: papers/AuthorYear_Keyword.pdf`
```

## Pending Downloads Report

After a retrieval session, produce a summary of all papers that could not be automatically downloaded:

```markdown
## Pending Downloads Report — YYYY-MM-DD

| Citation Key | Title | DOI | Status | Action Needed |
|---|---|---|---|---|
| Smith2023_method | A Novel Method for X | 10.xxxx/xxxx | needs_manual | Institutional access required |
| Jones2024_survey | Survey of Y Methods | N/A | unavailable | No open access version found |
| Lee2023_deep | Deep Learning for Z | 10.yyyy/yyyy | pending | Retry tomorrow (rate limited) |

Total: 3 papers need manual attention
```

## Error Handling

| Error | Response |
|---|---|
| HTTP 404 | Try next source in fallback chain |
| HTTP 401 (Anna's API) | Check `ANNAS_SECRET_KEY`. If invalid, skip Anna's Archive, continue with remaining sources. |
| HTTP 429 (rate limit) | Wait 30s, retry once. If still 429, move to next source. Use conservative delays: 2s for Anna's Archive, 2s for Scopus, 2s for Semantic Scholar, 3s for OpenAlex, 5s for CrossRef, 5s for arXiv. |
| CAPTCHA page detected | Stop that source. Do NOT attempt to bypass. Report to user. |
| PDF under 100KB | Delete file. Likely an error page. Try next source. |
| Not a PDF (`file` command disagrees) | Delete file. Try next source. |
| Wrong paper (metadata mismatch) | Delete file. Note the mismatch. Try next source with more specific query. |
| Corrupted download | Re-download once from same source. If still corrupt, try different source. |
| `ANNAS_SECRET_KEY` not set | Skip Anna's Archive JSON API. Use remaining sources. Report missing key. |
| `ELSEVIER_API_KEY` not set | Skip Scopus verification. Proceed with download. Note that metadata is unverified. |
| All sources exhausted | Set `download_status: unavailable`. Generate manual download guide. |
| Network error | Retry once after 10s. If still fails, set `download_status: pending`, report network issue. |
| JSON API returns unexpected format | Log the raw response. Fall back to remaining sources. |

## Batch Retrieval

When receiving multiple papers to retrieve, process them one at a time to avoid rate limiting:

```bash
for PAPER in paper1 paper2 paper3; do
  # Execute the download workflow for each paper
  sleep 5  # Conservative rate limit between requests
done
```

## Search Strategies for Retrieval

When multiple identifiers are available, prefer this lookup order for accuracy:
1. **DOI** (most precise) — search Anna's Archive, Unpaywall, CrossRef
2. **ISBN** (for books) — search Anna's Archive
3. **arXiv ID** (for preprints) — download directly from arXiv
4. **Title + author** combination — search Anna's Archive, Semantic Scholar
5. **Title alone** (least precise, highest false-positive risk)

## Integration with Research Pipeline

- **Inbound:** Receive retrieval requests from `res-phd-literature-searcher` containing title, authors, year, DOI, arXiv ID, and/or ISBN.
- **Outbound:** After successful download and verification, report to `res-phd-literature-reviewer` with the local file path, source, and extracted metadata.
- **Paired skills:** Use `skill://literature-search` for finding papers to retrieve, `skill://literature-retrieval` for retrieval procedure reference.

## Safety and Ethics

- Only retrieve papers through legitimate open access channels or archives.
- Respect robots.txt and rate limits of all services. Use conservative delays between requests.
- Do not attempt to bypass paywalls, CAPTCHAs, or authentication systems.
- If a paper is not freely available, report it as unavailable rather than seeking unauthorized access.
- The Anna's Archive API requires a secret key obtained through donation — only use it if the user has provided `ANNAS_SECRET_KEY`.
- Scopus API usage is permitted for academic research under Elsevier's policy, which allows "scholarly published work that utilizes publications in Scopus for a research effort" with an API key. Weekly quota: 20,000 requests. Use conservatively.