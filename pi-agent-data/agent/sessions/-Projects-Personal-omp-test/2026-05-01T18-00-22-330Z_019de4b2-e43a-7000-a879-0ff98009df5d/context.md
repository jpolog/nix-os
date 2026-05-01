# Conversation Context

This is a summary of the parent conversation. Read this if you need additional context about what was discussed or decided.

## User

I want you to improve the omp phd literature research agent. I want it to search in google scholar or scopus or other highly-regarded academic search engines. The idea is to try and avoid arXiv as much as possible due to the non-reviewed nature of their papers (not well regarded in the scientific academic world). It should return a list of interesting articles to review and an explanation on why (maybe group the results of the search by search query or topic). Then another agent would be the one to try and download them using annas archive API or if they can't then I would try to manually download them so the literature review agent can read them. All of this generates a /literature subdirectory in the project that contains the literature and the markdown files of the literature that we want to research and the status (downloaded or not and the file where they are) so I can know what I need to manually find and that serves as a guide for the literature review agent. Improve the phd agents to do this

## Assistant

Now let me read the relevant PhD agents and skills to understand the current architecture:

## Assistant

Now I have a comprehensive understanding of the current architecture. Let me also check the remaining relevant agents:

## Assistant

Now let me also check the other relevant researcher agent:

## Assistant

Now I have a thorough understanding of the entire PhD agent ecosystem. Let me plan the changes needed.

## Assistant

Let me design the architecture first, then implement all the changes in parallel. The key design decisions are:

1. **Literature directory structure**: `literature/` with `papers/` for PDFs, `notes/` for reading notes, `search-log.md` for reproducibility, and a central `catalog.md` (replacing `citations.md`) that tracks download status
2. **Search hierarchy**: Prioritize Google Scholar, Scopus, Semantic Scholar, OpenAlex, CrossRef — de-prioritize arXiv, clearly mark preprints
3. **Search results format**: Group results by search query/topic, with peer-reviewed status clearly indicated
4. **Download tracking**: `catalog.md` entries have explicit `download_status` field (downloaded/pending/unavailable/needs_manual) and `local_file` path
5. **Retriever**: Anna's Archive as primary download source, with fallback chain

Now let me implement everything. I'll work on all files in parallel.

## Assistant

Now I'll implement all changes in parallel using tasks for the major rewrites:

## User

This is the Elsevier API documentation How much data can I retrieve with my APIKey?

Every API Key comes with the ability to run a certain number of requests for data from the APIs. Quotas, meaning the number of requests run, are reset every seven days. You can view the quotas and throttling rates of our suite of APIs below. Quota limits are unique to each API, there is not a single global setting for a given APIKey. If you find that the quota of a particular API is not enough for your project needs, please write API Support with:

    your API Key
    full institution name
    a brief description of your use case
    API name and requested quota increase


Additionally, access to specialized APIs is not enabled by default, as use cases for specialized APIs require review from Elsevier’s API Support team. API Support cannot guarantee permission to use access-controlled APIs. The access-controlled APIs include:

    Scopus Citation Overview
    Scopus Author Feedback
    ScienceDirect Full-Text Entitlement
    ScienceDirect Article Hosting Permissions
    ScienceDirect Holdings Report
    Embase Search and Retrieval
    Engineering Village Search and Retrieval
    Pharmapendium API
    SUSHI COP5 API


If you would like to request access to one of these access-controlled APIs, please write API Support with the following information:

    your API Key
    full institution name
    a brief description of your use case
    API name and requested quota increase


How do I check my quota?

You can look to the following response headers to check your quota:

Review quota using the following response headers:

X-RateLimit-Limit       <----Shows API quota setting
X-RateLimit-Remaining   <----Shows API remaining quota
X-RateLimit-Reset       1234567891 <----Date/Time in Epoch seconds when API quota resets

What should I do when I get a http 429 TOO MANY REQUESTS Error?

There are two possible reasons that you are experiencing a 429 error. If the quota is exceeded, X-RateLimit-Limit and X-RateLimit-Remaining don’t return. Instead, the APIs deliver an http 429 TOO MANY REQUESTS msg, along with the following response headers:

X-ELS-Status            QUOTA_EXCEEDED - Quota Exceeded
X-RateLimit-Reset       1234567891 <----Date/Time in Epoch seconds

Alternately, if requests exceed the throttling rate, the APIs also return an http 429 TOO MANY REQUESTS msg

Throttling Rates are listed in the table below in column requests/second. If requests exceed the throttling rate, the APIs also return an http 429 TOO MANY REQUESTS msg
API Name     Views     Weekly Quota     Requests per second
Serial Title     STANDARD, COVERIMAGE, ENHANCED
Default 25 results / Max 200 results     20,000     6
Citations Count Metadata     STANDARD view Default
25 results / Max 200 results     50,000     10
Subject Classifications     STANDARD view
Default 25 results / Max 200 results     N/A     N/A
Abstract Retrieval     All views, default FULL view     10,000     9
Affiliation Retrieval     All views, default STANDARD view     5,000     9
Author Retrieval     All views, default STANDARD view     5,000     3
Affiliation Search     Default 25 results / Max 200 results
5000 item result limit     5,000     6
Author Search     Default 25 results / Max 200 results
5000 item result limit     5,000     2
Scopus Search     STANDARD view / Max 200 results
COMPLETE view / Max 25 results
COMPONENT view / Max 25 results
5000 item total result limit without ‘cursor pagination’ explained in Q4 of FAQ     20,000     9

