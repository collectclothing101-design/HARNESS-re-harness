# Product Discovery - Multi-Agent Team Design

**Pattern**: Expert Pool  
**Domain**: E-commerce & Product Discovery  
**Objective**: Design and implement intelligent product discovery system

---

## Team Architecture

```
                    ┌─────────────────┐
                    │  Router Agent   │
                    │  (Classify Type)│
                    └────────┬────────┘
                             │
                 ┌───────────┼───────────┬──────────────┐
                 ▼           ▼           ▼              ▼
         ┌────────────┐ ┌──────────┐ ┌───────────┐ ┌─────────┐
         │ Semantic   │ │ Trending │ │ User      │ │ Catalog │
         │ Search     │ │ Analysis │ │ Behavior  │ │ Expert  │
         │ Expert     │ │ Expert   │ │ Expert    │ │         │
         └──────┬─────┘ └────┬─────┘ └────┬──────┘ └────┬────┘
                │            │            │             │
                └────────────┼────────────┼─────────────┘
                             ▼
                    ┌────────────────┐
                    │  Aggregator    │
                    │  Agent         │
                    └────────┬───────┘
                             ▼
                    ┌────────────────┐
                    │  Ranker Agent  │
                    │  (Final Output)│
                    └────────────────┘
```

---

## Agent Specifications

### 1. Router Agent
**Purpose**: Classify user query type and route to appropriate expert

**Input Contract**:
```json
{
  "user_query": "string",
  "context": {
    "user_id": "string",
    "search_history": ["string"],
    "current_filters": "object"
  }
}
```

**Output Contract**:
```json
{
  "query_type": "semantic_search | trending | user_behavior | catalog_browse",
  "confidence": 0.0..1.0,
  "routed_to": "expert_name",
  "reasoning": "string"
}
```

**Handoff**: Routes to expert based on query classification

**Wix API Domain**: N/A (orchestration only)

---

### 2. Semantic Search Expert
**Purpose**: Find products using semantic understanding of query intent

**Input Contract**:
```json
{
  "query": "string",
  "embedding": "vector",
  "filters": {
    "price_range": [number, number],
    "category": ["string"],
    "rating": number
  },
  "limit": 20
}
```

**Output Contract**:
```json
{
  "results": [
    {
      "product_id": "string",
      "title": "string",
      "relevance_score": 0.0..1.0,
      "metadata": "object"
    }
  ],
  "search_type": "semantic",
  "total_found": number
}
```

**Validation**: Relevance scores > 0.7

---

### 3. Trending Analysis Expert
**Purpose**: Identify trending products and emerging categories

**Input Contract**:
```json
{
  "timeframe": "24h | 7d | 30d",
  "category": "string | null",
  "limit": 20
}
```

**Output Contract**:
```json
{
  "trending_products": [
    {
      "product_id": "string",
      "trend_score": 0.0..1.0,
      "velocity": "rapid | moderate | steady",
      "reason": "string"
    }
  ],
  "market_insights": "string"
}
```

---

### 4. User Behavior Expert
**Purpose**: Recommend products based on user history and preferences

**Input Contract**:
```json
{
  "user_id": "string",
  "behavior_signals": {
    "viewed_products": ["string"],
    "purchased": ["string"],
    "liked": ["string"],
    "abandoned_cart": ["string"]
  }
}
```

**Output Contract**:
```json
{
  "personalized_recommendations": [
    {
      "product_id": "string",
      "reason": "string",
      "confidence": 0.0..1.0
    }
  ],
  "user_segment": "string",
  "next_likely_purchase": "string"
}
```

---

### 5. Catalog Expert
**Purpose**: Browse and explore catalog structure, categories, and inventory

**Input Contract**:
```json
{
  "browse_type": "category | subcategory | new_arrivals | inventory",
  "path": "string",
  "limit": 20,
  "offset": 0
}
```

