# Content Analysis

## Description

Advanced skill for analyzing, understanding, and extracting insights from content across multiple formats and domains. This skill uses a multi-agent Harness architecture with specialist agents:

- **ContentParserAgent**: Extract and structure content from various formats
- **SemanticAnalysisAgent**: Understand meaning, topics, and themes
- **SentimentAnalysisAgent**: Analyze emotional tone and user sentiment
- **KeyEntityExtractionAgent**: Identify important concepts, people, places, organizations
- **SummaryGenerationAgent**: Create concise, accurate summaries
- **InferenceAgent**: Draw conclusions and answer questions about content

### When to Use

- Analyzing blog posts, articles, or written content
- Extracting insights from customer feedback or reviews
- Understanding themes and topics in large documents
- Determining sentiment in user-generated content
- Creating structured summaries from unstructured text
- Answering complex questions that require understanding content relationships
- Multi-step content workflows requiring specialist coordination

### Why This Skill

Progressive-disclosure architecture: core agents for 80% of analysis tasks (parsing, basic sentiment, key entities), advanced agents for 20% of complex scenarios (inference, cross-content analysis, nuanced semantic understanding).

---

## Trigger Patterns

Use this skill when:

- "Analyze this article for me" - Parse and extract key information
- "What's the overall sentiment of this feedback?" - Sentiment analysis needed
- "Summarize this document" - Summary generation required
- "Extract key topics from this text" - Topic/entity extraction needed
- "Answer this question based on the document" - Inference and reasoning needed
- "Process multiple documents and find patterns" - Complex multi-step analysis

---

## Core Tools

### ContentParserAgent

**Purpose**: Extract and structure content from various formats

**Handles**:
- Plain text, HTML, Markdown, PDF
- Extracting sections, headings, paragraphs
- Parsing tables, lists, structured data
- Cleaning and normalizing content

**Input**: Raw content in any format + format specification  
**Output**: Structured content object with:
```json
{
  "title": "string",
  "sections": [{"heading": "string", "body": "string"}],
  "tables": [{"headers": [], "rows": []}],
  "language": "detected_language",
  "reading_level": "grade_level"
}
```

**When to use first**: Always start with parsing to structure content

---

### SemanticAnalysisAgent

**Purpose**: Understand meaning, topics, and thematic relationships

**Handles**:
- Topic extraction and clustering
- Semantic relationships between concepts
- Theme identification
- Contextual understanding

**Input**: Structured content from parser  
**Output**: Semantic analysis with:
```json
{
  "primary_topics": [{"topic": "string", "relevance": 0.0..1.0}],
  "themes": ["string"],
  "semantic_relationships": [{"from": "string", "to": "string", "relationship": "string"}],
  "language_register": "formal | informal | technical"
}
```

**When to use**: After parsing, when understanding content meaning is important

---

### SentimentAnalysisAgent

**Purpose**: Analyze emotional tone and user sentiment

**Handles**:
- Overall sentiment (positive/negative/neutral)
- Granular sentiment per section
- Emotion detection (joy, anger, fear, surprise)
- Confidence scoring

**Input**: Structured content + section-level breakdown  
**Output**: Sentiment analysis with:
```json
{
  "overall_sentiment": "positive | negative | neutral",
  "confidence": 0.0..1.0,
  "emotions": [{"type": "joy|anger|fear|surprise|sadness", "intensity": 0.0..1.0}],
  "section_sentiments": [{"section": "string", "sentiment": "string"}]
}
```

**When to use**: For customer feedback, reviews, or any content where emotional tone matters

---

### KeyEntityExtractionAgent

**Purpose**: Identify important concepts, people, organizations, locations

**Handles**:
- Named entity recognition (person, org, location)
- Concept extraction (abstract ideas)
- Relationship mapping between entities
- Frequency analysis

**Input**: Structured content  
**Output**: Entity extraction with:
```json
{
  "entities": [
    {
      "text": "string",
      "type": "person | organization | location | concept",
      "mentions": number,
      "confidence": 0.0..1.0
    }
  ],
  "entity_relationships": [
    {"entity1": "string", "entity2": "string", "relationship": "string"}
  ]
}
```

