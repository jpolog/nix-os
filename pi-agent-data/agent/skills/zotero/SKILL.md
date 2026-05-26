---
name: zotero-connector
description: Connects the agent to your local Zotero library using the Zotero HTTP API (or local SQLite access) to search, retrieve metadata, and read attached PDFs.
globs:
  - "**/*"
---

# Zotero Connector

This skill allows you to interact with your local Zotero library to support academic research workflows.

## Features

- **Search**: Find items by title, author, year, or tags.
- **Metadata Retrieval**: Get full bibliographic data for items.
- **PDF Access**: Locate and read PDFs attached to Zotero items.
- **Collection Management**: Browse and filter by Zotero collections.

## Prerequisites

- Zotero must be running with the **Zotero HTTP API** enabled (usually via a plugin like `zotero-api-server` or `zotero-connect`).
- Default local API URL: `http://127.0.0.1:23119/connector` (or custom port).

## Commands (Agent-accessible via Bash)

- `curl -s "http://localhost:23119/connector/search?q=<query>"`
- `curl -s "http://localhost:23119/connector/selected_items"`

## Instructions for the Agent

1. **Search**: When asked to find a paper from your library, use `curl` to query the Zotero connector.
2. **Read**: To read a paper, find the attachment path in the metadata and use `read` or `pdftotext`.
3. **Cite**: Use the metadata to generate correct citations in `literature/citations.md`.