**Output Contract**:
```json
{
  "catalog_items": [
    {
      "product_id": "string",
      "category": "string",
      "in_stock": boolean,
      "availability": "string"
    }
  ],
  "total_items": number,
  "subcategories": ["string"]
}
```

---

### 6. Aggregator Agent
**Purpose**: Combine results from all experts into unified dataset

**Input Contract**:
- Semantic Search Expert output
- Trending Analysis output
- User Behavior output
- Catalog Expert output

**Output Contract**:
```json
{
  "consolidated_results": [
    {
      "product_id": "string",
      "sources": ["semantic", "trending", "personalized"],
      "combined_score": 0.0..1.0
    }
  ],
  "aggregation_method": "weighted_ensemble"
}
```

---

### 7. Ranker Agent
**Purpose**: Final ranking and deduplication, produce user-facing results

**Input Contract**:
- Aggregator output
- User preferences/filters

**Output Contract**:
```json
{
  "final_results": [
    {
      "rank": 1,
      "product_id": "string",
      "title": "string",
      "relevance": 0.0..1.0,
      "why_shown": "string"
    }
  ],
  "count": number,
  "query_execution_time_ms": number
}
```

---

## Validation Gates

### Gate 1: Query Understanding
**Agent**: Router Agent  
**Check**: Query classified with confidence > 0.7  
**Failure**: Return clarification request to user

### Gate 2: Expert Output Validation
**Between**: Each Expert → Aggregator  
**Check**: Output matches expected schema  
**Failure**: Return contract mismatch error, re-run expert

### Gate 3: Aggregation Integrity
**Agent**: Aggregator  
**Check**: All expert outputs successfully merged  
**Failure**: Use available results, note missing experts

### Gate 4: Final Ranking
**Agent**: Ranker  
**Check**: Results ranked by relevance, no duplicates  
**Failure**: Return partial results with warnings

---

## Error Recovery

### Scenario: Expert Timeout
**Detection**: Expert takes > 5 seconds  
**Recovery**: 
1. Skip slow expert, use other results
2. Mark expert as slower in future routing
3. Return partial results with notification

### Scenario: No Results from Expert
**Detection**: Expert returns empty result set  
**Recovery**:
1. Skip to next expert
2. Try broader query parameters
3. Fall back to catalog browse

### Scenario: Conflicting Results
**Detection**: Experts rank same product differently  
**Recovery**:
1. Weighted voting by expert reliability
2. Flag high-conflict items for review
3. Use aggregator ensemble score

---

## File Structure

```
product-discovery/
├── agents/
│   ├── 1_RouterAgent.md
│   ├── 2_SemanticSearchExpert.md
│   ├── 3_TrendingAnalysisExpert.md
│   ├── 4_UserBehaviorExpert.md
│   ├── 5_CatalogExpert.md
│   ├── 6_AggregatorAgent.md
│   └── 7_RankerAgent.md
├── src/
│   ├── router.py
│   ├── semantic_search.py
│   ├── trending.py
│   ├── user_behavior.py
│   ├── catalog.py
│   ├── aggregator.py
│   └── ranker.py
├── references/
│   ├── api_schema.openapi.json
│   ├── data_models.json
│   ├── ranking_algorithm.md
│   ├── test_cases.md
│   └── examples.md
├── orchestration.md
├── SKILL.md
└── validation_gates.md
```

---

## Implementation Timeline

- **Phase 1** (Days 1-2): Router Agent + Expert scaffolds
- **Phase 2** (Days 3-5): Implement all experts
- **Phase 3** (Days 6-7): Aggregator + Ranker
- **Phase 4** (Days 8): Validation gates + error recovery
- **Phase 5** (Days 9-10): Testing + optimization
- **Phase 6** (Day 11): Integration + deployment

---

## Next Steps

1. Review each agent's responsibilities
2. Implement agents in src/ following 1_XXX.md specs
3. Validate at each gate
4. Test with sample queries
5. Optimize ranking algorithm
6. Deploy to production