API Name     Views     Weekly Quota     Requests per second
Serial Title     STANDARD, COVERIMAGE views
Default 25 results / Max 200 results     20,000     6
Nonserial Title     STANDARD, COVERIMAGE views
Default 25 results / Max 200 results     20,000     6
Subject Classifications     No restrictions     No restrictions     N/A
Article Retrieval     All Subscribed, OpenAccess and Complimentary Articles     50,000 Unlimited for Text Mining API Keys     10
Article Metadata API     25 results- a field restricted search against ScienceDirect serial/nonserial full-text articles
6000 item total results limit     N/A     6
ScienceDirect Search v2     STANDARD view / Max 200 results
6000 item total results limit     20,000     2

API Name     Views     Weekly Quota     Requests per second
SciVal Author Lookup     Default 100 results / Max 500 results     *5000     6
SciVal Country Lookup     Maximum 100 results for Metrics resource
No limit on total results (varies by resource)     *5000     6
SciVal Country Group Lookup     Maximum 100 results for Metrics resource
No limit on total results (varies by resource)     *5000     6
SciVal Institution Lookup     Maximum 100 results for Metrics resource
No limit on total results (varies by resource)     *5000     6
SciVal Institution Group Lookup     Maximum 100 results for Metrics resource
No limit on total results (varies by resource)     *5000     6
SciVal Publication Lookup     Maximum 100 results for Metrics resource
No limit on total results (varies by resource)     *5000     6
SciVal Scopus Source Lookup     Maximum 100 results for Metrics resource
No limit on total results (varies by resource)     *5000     6
SciVal Subject Area     Maximum 100 results for Metrics resource
No limit on total results (varies by resource)     *5000     6
SciVal Topic Lookup     Maximum 100 results for Metrics resource
No limit on total results (varies by resource)     *5000     6
SciVal Topic Cluster Lookup     Maximum 100 results for Metrics resource
No limit on total results (varies by resource)     *5000     6
SciVal World Lookup     Maximum 100 results for Metric resource
No limit on total results (varies by resource)     *5000     6

API Name     Views     Weekly Quota     Requests per second
Scopus Citation Overview     STANDARD view
Default 25 results / Max 200 results     20,000     4
Scopus Author Feedback     N/A     N/A     N/A
ScienceDirect Full-Text Entitlement     N/A     N/A     6
ScienceDirect Article Hosting Permissions     Provides open access information for a single full text article     N/A     6
ScienceDirect Holdings Report     N/A     N/A     2
Embase Search     Default 25 results
No limit on total results     N/A     6
Embase Retrieval     1 document per request     N/A     6
Engineering Village Search     Default 25 results     N/A     N/A
Engineering Village Retrieval     1 document per request     N/A     N/A
Pharmapendium API     Variable, depending on request     N/A     6
SUSHI COP5 API     1 request per metric type     N/A     6 and also you must web search to determine if this that we want to do (use an ai agent to search queries to identify relevant literature) is allowed or not. If that is not allowed, could the agent just web search in the scopus search engine or google scholar engine?

Also for annas archive I will get the json api available because I am going to donate

## Assistant

Good questions. Let me research the Elsevier API terms for AI agent usage, then update all the affected files.

## Assistant

Now let me check the Anna's Archive fast download API:

## Assistant

Now I have all the information I need. Let me summarize my findings and update the files.

**Key findings:**

1. **Elsevier/Scopus API**: Permitted for academic research use. The policy explicitly allows "scholarly published work that utilizes publications in Scopus for a research effort" — this covers using an AI agent to search for relevant literature. The API key must be obtained, and the use must be non-commercial and academic. The quotas are generous (20,000 requests/week for Scopus Search). The permitted metadata includes: titles, authors, DOI, abstract, citation count, source type, journal metrics, etc. — exactly what we need.

2. **Anna's Archive API**: The `fast_download.json` API endpoint provides download URLs given an MD5 hash and a secret key (donor membership). The Rust/Dart client libraries show the API structure: search by query, get details by MD5 (requires key), get download URL by MD5. The MCP server project shows best practices: validate key via `POST /account/`, use `X-Annas-Secret-Key` header, and domain fallback (`gl` → `gd` → `pk`).

3. **Important**: The Elsevier terms say the API should NOT be used for "mining of the entire Scopus dataset" — but targeted searches for specific research topics are explicitly permitted. Using an AI agent to construct targeted queries and parse results is within the allowed "academic research" use case.

Now let me update all the affected files. I'll run tasks in parallel: