---
name: style-guard
description: AI-artifact detection patterns, plagiarism prevention, and personal style guide template — ensures academic writing sounds human and original.
globs:
  - "**/*"
alwaysApply: false
---

# Style Guard

Academic writing must sound like a human scholar wrote it — not like a language model filling in the most probable tokens. This skill provides detection patterns, prevention checklists, and rewrite strategies to keep writing original and authentic.

---

## 1. AI Artifact Detection — Comprehensive Pattern Catalog

### 1.1 Punctuation Tells

**Em-dashes as parenthetical separators**

AI overuses em-dashes (—) to insert mid-sentence asides. A single em-dash per 500 words is normal; more signals mechanical writing.

| AI tell | Human alternative |
|---|---|
| The results—despite the small sample size—suggest a clear trend. | The results suggest a clear trend, even with the small sample size. |
| This approach—unlike prior methods—accounts for selection bias. | This approach accounts for selection bias, which prior methods did not. |
| The model—initially proposed by Smith (2019)—was later extended. | Smith (2019) initially proposed the model; it was later extended. |

**Colon overuse before lists or elaborations**

AI places colons before nearly every enumeration or explanatory clause. Humans use colons sparingly and often let the sentence flow without one.

| AI tell | Human alternative |
|---|---|
| Three factors contributed: funding, expertise, and timing. | Funding, expertise, and timing all contributed. |
| The key insight: the effect is nonlinear. | The key insight is that the effect is nonlinear. |
| The system requires the following: a controller, sensors, and actuators. | The system requires a controller, sensors, and actuators. |

**Excessive semicolons joining independent clauses**

AI links clauses with semicolons at a rate far above natural academic prose. Humans prefer periods or explicit connectives.

| AI tell | Human alternative |
|---|---|
| The sample was small; the effect was large; the implications remain unclear. | The sample was small and the effect was large, but the implications remain unclear. |
| Method A converged quickly; Method B required more iterations; both produced similar results. | Method A converged quickly. Method B required more iterations, though both produced similar results. |

---

### 1.2 Structural Tells

**Uniform paragraph lengths**

AI paragraphs cluster within 10% word count of each other. Human paragraphs vary naturally — some a single sentence, others a full page.

- Detection: count words per paragraph. If standard deviation < 15% of mean, flag it.
- Fix: deliberately vary. Allow one-sentence paragraphs for emphasis. Allow longer ones for complex arguments.

**Homogeneous syntactic complexity**

AI produces runs of sentences with similar structure: subject-verb-object, similar clause count, similar subordinate clause depth.

| AI tell (three consecutive sentences with same structure) | Human alternative |
|---|---|
| The algorithm processes the input. The system validates the output. The framework stores the results. | The algorithm processes the input before the system validates the output. Results are then stored in the framework. |
| We analyzed the data. We identified patterns. We reported findings. | After analyzing the data, we identified patterns and reported our findings. |

**Exactly-three-item lists (repeatedly)**

AI defaults to triadic lists. Three examples, three reasons, three implications — always three. Humans use two, four, or simply avoid list-like enumeration.

| AI tell | Human alternative |
|---|---|
| The approach offers accuracy, efficiency, and scalability. | The approach is accurate and efficient, scaling well to larger datasets. |
| This matters for theory, practice, and policy. | This has theoretical and practical consequences. |

**Perfect parallel structure in consecutive sentences or paragraphs**

AI makes consecutive sentences mirror each other's grammar. Real academic writing is messier.

| AI tell | Human alternative |
|---|---|
| First, we collected the data. Second, we cleaned the data. Third, we analyzed the data. | We began by collecting raw responses, then cleaned them (removing 12 incomplete entries), and finally ran the regression. |
| The first study examined motivation. The second study examined performance. The third study examined satisfaction. | Study 1 looked at motivation; studies 2 and 3 turned to performance and satisfaction respectively. |

---

### 1.3 Transition Tells

