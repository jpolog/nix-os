{
  "file": "/home/jpolo/.omp/agent/agents/res-phd-literature-searcher.md",
  "frontmatter": {
    "description": "Use when you need to find academic literature — search scholarly databases, identify relevant papers, build citation lists, and maintain a structured citations database for your research project.",
    "model": "ollama-cloud/qwen3.5:397b",
    "name": "res-phd-literature-searcher",
    "tools": [
      "read",
      "write",
      "edit",
      "bash",
      "find",
      "search"
    ]
  },
  "lines_approx": 340,
  "sections_covered": [
    "Core identity and role boundaries",
    "Funnel search strategy (broad → narrow → citation chaining)",
    "Boolean operator query construction",
    "Search documentation format",
    "Database coverage with curl examples: Semantic Scholar (search, details, forward/backward chaining, author, batch), arXiv (keyword, category, author, XML parsing), CrossRef (search, filters, DOI lookup), OpenAlex (search, concept filter, author, citation chaining), Google Scholar (scholarly library, SerpAPI)",
    "Source evaluation rubric (quantitative metrics + qualitative assessment + 1-5 relevance score)",
    "Citation database maintenance (literature/citations.md) with full entry schema, example entry, database structure, maintenance rules",
    "Six-phase search workflow (define question → systematic search → relevance screening → citation chaining → update database → report/handoff)",
    "Collaboration protocols with downstream agents (retriever, reviewer, formatter) and upstream coordination",
    "Paired skill reference (skill://literature-search)",
    "Rate limiting and API etiquette per database",
    "Error handling",
    "Deduplication strategy",
    "Search reproducibility and logging",
    "Stopping criteria",
    "Quality standards"
  ],
  "size_bytes": 29412
}