**When to use**: When identifying key concepts, people, or organizations matters

---

### SummaryGenerationAgent

**Purpose**: Create concise, accurate summaries at various levels

**Handles**:
- Extractive summaries (select key sentences)
- Abstractive summaries (rewrite in new words)
- Multi-level summaries (paragraph, page, document)
- Bullet-point summaries

**Input**: Structured content + summary type  
**Output**: Summary with:
```json
{
  "summary": "string",
  "type": "extractive | abstractive",
  "compression_ratio": 0.0..1.0,
  "key_points": ["string"],
  "coverage": 0.0..1.0
}
```

**When to use**: When you need concise overview of content

---

## Advanced Tools

### InferenceAgent

**Purpose**: Answer questions and draw conclusions from content

**Handles**:
- Question answering with evidence
- Hypothesis testing against content
- Causal inference
- Comparative analysis

**Input**: Structured content + question/inference task  
**Output**: Inference result with:
```json
{
  "answer": "string",
  "confidence": 0.0..1.0,
  "supporting_evidence": ["string"],
  "reasoning": "string"
}
```

**When to use**: Advanced scenario - answering complex questions or testing hypotheses

---

### Multi-DocumentAnalysisAgent

**Purpose**: Analyze patterns and relationships across multiple documents

**Handles**:
- Cross-document topic analysis
- Comparative sentiment analysis
- Contradiction detection
- Pattern identification across documents

**Input**: Analysis results from multiple documents  
**Output**: Cross-document insights with:
```json
{
  "common_themes": ["string"],
  "divergent_topics": ["string"],
  "sentiment_comparison": "object",
  "patterns": ["string"]
}
```

**When to use**: Advanced scenario - comparing multiple documents or finding patterns

---

## Integration Points

### With Other Skills

- **text-summarization**: Use SummaryGenerationAgent for structured summaries
- **sentiment-detection**: Use SentimentAnalysisAgent for real-time sentiment scoring
- **topic-modeling**: Use SemanticAnalysisAgent for topic extraction
- **qa-system**: Use InferenceAgent for question answering

### With Orchestration

Content analysis uses a sequential pipeline with optional branching:

```
1. ContentParserAgent
   ↓
2. [SemanticAnalysisAgent | SentimentAnalysisAgent | KeyEntityExtractionAgent]
   ↓
3. SummaryGenerationAgent (optional)
   ↓
4. InferenceAgent (advanced queries)
```

Agents run in parallel when independent, merge results at aggregation point.

---

## References

- `content_parser_schema.json` - Input/output formats for parsing
- `semantic_analysis_examples.md` - Examples of topic/theme extraction
- `sentiment_reference.md` - Sentiment categories and scoring
- `entity_types.json` - Entity classification system
- `orchestration.md` - Full agent handoff sequence
- `validation_gates.md` - Quality checks between agents
- `test_cases.md` - Example analyses and expected outputs

---

## Quick Start

### Scenario 1: Analyze Customer Feedback

```
1. Use ContentParserAgent
   Input: Raw feedback text
   Output: Structured feedback

2. Use SentimentAnalysisAgent
   Input: Structured feedback
   Output: Overall sentiment + emotions

3. Use KeyEntityExtractionAgent
   Input: Structured feedback
   Output: Key issues mentioned

4. Aggregate
   Output: Sentiment + issues for action
```

### Scenario 2: Summarize Long Document

```
1. Use ContentParserAgent
   Input: Long document
   Output: Structured sections

2. Use SemanticAnalysisAgent
   Input: Structured content
   Output: Primary topics + themes

3. Use SummaryGenerationAgent
   Input: Structured content + semantic analysis
   Output: Concise summary with key points
```

### Scenario 3: Complex Question Answering

```
1. Use ContentParserAgent
   Input: Document
   Output: Structured content

2. Use SemanticAnalysisAgent
   Input: Structured content
   Output: Topic/concept mapping

3. Use InferenceAgent
   Input: Structured content + question
   Output: Answer with evidence
```

---

## Implementation Examples

### Example 1: Analyze Blog Post for SEO

```
Input Blog Post:
"10 Tips for Remote Work Productivity"

ContentParserAgent output:
- Title: "10 Tips for Remote Work Productivity"
- Sections: [Introduction, Tip1, Tip2, ..., Conclusion]
- Reading level: 8th grade

SemanticAnalysisAgent output:
- Primary topics: ["Remote Work" (0.95), "Productivity" (0.92)]
- Themes: ["Time Management", "Focus", "Work-Life Balance"]

KeyEntityExtractionAgent output:
- Concepts: ["Remote Work", "Productivity", "Focus"]
- Mentioned tools: ["Slack", "Asana", "Zoom"]

SummaryGenerationAgent output:
- "10 practical tips for improving remote work productivity, including time management, focus techniques, and tool recommendations"

Result: SEO keywords, topic focus, concept importance
```

### Example 2: Analyze Customer Support Tickets

```
Input Tickets:
["The product arrived broken", "Great service, would buy again", "Still waiting for refund"]

SentimentAnalysisAgent output:
- Ticket 1: Negative (0.92)
- Ticket 2: Positive (0.88)
- Ticket 3: Negative (0.75)

KeyEntityExtractionAgent output:
- Issues: ["Product Damage", "Shipping Speed", "Refund Processing"]
- Frequency: [1, 1, 1]

Result: Sentiment distribution + action items (fix packaging, speed up refunds)
```

---

## Validation Gates

All analyses pass through validation gates:

**Gate 1: Parse Completeness**
- Check: Content successfully parsed into sections
- Failure: Return parse error with sample content

**Gate 2: Semantic Coverage**
- Check: Primary topics identified (confidence > 0.7)
- Failure: Request broader content sample

**Gate 3: Sentiment Confidence**
- Check: Overall sentiment confidence > 0.6
- Failure: Return mixed/uncertain sentiment result

**Gate 4: Entity Validation**
- Check: Extracted entities appear in original text
- Failure: Remove unsupported entities

**Gate 5: Summary Accuracy**
- Check: Summary covers main topics from content
- Failure: Regenerate with broader scope

---

## Advanced Patterns

### Pattern: Comparative Analysis

Compare sentiment/topics across multiple documents:

```
Input: [Document1, Document2, Document3]

→ Analyze each with core agents
→ Use Multi-DocumentAnalysisAgent
→ Output: Common themes, divergent views, overall patterns
```

### Pattern: Topic Tracking

Track how topic/sentiment evolves:

```
Input: [Document_v1, Document_v2, Document_v3] (over time)

→ Parse each
→ Extract sentiment per version
→ Extract topics per version
→ Identify evolution pattern
→ Output: Change trajectory
```

### Pattern: Question Bank

Answer multiple questions about same content:

```
Input: Document + [Question1, Question2, Question3]

→ Parse document once
→ Use InferenceAgent on each question
→ Aggregate answers with evidence
→ Output: Comprehensive Q&A
```

---

## Testing

Content analysis skill tested with:

- **Parsing**: Multiple formats (text, HTML, PDF, JSON)
- **Sentiment**: Known sentiment datasets (positive/negative/neutral)
- **Entity extraction**: Wikipedia/news articles with known entities
- **Summaries**: Compression ratio and coverage targets
- **Inference**: Question answering with ground truth answers

Coverage target: 85%+

---

## Implementation Status

- [x] Content parsing (all formats)
- [x] Semantic analysis (topics + themes)
- [x] Sentiment analysis (emotions + confidence)
- [x] Entity extraction (people, orgs, concepts)
- [x] Summary generation (extractive + abstractive)
- [x] Inference engine (Q&A + hypothesis testing)
- [x] Multi-document analysis (cross-document patterns)
- [x] Validation gates (quality checks)

Ready for production use.
