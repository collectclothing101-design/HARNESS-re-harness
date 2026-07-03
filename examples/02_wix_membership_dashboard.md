# Wix Membership Dashboard - Multi-Agent Feature Design

**Feature Type**: Dashboard  
**App Context**: Membership Management Application  
**Backend Required**: Yes (HTTP Functions + Data Collections)

---

## Agent Team (5 Specialists)

```
┌──────────────────────────────────────┐
│ 1. UIDesignAgent                     │
│ Select WDS components, layout         │
└────────────┬─────────────────────────┘
             │ Output: Component spec
             ▼
┌──────────────────────────────────────┐
│ 2. APIContractAgent                  │
│ Define data schema, request/response  │
└────────────┬─────────────────────────┘
             │ Output: OpenAPI schema
             ▼
┌──────────────────────────────────────┐
│ 3. ValidationAgent                   │
│ Input validation, business rules      │
└────────────┬─────────────────────────┘
             │ Output: Validation rules
             ▼
┌──────────────────────────────────────┐
│ 4. BackendImplementationAgent        │
│ HTTP functions, data model           │
└────────────┬─────────────────────────┘
             │ Output: Backend code
             ▼
┌──────────────────────────────────────┐
│ 5. TestingAgent                      │
│ Test strategy, coverage targets      │
└──────────────────────────────────────┘
```

---

## Agent 1: UI Design Agent

**File**: `agents/1_UIDesignAgent.md`

**Purpose**: Select Wix Design System components and layout dashboard

**Input Contract**:
```
Feature requirements from product spec
- Dashboard sections needed
- Data to display
- User interactions
- Design constraints
```

**Output Contract**:
```
Component selection with:
- WDS components chosen (Card, Table, Chart, Form, etc.)
- Layout grid (rows/columns)
- Styling tokens (colors, spacing, typography)
- Responsive breakpoints
- Accessibility attributes
```

**Wix API Domain**: Wix Design System (WDS), component library

**Responsibilities**:
1. Analyze dashboard requirements
2. Select WDS components for each section
3. Design responsive grid layout
4. Apply design tokens
5. Document component props and variants
6. Ensure accessibility (ARIA labels, keyboard nav)

**Example Components**:
- `Card` - Display membership info
- `Table` - List members, subscriptions
- `Chart` - Visualize metrics
- `Form` - Edit member details
- `Tabs` - Organize sections
- `Breadcrumb` - Navigation

**Output Files**:
```
src/components/
├── MembershipDashboard.tsx
├── MemberInfoCard.tsx
├── SubscriptionTable.tsx
├── MetricsChart.tsx
├── MemberEditForm.tsx
└── DashboardLayout.tsx
```

---

## Agent 2: API Contract Agent

**File**: `agents/2_APIContractAgent.md`

**Purpose**: Define data schema and API contracts

**Input Contract**:
```
- UI component requirements
- Data types needed
- User interactions
```

**Output Contract**:
```
OpenAPI 3.1 specification with:
- Data models (Member, Subscription, Metrics)
- API endpoints (/members, /subscriptions, etc.)
- Request/response schemas
- Error responses
- Example payloads
```

**Wix API Domain**: Wix REST API, Data Collections, HTTP Functions

**Responsibilities**:
1. Define data models (JSON Schema)
2. Design HTTP endpoints
3. Specify request parameters
4. Define response formats
5. Document error responses
6. Create request/response examples

**Example Data Models**:

```json
Member:
{
  "id": "string",
  "email": "string",
  "name": "string",
  "joinDate": "ISO8601",
  "subscriptionStatus": "active | paused | expired",
  "tier": "basic | premium | vip"
}

Subscription:
{
  "id": "string",
  "memberId": "string",
  "tier": "string",
  "billingCycle": "monthly | yearly",
  "renewalDate": "ISO8601",
  "amount": "number"
}
```

**Example Endpoints**:

```
GET /members - List all members
GET /members/{id} - Get member details
PATCH /members/{id} - Update member
GET /subscriptions - List subscriptions
GET /metrics - Dashboard metrics
```