AI relies on a small set of formal transition words as sentence starters. Humans use a wider, less predictable range — or no explicit transition at all.

**High-signal transition words (flag if used more than once per 1000 words):**

- Moreover
- Furthermore
- Additionally
- In particular
- It is worth noting
- It is important to emphasize
- Notably
- Significantly
- Crucially
- Importantly
- It should be noted that
- It is worth mentioning that
- Of particular importance
- As a matter of fact

| AI tell | Human alternative |
|---|---|
| Moreover, the effect persisted across subgroups. | The effect persisted across subgroups. |
| Furthermore, prior work supports this interpretation. | Prior work supports this interpretation too. |
| It is worth noting that the sample was not random. | The sample was not random, which limits generalizability. |
| Notably, all three experiments converged. | All three experiments converged. |
| Crucially, the mechanism differs from the classic model. | The mechanism differs from the classic model — this distinction matters for prediction. |

---

### 1.4 Hedging Tells

**Stacked hedges**

AI stacks multiple hedges in one sentence, producing overly cautious prose.

| AI tell | Human alternative |
|---|---|
| It could perhaps be argued that this might suggest a possible relationship. | This suggests a relationship. |
| It may potentially be the case that these findings could indicate a trend. | These findings indicate a trend. |

**Hedging verb clusters**

AI clusters hedging verbs (suggests, indicates, implies, demonstrates) in the same paragraph rather than varying assertion strength.

| AI tell | Human alternative |
|---|---|
| The data suggests X. The analysis indicates Y. This implies Z. Together these demonstrate W. | The data show X. Analysis confirms Y, from which Z follows. Taken together, they establish W. |

**Formulaic hedging patterns**

| AI tell | Human alternative |
|---|---|
| While further research is needed, these findings suggest… | These findings suggest… (save the "further research" point for the actual limitations section). |
| Although this study has limitations, it contributes to… | This study contributes to… |
| It is important to note that this remains speculative. | This remains speculative. |

---

### 1.5 Vocabulary Tells

**Elevated vocabulary without variation**

AI selects the most formal word every time, never dropping to a simpler synonym for rhythm or clarity.

| AI tell | Human alternative |
|---|---|
| The methodology facilitates the elucidation of underlying mechanisms. | The method helps explain the underlying mechanisms. |
| This framework enables practitioners to navigate complexity. | This framework helps practitioners deal with complexity. |

**Abstract nouns dominating**

AI writes in nominalizations. Humans mix verbs and concrete nouns.

| AI tell | Human alternative |
|---|---|
| The implementation of the optimization resulted in the enhancement of performance. | Optimizing the code improved performance. |
| The facilitation of collaboration was a key outcome. | The key outcome was that people collaborated more. |

**Overused AI-associated words**

Flag these if they appear more than once per 2000 words:

- delve / delve into
- navigate / navigating
- leverage / leveraging
- facilitate / facilitating
- underscore / underscoring
- elucidate / elucidating
- encompass / encompassing
- harness / harnessing
- paramount
- pivotal
- multifaceted
- nuanced (when used without specific detail following)
- robust (when not in a statistical sense)
- synergistic / synergy
- paradigm (when not in Kuhn sense)
- holistic
- bespoke (outside UK legal context)
- endeavor

| AI tell | Human alternative |
|---|---|
| We delve into the nuances of the problem. | We examine the problem in detail. |
| This approach leverages existing infrastructure. | This approach uses existing infrastructure. |
| The framework facilitates collaboration across teams. | The framework makes it easier for teams to collaborate. |

---

### 1.6 Register Tells

**Perfectly consistent formality**

AI maintains the same register throughout — no variation. Real academic prose has subtle shifts: slightly more informal in method descriptions, more formal in theoretical framing, occasionally colloquial in discussion.

- Detection: run a formality score per paragraph. If all paragraphs score within 5% of each other, flag it.
- Fix: allow the discussion section to be slightly more conversational; let methods be terse.

**Lack of discipline-specific jargon mixed with general academic prose**

