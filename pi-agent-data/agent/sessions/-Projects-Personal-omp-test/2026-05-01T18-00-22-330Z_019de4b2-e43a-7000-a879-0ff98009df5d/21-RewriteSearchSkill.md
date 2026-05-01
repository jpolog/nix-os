{
  "changes": [
    "Restructured §2 database order: Google Scholar (§2.1) > Scopus (§2.2) > Semantic Scholar (§2.3) > OpenAlex (§2.4) > CrossRef (§2.5) > arXiv (§2.6, LAST RESORT)",
    "Added §2.7 Finding Peer-Reviewed Versions of Preprints: Semantic Scholar externalIds/venue check, CrossRef DOI verification, Google Scholar title search, catalog update instructions",
    "Added explicit arXiv warning block in §2.6 with three mandatory steps (mark preprint, cross-reference, default to Tier 3)",
    "Replaced §7 with Source Quality Tiers: Tier 1 (peer-reviewed journal/conference), Tier 2 (cited preprints >50/>20, industry reports), Tier 3 (uncited preprints, default for arXiv). Includes tier promotion rules.",
    "Updated §5 search log template with peer-reviewed/preprint counts and result grouping requirement",
    "Updated §1 search workflow Phase 2: strict database priority order, preprint status marking per result",
    "Updated §8 catalog to use catalog.md with new fields: peer_reviewed, source_type, download_status, peer_reviewed_version, influential_citation_count, search_query, relevance_score",
    "Added §2.2 Scopus with ELSEVIER_API_KEY env var, query syntax, and API calls",
    "Updated §9 rate limiting table with Scopus row (2 req/sec, API key required, skip if unavailable)",
    "Updated frontmatter description to reflect peer-reviewed priority",
    "Preserved: boolean queries (§3), citation chaining (§4), deduplication (§6), saturation criteria (§10)",
    "Added preprint-vs-published deduplication rule in §6"
  ],
  "file": "/home/jpolo/.omp/agent/skills/literature-search/SKILL.md"
}