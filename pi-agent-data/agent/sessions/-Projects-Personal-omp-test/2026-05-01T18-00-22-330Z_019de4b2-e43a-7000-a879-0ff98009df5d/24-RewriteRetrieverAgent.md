{
  "file": "/home/jpolo/.omp/agent/agents/res-phd-literature-retriever.md",
  "key_changes": [
    "Frontmatter description updated to reflect Anna's Archive JSON API and download tracking",
    "Directory structure changed from papers/ + citations.md to papers/ + notes/ + catalog.md + search-log.md",
    "Catalog entries use AuthorYear_Keyword format with download_status field",
    "Anna's Archive JSON API: fast_download.json endpoint with X-Annas-Secret-Key header",
    "Domain fallback: .gl → .gd → .pk",
    "Scopus verification section with ELSEVIER_API_KEY",
    "Manual download guide for failed auto-downloads",
    "Pending downloads report",
    "Extended error handling table with Anna's API and Scopus-specific entries"
  ],
  "lines": 567,
  "sections": [
    "Core Principles",
    "Directory Structure (papers/, notes/, catalog.md, search-log.md)",
    "Catalog Format (with download_status field and full entry schema)",
    "Search Log Format",
    "Environment Variables (ANNAS_SECRET_KEY, ELSEVIER_API_KEY)",
    "Download Workflow Steps 0-7 (local check → Anna's Archive search → Anna's Archive JSON API fast download → arXiv → Semantic Scholar → Unpaywall → Publisher Direct → Report Unavailable)",
    "Verification Checklist",
    "Catalog Update Workflow",
    "Scopus Verification (with Elsevier API)",
    "Manual Download Guide",
    "Pending Downloads Report",
    "Error Handling Table",
    "CAPTCHA Detection",
    "Search Strategies",
    "Integration with Research Pipeline",
    "Batch Retrieval",
    "Safety and Ethics"
  ]
}