AI produces generic academic English even in specialized fields. Real scholars use field-specific terms naturally and occasionally coin or repurpose terms.

- Detection: if the text reads like it could apply to any social science, it probably reads like AI.
- Fix: use the specific terms your community uses, even if they are less "standard" English.

**No personal voice markers**

AI never uses first person, never admits uncertainty casually, never shows a scholar thinking out loud.

| AI tell | Human alternative |
|---|---|
| This study demonstrates that the hypothesis is supported. | We find support for the hypothesis. |
| The data suggest that further investigation is warranted. | The data surprised us: we expected the opposite pattern, and this warrants follow-up. |
| It is concluded that the model performs adequately. | We conclude that the model performs adequately, though not as well as we hoped. |

---

## 2. Style Guide Template

When this skill activates, check for a `literature/style-guide.md` file. If none exists, suggest creating one from this template. If one exists, use it as the reference for all subsequent checks.

### Template for `literature/style-guide.md`

````markdown
# Personal Academic Style Guide

## Voice and Tone
- Formality level: [high / moderate / conversational-academic]
- First person usage: [never / sparingly / commonly]
- Personal asides permitted: [no / occasionally / yes]
- Humor permitted: [no / rarely / in discussion sections]

## Sentence Pattern Preferences
- Preferred average sentence length: [15-20 / 20-25 / 25-30] words
- Acceptable range: [min]–[max] words
- Complex sentences (multiple clauses): [rare / moderate / frequent]
- Fragments for emphasis: [never / occasionally / yes]
- Questions as rhetorical devices: [never / rarely / sometimes]

## Paragraph Structure Preferences
- Typical paragraph length: [3-5 / 5-8 / 8-12] sentences
- Variation: paragraphs should vary ±[30 / 50 / 70]% in length
- Topic sentences: [always / usually / sometimes optional]
- One-sentence paragraphs for emphasis: [never / rarely / sometimes]

## Transition Preferences
- Preferred transitions: [list 5-8 you actually use]
- Banned transitions: [list any you dislike]
- Implicit transitions (no connective word): [rare / sometimes / common]
- Repetition of key terms as connective device: [avoid / sometimes / prefer]

## Vocabulary Preferences
- Technical jargon level: [light / moderate / heavy]
- Preferred simpler alternatives: [e.g., "use" not "utilize", "show" not "demonstrate"]
- Words to avoid: [list personal pet peeves]
- Field-specific terms to always use: [list]

## Hedging Calibration
- Default assertion strength: [strong / moderate / cautious]
- When to hedge: [only when genuinely uncertain / in interpretations / always in claims]
- Preferred hedging phrases: [e.g., "We find", "The data show", "This suggests"]
- Over-hedging threshold: [max 1 hedge per claim / 2 per claim / case by case]

## Personal Voice Markers
- Use "we" for author team: [yes / no]
- Admit surprise or unexpected results: [no / sometimes / yes]
- Express enthusiasm or frustration: [no / rarely / yes]
- Reference personal research history: [no / occasionally / yes]
- Footnote asides: [never / sometimes / yes]

## Formatting Preferences
- Oxford comma: [yes / no]
- Serial semicolons in complex lists: [yes / no]
- Em-dash spacing: [closed — like this / spaced — like — this / avoid em-dashes]
- Abbreviation introduction: [first use only / repeated in each chapter / never abbreviate]
- Citation style: [APA / Chicago / other]
- Block quote threshold: [40+ / 60+ / 80+] words
````

---

## 3. Plagiarism Prevention Checklist

Before submitting any written work, verify each item:

### 3.1 Adequate Paraphrasing

Paraphrasing is not synonym substitution. It requires restructuring the argument in your own voice.

**Failing paraphrase (synonym swap):**
> Original: "The intervention significantly reduced dropout rates among at-risk students."
> Bad paraphrase: "The program markedly decreased dropout rates among vulnerable students."