**Output Files**:
```
references/
├── api_contract.openapi.json
├── member_schema.json
├── subscription_schema.json
└── metrics_schema.json
```

---

## Agent 3: Validation Agent

**File**: `agents/3_ValidationAgent.md`

**Purpose**: Define input validation rules and business logic constraints

**Input Contract**:
```
- API schema from APIContractAgent
- Business rules
- User interactions
```

**Output Contract**:
```
Validation rules JSON with:
- Field-level validations
- Business rule constraints
- Error messages
- Edge cases
```

**Wix API Domain**: Wix Hooks API (beforeSubmit, afterSubmit)

**Responsibilities**:
1. Define field validation rules
2. Validate email format, phone, etc.
3. Check subscription status transitions
4. Validate member tier changes
5. Handle edge cases
6. Create error messages

**Example Validation Rules**:

```json
{
  "email": {
    "required": true,
    "format": "email",
    "error": "Valid email required"
  },
  "tier": {
    "enum": ["basic", "premium", "vip"],
    "error": "Invalid tier selection"
  },
  "subscriptionStatus": {
    "enum": ["active", "paused", "expired"],
    "transitions": {
      "active": ["paused", "expired"],
      "paused": ["active", "expired"],
      "expired": ["active"]
    },
    "error": "Invalid subscription status transition"
  }
}
```

**Edge Cases**:
- Cannot pause expired subscription
- Cannot upgrade to lower tier
- Cannot cancel during trial period
- Must have valid payment method for renewal

**Output Files**:
```
references/
├── validation_rules.json
└── business_rules.md
```

---

## Agent 4: Backend Implementation Agent

**File**: `agents/4_BackendImplementationAgent.md`

**Purpose**: Implement HTTP Functions and Data Collections

**Input Contract**:
```
- API contract
- Validation rules
- Data models
```

**Output Contract**:
```
Backend code with:
- HTTP functions (GET, POST, PATCH, DELETE)
- Data collection queries
- Error handling
- Authentication/authorization
```

**Wix API Domain**: Wix HTTP Functions, Data Collections, Contacts API

**Responsibilities**:
1. Create HTTP function handlers
2. Implement CRUD operations
3. Add authentication checks
4. Handle errors with proper status codes
5. Log operations for auditing
6. Query data collections

**Example HTTP Functions**:

```typescript
// GET /members
export async function get_members(request: HttpRequest) {
  const collection = wixData.query('Members')
    .find()
    .then(results => {
      return { members: results.items };
    })
    .catch(err => {
      console.error('Error fetching members:', err);
      return { error: 'Failed to fetch members' };
    });
}

// PATCH /members/{id}
export async function patch_members_id(request: HttpRequest) {
  const memberId = request.path.split('/').pop();
  const updates = JSON.parse(request.body);
  
  return wixData.update('Members', memberId, updates)
    .then(updated => ({ member: updated }))
    .catch(err => ({ error: err.message }));
}
```

**Output Files**:
```
src/backend/
├── members.web.ts
├── subscriptions.web.ts
├── metrics.web.ts
└── common/
    ├── auth.ts
    ├── errors.ts
    └── logger.ts
```

---

## Agent 5: Testing Agent

**File**: `agents/5_TestingAgent.md`

**Purpose**: Define test strategy and coverage targets

**Input Contract**:
```
- All agent outputs
- Feature spec
- Implementation code
```

**Output Contract**:
```
Test plan with:
- Unit tests per component
- Integration tests for flows
- E2E tests in Wix preview
- Coverage targets
- Test cases
```

**Wix API Domain**: Wix Testing SDK, site operations

**Responsibilities**:
1. Define test strategy
2. Create unit test cases
3. Create integration test cases
4. Create E2E test cases
5. Target 80%+ code coverage
6. Document test execution

**Test Categories**:

**Unit Tests** (Components):
- MemberInfoCard renders correctly
- SubscriptionTable sorts/filters
- MemberEditForm validation
- MetricsChart data formatting

**Integration Tests** (Features):
- Member list → select → edit → save
- Subscription upgrade flow
- Metrics dashboard loads data
- Error handling displays properly