**Passing paraphrase (restructured):**
> Original: "The intervention significantly reduced dropout rates among at-risk students."
> Good paraphrase: "Students who had been identified as at-risk were far less likely to drop out after the intervention."

**Paraphrase quality test:**
1. Can you explain the idea without looking at the source? If not, you have not understood it well enough to paraphrase.
2. Read your paraphrase, then the original. If the sentence structure is the same, rewrite.
3. Does your paraphrase add something — context, connection to your argument, a different emphasis? It should.

### 3.2 Proper Attribution

- Every claim that is not common knowledge in your field needs a citation.
- "Common knowledge" test: would a typical second-year graduate student in your field know this without looking it up? If not, cite.
- When in doubt, cite. Over-citation is a minor stylistic issue; under-citation is misconduct.

### 3.3 Citation for Every Claim

- Check: scan each paragraph. Is there at least one citation for each empirical claim?
- Check: are there claims presented as facts that are actually findings from specific studies?
- Check: are there generalizations ("Research shows that…") without at least one representative citation?

### 3.4 Direct Quotes Marked

- Any verbatim phrase of 3+ words from a source must be in quotation marks.
- Block quotes (see formatting preferences for threshold) must be indented and attributed.
- Paraphrased ideas that closely follow the source's structure need attribution even without quotation marks.

### 3.5 Paraphrase Quality Test (Expanded)

For each paraphrased passage, ask:
1. **Structure test**: Does your version use a different grammatical structure? Different subject, different verb, different clause order?
2. **Level test**: Does your version sit at a different level of abstraction? More specific? More general? Connected to your framework?
3. **Voice test**: Does your version sound like you wrote it, not like the original author?
4. **Accuracy test**: Does your version still accurately represent the original claim?
5. **Addition test**: Does your version contribute something the original did not — context, critique, extension, or connection?

If any test fails, rewrite the paraphrase.

---

## 4. Self-Audit Protocol

Run this protocol on every draft before submission.

### Step 1: Read Aloud

Read the entire text aloud. Flag anything that:
- You stumble over (likely awkward syntax)
- Sounds like a textbook, not a person (likely AI register)
- Has no breath pauses for 30+ words (likely run-on)

### Step 2: Check Paragraph Length Variance

- Count words per paragraph.
- Compute mean and standard deviation.
- If coefficient of variation (SD/mean) < 0.20, paragraphs are too uniform. Restructure at least two paragraphs to break the pattern.

### Step 3: Check Sentence Opener Variety

- List the first word or phrase of every sentence in a section.
- If more than 20% start with the same structure (e.g., subject-verb, transition word), rewrite.
- Specifically check for: "The [noun] [verb]…" — if this pattern opens more than 3 consecutive sentences, break it.

### Step 4: Check for Banned Patterns

Scan for each category in Section 1:
- [ ] Punctuation tells: count em-dashes, colons before lists, semicolons per 1000 words
- [ ] Structural tells: count items in each list (flag every triad), check paragraph uniformity
- [ ] Transition tells: highlight every word from the list in Section 1.3
- [ ] Hedging tells: count hedges per paragraph, flag stacked hedges
- [ ] Vocabulary tells: search for each word in Section 1.5 list
- [ ] Register tells: assess formality variation across paragraphs

### Step 5: Compare Against Style Guide

If `literature/style-guide.md` exists:
- Read each preference.
- Check the draft against each preference.
- List deviations.

If no style guide exists:
- Generate one from the template in Section 2.
- Ask whether the preferences match the author's actual style.
- Adjust based on feedback, then run the comparison.

---

## 5. Rewrite Strategies for Detected Artifacts

### 5.1 Vary Sentence Length

**Problem**: Sentences cluster around the same length (typically 20-25 words).

**Strategy**:
- After every 3-4 sentences of similar length, insert a short sentence (5-10 words) for emphasis.
- Allow one longer sentence (35+ words) per paragraph for complex ideas.
- Count: aim for a sentence length distribution with a range spanning at least 15 words between shortest and longest in any paragraph.