**E2E Tests** (Full Flow):
- Login → view dashboard → edit member → save → verify in DB
- Create subscription → verify billing → check renewal date
- Filter members → export list → verify data

**Coverage Targets**:
- Branches: 80%+
- Functions: 90%+
- Statements: 85%+
- Lines: 85%+

**Output Files**:
```
src/tests/
├── components/
│   ├── MembershipDashboard.test.tsx
│   └── MemberEditForm.test.tsx
├── integration/
│   └── member_edit_flow.test.ts
├── e2e/
│   └── membership_dashboard.e2e.ts
└── coverage_report.json
```

---

## Orchestration

### Handoff Sequence

1. **UI Design** (Agent 1)
   - Output: Component selection + layout spec
   - Validates: Layout is responsive, accessible

2. **API Contract** (Agent 2)
   - Input: Component spec
   - Output: OpenAPI schema
   - Validates: Schema matches component data needs

3. **Validation** (Agent 3)
   - Input: API schema
   - Output: Validation rules
   - Validates: Rules cover all fields and edge cases

4. **Backend Implementation** (Agent 4)
   - Input: API contract + validation rules
   - Output: HTTP functions + data collections
   - Validates: Functions implement API contract

5. **Testing** (Agent 5)
   - Input: All implementations
   - Output: Test suite
   - Validates: 80%+ coverage achieved

### Validation Gates

**Gate 1: UI Component Compliance**
- Agent 1 output uses only WDS components
- Layout responsive at all breakpoints
- ARIA labels present for accessibility
- Failure: Return component compliance report

**Gate 2: API Contract Alignment**
- Agent 2 output matches Agent 1 data needs
- All required fields defined
- Error responses specified
- Failure: Request schema revision

**Gate 3: Validation Coverage**
- Agent 3 covers all API fields
- Business rules documented
- Edge cases handled
- Failure: Request validation rule additions

**Gate 4: Backend Completeness**
- Agent 4 implements all API endpoints
- Auth checks present
- Error handling comprehensive
- Failure: Request implementation review

**Gate 5: Test Coverage**
- Agent 5 achieves 80%+ coverage
- All flows tested
- E2E tests pass
- Failure: Request additional test cases

---

## Success Criteria

- [x] All agents complete successfully
- [x] Output passes all validation gates
- [x] API contract fully implemented
- [x] Test coverage >= 80%
- [x] Code ready for pull request
- [x] Wix preview environment works
- [x] Dashboard loads and displays data
- [x] Member edits persist to database

---

## File Structure

```
membership-dashboard/
├── agents/
│   ├── 1_UIDesignAgent.md
│   ├── 2_APIContractAgent.md
│   ├── 3_ValidationAgent.md
│   ├── 4_BackendImplementationAgent.md
│   └── 5_TestingAgent.md
├── src/
│   ├── components/
│   │   ├── MembershipDashboard.tsx
│   │   ├── MemberInfoCard.tsx
│   │   ├── SubscriptionTable.tsx
│   │   ├── MetricsChart.tsx
│   │   ├── MemberEditForm.tsx
│   │   └── DashboardLayout.tsx
│   ├── backend/
│   │   ├── members.web.ts
│   │   ├── subscriptions.web.ts
│   │   ├── metrics.web.ts
│   │   └── common/
│   │       ├── auth.ts
│   │       ├── errors.ts
│   │       └── logger.ts
│   └── tests/
│       ├── components/
│       ├── integration/
│       └── e2e/
├── references/
│   ├── api_contract.openapi.json
│   ├── member_schema.json
│   ├── subscription_schema.json
│   ├── validation_rules.json
│   ├── business_rules.md
│   └── test_cases.md
├── orchestration.md
├── SKILL.md
└── wix.config.json
```

---

## Next Steps

1. Review each agent file (1_UIDesignAgent.md through 5_TestingAgent.md)
2. Follow handoff sequence
3. Implement code in src/
4. Test each gate
5. Merge to main when all tests pass
6. Deploy to Wix preview
7. Publish to production