| Before | After |
|---|---|
| The data were collected over three months. The analysis controlled for confounds. The results supported the hypothesis. The implications are discussed below. | The data were collected over three months and the analysis controlled for confounds. The results supported the hypothesis. We discuss the implications below. |

### 5.2 Use Different Transitions

**Problem**: "Moreover," "Furthermore," "Additionally" appear repeatedly.

**Strategy**: Replace with one of these alternatives — or use no transition at all:
- Omit the transition entirely (often the logic is clear without it)
- Use a content-based link: "This finding…" / "The same pattern…" / "In contrast,…"
- Use punctuation: a period, a colon, parentheses
- Restructure: merge sentences so no transition is needed

| Before | After |
|---|---|
| Moreover, the effect size was large. | The effect size was large. |
| Additionally, prior work supports this. | Prior work supports this too. |
| Furthermore, the model generalizes. | The model also generalizes. |

### 5.3 Restructure Paragraphs

**Problem**: Paragraphs follow the same internal structure (topic sentence → evidence → conclusion).

**Strategy**:
- Start some paragraphs with evidence, then draw the conclusion.
- Start some paragraphs with a question.
- Begin with a concession ("Although X, Y").
- Use a brief narrative or example as an opener.
- End some paragraphs mid-thought, completing it in the next paragraph.

| Before (uniform structure) | After (varied structure) |
|---|---|
| (Topic sentence) Social trust influences institutional quality. (Evidence) Putnam (2000) showed that high-trust regions had better governance. (Conclusion) Thus, trust is a precondition for institutions. | Putnam (2000) found that regions with higher social trust also had better-governed institutions. Trust, it seems, is not merely a consequence of good institutions but a precondition for them. |

### 5.4 Add Personal Voice

**Problem**: Text reads as if no human wrote it — no first person, no surprise, no opinion.

**Strategy**:
- Use "we" for the author team (standard in many fields).
- Express surprise: "Unexpectedly,…" / "Contrary to our expectations,…"
- Express opinion: "We believe this matters because…" / "In our view,…"
- Show the thinking process: "We initially expected X, but the data showed Y."
- Add an aside: "This result, though small in magnitude,…"

| Before | After |
|---|---|
| The results demonstrate that the model is effective. | We found that the model worked, though not as well as we expected. |
| It is argued that the theory has limitations. | The theory has limitations that we think have been underappreciated. |

### 5.5 Break Parallel Patterns

**Problem**: Consecutive sentences or paragraphs mirror each other's grammar.

**Strategy**:
- Change the subject of at least one sentence.
- Switch from active to passive or vice versa.
- Merge two parallel sentences into one compound or complex sentence.
- Split a long parallel sentence into two non-parallel ones.
- Insert a parenthetical aside that disrupts the rhythm.

| Before (parallel) | After (varied) |
|---|---|
| The first experiment tested accuracy. The second experiment tested speed. The third experiment tested robustness. | Experiment 1 tested accuracy. Speed was the focus of experiment 2, and experiment 3 checked for robustness. |
| Smith (2018) found X. Jones (2019) found Y. Lee (2020) found Z. | Smith (2018) found X; Jones (2019) and Lee (2020) extended this work to Y and Z respectively. |

---

## Quick Reference: AI Tell Density Score

For any text, compute a rough AI-tell density:

1. Count em-dashes per 500 words (normal: 0-1; suspicious: 2+)
2. Count flagged transition words per 1000 words (normal: 0-1; suspicious: 3+)
3. Count flagged vocabulary words per 2000 words (normal: 0-1; suspicious: 2+)
4. Count stacked hedges per 1000 words (normal: 0; suspicious: 1+)
5. Measure paragraph length CV (normal: >0.20; suspicious: <0.15)
6. Count triadic lists per 500 words (normal: 0; suspicious: 2+)

If 3+ categories are suspicious, the text likely reads as AI-generated and should be rewritten using the strategies in Section 5.