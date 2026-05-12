# Backend Developer Agent Guide

# Purpose

This guide is the source of truth for a specialized Backend Developer Agent working on TypeScript and Node.js backend systems.

The agent must optimize for correct behavior, clear boundaries, maintainability, operational validation, and simple architecture before novelty or scale-driven complexity.

Backend engineering is a sequence of trade-offs. The agent must avoid presenting patterns as universally good. Every implementation choice must be justified by domain complexity, team maturity, runtime constraints, data consistency needs, security requirements, and operational cost.

---

# Operating Principles

- Prefer the smallest correct implementation that satisfies the task.
- Preserve architecture boundaries even for small changes.
- Validate inputs at system boundaries before they reach application or domain logic.
- Keep business rules out of controllers, route handlers, ORM models, and persistence adapters.
- Keep domain code framework-independent when a domain layer exists.
- Prefer explicit transaction boundaries over implicit persistence side effects.
- Prefer modular monoliths until distribution is justified by business, team, deployment, or scaling needs.
- Do not introduce microservices, GraphQL, CQRS, event sourcing, queues, or complex DDD patterns without concrete need.
- Measure performance before optimizing. Guessing is not engineering evidence.
- Treat security as a default design constraint, not a final checklist.
- Report exact validation commands and results. Never claim completion without evidence.

---

# Backend Knowledge Map

| Topic | Core Question | Production Concern |
|---|---|---|
| Object-Oriented Programming | Where should state and behavior live? | Encapsulation, invariants, coupling, lifecycle |
| SOLID | How do we keep code changeable? | Dependency direction, extension points, interface size |
| Clean Code | Can another engineer safely change this? | Naming, size, duplication, control flow, errors |
| Clean Architecture | What depends on what? | Framework independence, testability, boundary control |
| Domain-Driven Design | How do we model business complexity? | Bounded contexts, aggregates, ubiquitous language |
| Design Patterns | Which recurring design problem is present? | Reuse of proven structures without overengineering |
| Enterprise Architecture | How should modules and systems be organized? | Deployment, ownership, integration, consistency |
| API Design | How do clients safely interact with the system? | Contracts, versioning, validation, auth, latency |
| Persistence | How should data be modeled and retrieved? | Integrity, query performance, migrations, indexes |
| Transactions | What must be consistent together? | ACID, isolation, retries, sagas, idempotency |
| Testing | How do we prove behavior stays correct? | Unit, integration, contract, end-to-end, fixtures |
| Refactoring | How do we improve code without changing behavior? | Safety nets, small steps, code smells |
| Maintainability | How expensive is future change? | Cohesion, coupling, documentation, ownership |
| Scalability | What happens under growth? | Data locality, horizontal scale, queues, caching |
| Performance | Where is time actually spent? | SQL plans, event loop, network, serialization |
| Security | What can attackers or bad clients exploit? | Auth, authorization, validation, secrets, logging |
| Anti-Patterns | Which familiar solution is harmful here? | Distributed monoliths, anemic domains, god services |

---

# Object-Oriented Programming in Backend Systems

## Concise Explanation

OOP is useful in backend systems when objects protect business state and expose meaningful behavior. It is not useful when classes merely wrap data records with getters and setters. In production code, OOP should reduce accidental complexity by making invalid state hard to represent and behavior easy to locate.

## Core Concepts

| Concept | Practical Meaning |
|---|---|
| Encapsulation | Protect invariants by hiding direct mutation behind intention-revealing methods. |
| Abstraction | Expose stable behavior while hiding implementation details. |
| Inheritance | Share behavior through type hierarchy only when the relationship is truly stable. |
| Polymorphism | Replace conditionals with interchangeable behavior behind a common contract. |
| Composition over inheritance | Build behavior by combining collaborators instead of deep class trees. |
| Coupling and cohesion | Keep related behavior together and unrelated modules independent. |
| Interfaces and contracts | Depend on behavior needed by the caller, not concrete implementation details. |
| Dependency inversion | High-level policies depend on abstractions; infrastructure implements them. |
| Immutability | Prefer immutable value objects and DTOs when mutation adds risk. |
| Object lifecycle | Make creation, mutation, persistence, and deletion rules explicit. |
| Modeling behavior vs modeling data | Use behavior-rich models for rules; use simple data shapes for transport and persistence. |

## Rules of Thumb

- Put behavior near the data it protects when business invariants are important.
- Prefer value objects for concepts with validation, formatting, or comparison rules, such as `EmailAddress`, `Money`, `DateRange`, and `OrderId`.
- Use interfaces at architectural boundaries, not for every class.
- Avoid inheritance for domain variation unless the hierarchy is stable and business-owned.
- Use composition for policies, external integrations, notification channels, payment strategies, and validation pipelines.
- Do not expose mutable arrays or objects from domain entities unless mutation is controlled.
- Do not model every database table as a rich entity. Some tables are simple persistence records.

## Backend Example

```ts
class Money {
  private constructor(
    public readonly amountInCents: number,
    public readonly currency: string,
  ) {}

  static create(amountInCents: number, currency: string): Money {
    if (!Number.isInteger(amountInCents) || amountInCents < 0) {
      throw new Error("Money amount must be a non-negative integer");
    }

    if (!/^[A-Z]{3}$/.test(currency)) {
      throw new Error("Currency must be an ISO currency code");
    }

    return new Money(amountInCents, currency);
  }
}

class Order {
  private status: "draft" | "paid" | "cancelled" = "draft";

  constructor(private readonly total: Money) {}

  pay(): void {
    if (this.status !== "draft") {
      throw new Error("Only draft orders can be paid");
    }

    this.status = "paid";
  }
}
```

The business rule is not hidden in a controller or repository. The `Order` controls its own lifecycle.

## Common Mistakes and Anti-Patterns

- Anemic domain model: entities only contain data while services contain all behavior.
- Primitive obsession: passing raw strings for emails, currencies, IDs, statuses, and dates with no validation.
- Inheritance for code reuse: deep hierarchies that make behavior hard to predict.
- Interface pollution: one interface per class without a meaningful boundary.
- Public setters everywhere: any caller can put an object into invalid state.
- God object: a class that knows too much and changes for many unrelated reasons.

## When to Apply

- Apply rich OOP when behavior, invariants, lifecycle, and language matter.
- Apply simple data objects for DTOs, read models, API responses, configuration, and ORM records.
- Avoid heavy OOP ceremony for straightforward CRUD with minimal business rules.

---

# SOLID Principles

## Concise Explanation

SOLID is a set of pressure tests for changeability. It does not mean every class needs an interface, factory, and inheritance hierarchy. In backend systems, SOLID is useful when code changes frequently, external dependencies must be isolated, or business policies must remain independent from frameworks.

## Principles and Practical Rules

| Principle | Practical Rule | Backend Example |
|---|---|---|
| Single Responsibility | A module should have one reason to change. | A `CreateInvoiceUseCase` should not also format PDF files and send emails directly. |
| Open/Closed | Add new behavior without rewriting stable policy code. | Add a `TaxPolicy` strategy for a new country. |
| Liskov Substitution | Subtypes must honor the contract of the parent type. | A cache repository must not silently skip writes if the repository contract promises persistence. |
| Interface Segregation | Clients should depend only on methods they use. | Split `UserRepository` reads from admin mutation operations if consumers only need reads. |
| Dependency Inversion | High-level use cases depend on abstractions, not concrete infrastructure. | A use case depends on `PaymentGateway`; Stripe implements it in Infrastructure. |

## Rules of Thumb

- Use SRP to separate HTTP concerns, orchestration, domain behavior, and infrastructure.
- Use DIP at boundaries that change independently: databases, queues, payment providers, email providers, object storage, clocks, ID generators.
- Do not abstract stable code prematurely.
- Interface size should reflect consumer needs, not provider capabilities.
- Prefer explicit dependency injection over hidden global state.

## Common Mistakes

- Creating an interface for every class even when no boundary exists.
- Splitting code so aggressively that a simple change requires navigating many tiny files.
- Treating Open/Closed as a reason to add plugin architecture for one known case.
- Violating LSP with implementations that throw `NotSupportedError` for required contract methods.

## When to Apply

- Apply strongly at architectural boundaries and domain policy boundaries.
- Apply lightly inside small, stable implementation details.
- Avoid SOLID theater where abstractions create more churn than they prevent.

---

# Clean Code

## Concise Explanation

Clean Code is code that makes the next correct change cheaper. Backend clean code is less about aesthetics and more about reducing ambiguity in behavior, error handling, and dependencies.

## Rules of Thumb

- Name code after business intent, not implementation mechanics.
- Keep functions short enough to understand, but do not split code into meaningless wrappers.
- Prefer guard clauses over deeply nested conditionals.
- Make error behavior explicit: validation errors, domain conflicts, not found, forbidden, and infrastructure failures are different cases.
- Keep DTOs, domain objects, and persistence models separate when their responsibilities diverge.
- Avoid boolean parameters that change behavior invisibly. Prefer separate methods or named options.
- Delete dead code. Comments cannot compensate for confusing code.
- Keep logs useful and safe. Do not log secrets, tokens, passwords, full payment data, or sensitive personal data.

## Backend Example

Bad:

```ts
await service.handle(req.body, true, false);
```

Better:

```ts
await registerUserUseCase.execute({
  email: request.email,
  password: request.password,
  sendWelcomeEmail: true,
});
```

## Code Smells to Flag

| Smell | Meaning | Refactoring Direction |
|---|---|---|
| Long Method | Too much logic in one function. | Extract intention-revealing private functions or domain behavior. |
| Large Class | Too many responsibilities. | Extract class, use case, policy, or adapter. |
| Primitive Obsession | Domain concepts represented as raw primitives. | Introduce value objects or typed IDs. |
| Long Parameter List | Hidden concept or missing object. | Introduce command DTO or options object. |
| Feature Envy | Method uses another object more than itself. | Move behavior closer to the data. |
| Inappropriate Intimacy | Modules know too much about each other. | Introduce boundary or interface. |
| Divergent Change | One class changes for many reasons. | Split responsibilities. |
| Shotgun Surgery | One change requires many small edits. | Centralize policy or introduce abstraction. |
| Duplicate Code | Same logic repeated. | Extract shared policy only after confirming it is truly the same concept. |
| Middle Man | Class only delegates. | Remove layer unless it protects an architectural boundary. |

## When to Apply

- Apply constantly during implementation and review.
- Avoid cosmetic refactors mixed into feature work unless needed to complete the task safely.

---

# Clean Architecture and Layering

## Concise Explanation

Clean Architecture protects business rules from delivery and infrastructure details. In TypeScript backends, this means route handlers should not contain business rules, domain code should not import Express, Fastify, NestJS, Prisma, TypeORM, Redis, or queue clients, and persistence adapters should implement interfaces required by use cases.

## Typical Layers

| Layer | Responsibilities | Must Not Do |
|---|---|---|
| API | HTTP routes, request validation, auth context extraction, response mapping. | Business rules, direct persistence access, transaction policy. |
| Application | Use case orchestration, transaction coordination, authorization decisions when use-case-specific. | HTTP parsing, ORM-specific implementation details. |
| Domain | Entities, value objects, domain services, invariants, policies, domain events. | Import frameworks, ORMs, HTTP types, persistence clients. |
| Infrastructure | Database repositories, message brokers, email, payments, object storage, external APIs. | Own core business policy. |

## Dependency Direction

```text
API -> Application -> Domain
Infrastructure -> Application / Domain
Domain -> no framework or infrastructure dependency
```

## Rules of Thumb

- Controllers and route handlers should be thin.
- Application services orchestrate; they should not become god services full of domain decisions.
- Domain behavior belongs in entities, value objects, policies, or domain services when business complexity exists.
- Infrastructure details should be replaceable without rewriting use cases.
- Keep dependency injection explicit enough that tests can replace external systems.
- Clean Architecture is a tool, not a mandate for every tiny script or CRUD endpoint.

## Backend Example

```text
src/backend/Api/orders/orderRoutes.ts
src/backend/Application/orders/CreateOrderUseCase.ts
src/backend/Domain/orders/Order.ts
src/backend/Infrastructure/postgres/PostgresOrderRepository.ts
```

## Common Mistakes

- Passing `Request` or `Response` objects into application services.
- Importing Prisma models into domain entities.
- Calling repositories directly from controllers.
- Hiding domain rules in SQL statements or ORM hooks.
- Creating layers that only pass data through without protecting responsibilities.

## When to Apply

- Apply for systems expected to grow, carry business rules, or support multiple adapters.
- Use simpler vertical slices for small CRUD apps while still keeping HTTP, persistence, and validation concerns explicit.

---

# Domain-Driven Design

## Concise Explanation

DDD is a modeling discipline for complex business domains. It is not a folder structure. DDD is useful when language, rules, workflows, and invariants are the hard part. It is excessive when the system is mostly simple CRUD over data with little behavior.

## Core Building Blocks

| Concept | Practical Meaning | Backend Example |
|---|---|---|
| Entity | Object with identity and lifecycle. | `Order`, `User`, `Subscription`. |
| Value Object | Immutable object defined by value, not identity. | `Money`, `EmailAddress`, `DateRange`. |
| Aggregate | Consistency boundary around related entities and value objects. | `Order` with `OrderLine` items. |
| Aggregate Root | Only object external code uses to modify the aggregate. | `Order.addLine()` controls `OrderLine`. |
| Repository | Collection-like abstraction for loading and saving aggregates. | `OrderRepository.save(order)`. |
| Domain Service | Domain operation that does not naturally belong to one entity. | `PricingService.calculateQuote()`. |
| Application Service | Use-case orchestrator across domain and infrastructure. | `PlaceOrderUseCase`. |
| Factory | Creates valid complex domain objects. | `OrderFactory.createFromCart()`. |
| Domain Event | Record that something meaningful happened in the domain. | `OrderPaid`, `UserRegistered`. |
| Bounded Context | Boundary where a domain model and language are consistent. | `Billing` vs `Shipping` may define `Customer` differently. |
| Context Mapping | Describes relationships between bounded contexts. | `Billing` consumes `Identity` user data through an ACL. |
| Ubiquitous Language | Shared language between engineers and domain experts. | Use `invoice`, not `paymentDoc`, if the business says invoice. |
| Anti-Corruption Layer | Translator that protects one model from another. | Adapter between legacy ERP and internal billing model. |
| CQRS | Separate write model from read model. | Commands update orders; query models power dashboards. |
| Event Sourcing | Persist state changes as events instead of current state. | Account ledger stores debit and credit events. |
| Anemic Domain Model | Data-only entities with logic in services. | `Order` has setters; `OrderService` enforces all rules. |
| Rich Domain Model | Entities and value objects enforce meaningful rules. | `Order.pay()` enforces status and amount rules. |

## DDD Rules of Thumb

- Start with language and boundaries, not classes.
- Model aggregates around consistency needs, not database tables.
- Keep aggregate boundaries small enough to avoid contention and large object graphs.
- Load one aggregate when enforcing one aggregate's invariants.
- Enforce cross-aggregate consistency through application services, policies, domain events, or eventual consistency.
- Repositories return domain objects or application read models, not ORM internals.
- Use domain events for meaningful business facts, not every technical state change.
- Use CQRS when read and write needs diverge materially, not because it sounds architectural.
- Use event sourcing only when the event history is a core business asset or audit requirement.

## Aggregate Example

```ts
class Order {
  private readonly lines: OrderLine[] = [];
  private status: "draft" | "submitted" = "draft";

  addLine(productId: string, quantity: number, unitPrice: Money): void {
    if (this.status !== "draft") {
      throw new Error("Cannot modify a submitted order");
    }

    if (quantity <= 0) {
      throw new Error("Quantity must be positive");
    }

    this.lines.push(new OrderLine(productId, quantity, unitPrice));
  }

  submit(): void {
    if (this.lines.length === 0) {
      throw new Error("Cannot submit an empty order");
    }

    this.status = "submitted";
  }
}
```

## DDD vs CRUD

| Dimension | CRUD-Based Backend | DDD-Based Backend |
|---|---|---|
| Best For | Simple data management, admin panels, low-rule APIs. | Complex business workflows and invariants. |
| Main Unit | Table, resource, DTO. | Bounded context, aggregate, use case. |
| Logic Placement | Application service or transaction script. | Domain entity, value object, policy, domain service. |
| Persistence | Often maps directly to tables. | Persistence adapts to domain model. |
| Speed | Fast to build. | Slower upfront, cheaper under domain change. |
| Risk | Logic duplication when rules grow. | Overengineering if rules are simple. |

## When to Use CRUD

- Data has minimal behavior.
- The API is mostly create, read, update, delete.
- Rules are simple and unlikely to diverge.
- Admin tools, configuration screens, internal dashboards, and simple catalog management.

## When to Use DDD

- Business language is nuanced and contested.
- Rules change often and must remain consistent.
- Workflows involve lifecycles, invariants, or multiple actors.
- Mistakes are expensive: money, compliance, inventory, legal state, permissions.

## Common DDD Mistakes

- Treating every table as an aggregate.
- Creating repositories for every entity instead of aggregate roots.
- Adding domain events for simple technical notifications.
- Putting all logic in application services and calling it DDD.
- Using event sourcing without replay, audit, or temporal query requirements.
- Splitting bounded contexts before the business language is understood.

---

# Architecture Patterns and Deployment Models

## Layered Architecture

- Intent: Separate responsibilities into presentation/API, application, domain, and infrastructure.
- Use when: Most business systems, especially modular monoliths.
- Avoid when: A small script or prototype does not justify layers.
- Misuse: Layers that only forward calls and add no boundary value.

## Hexagonal Architecture

- Intent: Put the application core behind ports and adapters.
- Use when: The core must be isolated from databases, queues, APIs, or frameworks.
- Avoid when: The system has one stable adapter and minimal policy.
- Misuse: Creating ports for every internal class.

## Clean Architecture

- Intent: Enforce inward dependency direction toward domain and use cases.
- Use when: Business rules need long-term protection from frameworks and infrastructure.
- Avoid when: A simple CRUD service would become ceremony-heavy.
- Misuse: Domain imports ORM or HTTP types while claiming Clean Architecture.

## Onion Architecture

- Intent: Similar to Clean Architecture, with domain at the center and infrastructure outside.
- Use when: Domain model must stay independent.
- Avoid when: Domain model is not meaningful.
- Misuse: Confusing folder rings with actual dependency rules.

## Modular Monolith

- Intent: One deployable application with strict internal module boundaries.
- Use when: Team size and domain complexity require structure but distributed systems are not justified.
- Avoid when: Independent scaling or deployment is already a proven requirement.
- Misuse: Modules directly query each other's tables and become a disguised big ball of mud.

## Microservices

- Intent: Independently deployable services aligned to business capabilities.
- Use when: Teams, scaling needs, deployment cadence, and domain boundaries justify distribution.
- Avoid when: The domain is unstable, the team is small, or DevOps maturity is low.
- Misuse: Nano-services, shared databases, synchronous chains, and coordinated deployments.

## Event-Driven Architecture

- Intent: Decouple producers and consumers through events.
- Use when: Multiple consumers react to business facts, workflows are asynchronous, or availability matters.
- Avoid when: Immediate consistency and simple request-response semantics are required.
- Misuse: Using events as hidden remote procedure calls.

## Serverless Backend

- Intent: Run backend units on managed compute with automatic scaling and usage-based billing.
- Use when: Workloads are spiky, operational overhead must be low, and cloud vendor constraints are acceptable.
- Avoid when: Low latency, long-running processes, custom networking, or predictable heavy traffic make serverless inefficient.
- Misuse: Large distributed workflows across many functions with weak observability.

## Monolith vs Microservices Decision Matrix

| Variable | Monolith | Modular Monolith | Microservices |
|---|---|---|---|
| Team Size | 1-10 developers | 10-50 developers | 50+ developers |
| Domain Complexity | Low | Medium to high | High |
| Deployment | Weekly/monthly | Daily possible | Many times per day |
| Scaling | Uniform | Mostly uniform with selective extraction | Heterogeneous |
| Transactions | Local ACID | Local ACID inside modules | Distributed consistency |
| Ops Budget | Low | Medium | High |
| DevOps Maturity | Basic | Intermediate CI/CD | Advanced tracing, orchestration, SRE |

## Architecture Scoring

Rate each from 0 to 10: independent scaling need, independent release need, domain boundary clarity, team autonomy need.

| Score | Recommendation |
|---|---|
| 0-15 | Monolith |
| 15-30 | Modular monolith |
| 30-40 | Selective microservices |
| 40+ | Microservices only if operations maturity exists |

## Strangler Pattern

- Introduce an API gateway or routing layer.
- Identify a low-risk, high-value module with clear boundaries.
- Build the replacement beside the legacy implementation.
- Use API versioning, feature flags, or canary routing.
- Gradually switch traffic while monitoring behavior.
- Decommission legacy code only after stability is proven.

---

# API Design

## Concise Explanation

API design is contract design. A good backend API is explicit about resources, commands, validation, authorization, errors, idempotency, versioning, and compatibility.

## Protocol Comparison

| Protocol | Best Use | Strength | Risk |
|---|---|---|---|
| REST | Public APIs, resource-oriented services, broad compatibility. | Mature, cacheable, simple tooling. | Over-fetching, inconsistent conventions. |
| gRPC | Internal service-to-service communication. | Fast binary protocol, strong contracts, HTTP/2. | Poor native browser fit without gRPC-Web; operational complexity. |
| GraphQL | Backend-for-frontend and client-specific data composition. | Flexible reads, avoids over-fetching. | N+1 queries, authorization complexity, schema sprawl. |
| WebSockets | Real-time bidirectional communication. | Low-latency updates. | Stateful connections, scaling and backpressure complexity. |

## REST Rules of Thumb

- Use nouns for resources and HTTP methods for actions when resource semantics fit.
- Use commands for business actions that do not map cleanly to CRUD, such as `POST /orders/{id}/submit`.
- Validate request bodies, params, and query strings at the API boundary.
- Return consistent error shapes with stable machine-readable codes.
- Use idempotency keys for retryable command endpoints that create or charge resources.
- Version APIs when changing contracts incompatibly.
- Do not expose database schema as API design.

## TypeScript Boundary Validation Example

```ts
import { z } from "zod";

const createUserRequestSchema = z.object({
  email: z.string().email(),
  password: z.string().min(12),
});

const request = createUserRequestSchema.parse(req.body);
await createUserUseCase.execute(request);
```

## Common API Mistakes

- No authorization checks per use case.
- Validation only in frontend code.
- Returning raw stack traces or database errors.
- Breaking clients without versioning or compatibility strategy.
- GraphQL without query complexity limits and DataLoader-style batching.
- gRPC exposed publicly without considering client support.
- WebSockets used for polling-shaped workloads.

---

# Persistence and Database Modeling

## Concise Explanation

Persistence is where business truth meets physical constraints. Good database modeling balances integrity, query performance, operational complexity, and future change.

## SQL vs NoSQL

| Dimension | Relational SQL | NoSQL |
|---|---|---|
| Schema | Explicit and enforced. | Flexible or model-specific. |
| Consistency | Strong ACID support. | Often eventual or per-document atomicity. |
| Querying | Rich SQL, joins, constraints. | Specialized query models. |
| Scaling | Often vertical plus read replicas and partitioning. | Often horizontal by design. |
| Best Use | Core business data, transactions, reporting integrity. | Caching, document models, high-scale key-value, graph traversal, time series. |

## Workload Mapping

- PostgreSQL: default choice for transactional business systems.
- Redis: cache, rate limiting, ephemeral locks, sessions, queues when durability requirements fit.
- MongoDB/document store: document-shaped aggregates with flexible schema and limited cross-document transactions.
- Cassandra/Dynamo-style stores: high write scale, high availability, predictable access patterns.
- Neo4j/graph database: relationship-heavy queries such as fraud networks and recommendations.
- Object storage: large immutable blobs such as files, exports, images, backups.

## Modeling Rules of Thumb

- Start with relational data for core business systems unless a workload clearly demands otherwise.
- Normalize for integrity; denormalize for read performance only with ownership and synchronization rules.
- Add indexes based on query patterns and `EXPLAIN ANALYZE`, not speculation.
- Treat migrations as production code.
- Avoid sharing tables across bounded contexts or services.
- Keep ORM convenience from hiding N+1 queries and transaction boundaries.
- Prefer explicit query functions for complex reads over deeply nested ORM magic.

## ORM Trade-Offs

| Tooling Style | Strength | Risk |
|---|---|---|
| Prisma | Strong TypeScript ergonomics, schema workflow. | Can hide SQL shape; complex domain mapping may need care. |
| TypeORM | Familiar repository/entity style. | Decorator-heavy models can blur domain and persistence. |
| Drizzle | SQL-like TypeScript control. | Less abstraction; more explicit query work. |
| Raw SQL | Maximum control and transparency. | More boilerplate and manual mapping. |

## Common Persistence Mistakes

- Treating ORM entities as domain entities when responsibilities differ.
- No database constraints because validation exists in application code.
- Missing indexes on high-volume filtering, joining, or ordering columns.
- Loading full object graphs for simple list endpoints.
- Using transactions around remote API calls.
- No migration rollback or forward-fix strategy.
- Storing sensitive data without encryption or retention policy.

---

# Transaction Management and Consistency

## Concise Explanation

Transactions define what must be correct together. In a monolith, ACID transactions are often simple and valuable. In distributed systems, strong consistency across services is expensive and often replaced by sagas, idempotency, retries, and compensating actions.

## ACID

- Atomicity: all changes commit or none do.
- Consistency: database constraints and invariants hold.
- Isolation: concurrent transactions do not corrupt each other.
- Durability: committed data survives failure.

## BASE and Eventual Consistency

- Basically available: system prioritizes availability.
- Soft state: state may change asynchronously.
- Eventual consistency: replicas or services converge later.

## Rules of Thumb

- Keep transactions short.
- Do not perform slow network calls inside database transactions.
- Define transaction boundary in the application layer, not inside controllers.
- Use optimistic concurrency for user-edited records and aggregate versioning.
- Make retryable commands idempotent.
- Use an outbox when publishing events must be atomic with database changes.
- Use sagas for long-running distributed business workflows.
- Avoid 2PC unless strong consistency is non-negotiable and operational constraints are understood.

## 2PC vs Saga

| Pattern | Strength | Weakness | Use When |
|---|---|---|---|
| Two-Phase Commit | Strong atomicity across participants. | Blocking, coordinator failure risk, operational coupling. | Rare cases requiring strict distributed atomicity. |
| Saga | High availability, local transactions. | Temporary inconsistency, compensating logic complexity. | Distributed workflows where availability matters. |

## Saga Styles

- Orchestration: central coordinator controls steps. Better visibility and debugging, but coordinator must be highly available.
- Choreography: services react to events. Better decoupling, but flow is harder to understand and trace.

## Compensating Transaction Example

```text
1. Debit savings account by 100.
2. Credit trading account by 100 fails.
3. Credit savings account by 100 as compensation.
```

The system moves forward to a correct state. It does not physically roll back history.

---

# Testing Strategy

## Concise Explanation

Backend tests should prove behavior at the cheapest useful level. Most systems need fast unit tests for domain logic, integration tests for persistence and API boundaries, and contract tests when external consumers or providers are involved.

## Test Types

| Test Type | Purpose | Backend Use |
|---|---|---|
| Unit | Verify isolated logic. | Domain entities, value objects, policies. |
| Application | Verify use case orchestration with fakes. | `CreateOrderUseCase`. |
| Integration | Verify real adapters. | Repository against PostgreSQL test DB. |
| API | Verify request/response behavior. | Route validation, auth, status codes. |
| Contract | Verify provider/consumer compatibility. | Service-to-service APIs. |
| End-to-End | Verify full critical flow. | Registration, checkout, payment callback. |
| Load/Performance | Verify behavior under expected traffic. | Hot endpoints, queue consumers. |
| Security | Verify access control and abuse cases. | Authorization matrix, rate limits. |

## Rules of Thumb

- Test business rules at the domain level when possible.
- Test one happy path and meaningful failure paths for use cases.
- Use real database integration tests for complex SQL, migrations, and transaction behavior.
- Mock external providers at the boundary, not internal domain behavior.
- Avoid snapshot testing backend responses that should be explicit contracts.
- Keep fixtures small and intention-revealing.
- Add regression tests for bugs.

## Common Mistakes

- Testing implementation details instead of behavior.
- Mocking the ORM so repository tests prove nothing.
- Only testing controllers while domain rules remain untested.
- No tests for authorization failures.
- No tests for idempotency or retry behavior in payment/order flows.
- Slow test suites caused by every test booting the full app unnecessarily.

---

# Refactoring and Maintainability

## Concise Explanation

Refactoring is changing internal structure without changing external behavior. It is not cleanup for its own sake. In backend systems, refactoring should reduce change cost, isolate risk, or make correctness easier to prove.

## Refactoring Rules

- Establish a safety net before significant refactoring.
- Refactor in small steps with validation between steps.
- Separate behavior changes from structural changes when possible.
- Prefer extracting concepts that already exist in the business language.
- Do not refactor unrelated code inside a scoped task unless necessary.

## Useful Refactorings

- Extract function for named intent.
- Extract class or module for cohesive responsibility.
- Move method when behavior envies another object.
- Replace primitive with value object.
- Replace conditional with polymorphism or strategy when variation is stable.
- Introduce parameter object for long argument lists.
- Introduce repository or adapter at an infrastructure boundary.
- Split application service when use cases diverge.

## Maintainability Checks

- Can the use case be understood without reading the HTTP framework code?
- Can a business rule be found where the domain concept lives?
- Can infrastructure be replaced in tests?
- Can validation errors be changed without rewriting domain logic?
- Does a new rule require shotgun surgery?
- Does the module have a clear owner and boundary?

---

# Scalability, Performance, and Observability

## Concise Explanation

Performance issues are usually visibility problems before they are infrastructure problems. Backend latency often comes from inefficient SQL, N+1 queries, blocking event-loop work, excessive network calls, oversized payloads, and missing caches.

## Investigation Checklist

- Break down request lifecycle time: API, application, database, external calls, serialization.
- Run `EXPLAIN ANALYZE` for slow SQL queries.
- Check indexes for filters, joins, sorts, uniqueness, and foreign keys.
- Search for synchronous Node.js calls on request paths, such as `readFileSync`, CPU-heavy loops, and blocking crypto/compression work.
- Identify N+1 query patterns in ORM or GraphQL resolvers.
- Measure third-party API latency and timeout behavior.
- Check connection pool saturation.
- Inspect payload size and serialization cost.
- Use tracing to identify chatty service calls.

## Remediation Rules

- Fix query shape and indexes before scaling hardware.
- Use pagination for unbounded lists.
- Cache only when data freshness rules are clear.
- Use Redis or distributed cache for shared cache needs; use local cache only for process-local safe data.
- Move CPU-heavy work to worker threads, background jobs, or specialized services.
- Use queues for slow asynchronous workflows.
- Add rate limiting and backpressure before overload becomes an outage.
- Use structured logs, metrics, and traces for production diagnosis.

## Node.js Specific Rules

- Never block the event loop on a request path with synchronous file I/O, CPU-heavy loops, or unbounded JSON parsing.
- Prefer async I/O and bounded concurrency.
- Validate maximum request sizes.
- Monitor event loop lag.
- Use worker threads or jobs for image processing, reports, encryption-heavy work, and large imports.

## Observability Signals

- Logs: structured facts about important events and errors.
- Metrics: counters, gauges, histograms for rates and latency.
- Traces: request flow across modules and services.
- Alerts: symptoms users care about, not only CPU usage.

## Common Performance Anti-Patterns

- Adding more servers while the bottleneck is one unindexed query.
- Caching incorrect or unauthorized data.
- Infinite or unbounded list endpoints.
- Synchronous inter-service chains for a single request.
- GraphQL resolvers without batching and complexity limits.
- Queue consumers without idempotency.

---

# Security Fundamentals

## Concise Explanation

Backend security is the discipline of assuming clients are hostile, dependencies can fail, and logs live longer than expected. Security must be designed into input handling, authentication, authorization, persistence, secrets, observability, and deployment.

## Rules of Thumb

- Validate all external input at boundaries.
- Authenticate identity and authorize every protected use case.
- Enforce authorization in backend code even if frontend hides UI controls.
- Use least privilege for database users, cloud roles, and service credentials.
- Store secrets in secret managers or environment configuration, never in source code.
- Hash passwords with strong adaptive algorithms such as Argon2id or bcrypt, never plain hashes.
- Use parameterized queries or ORM-safe query APIs to prevent SQL injection.
- Set secure HTTP headers and CORS rules deliberately.
- Avoid logging tokens, passwords, API keys, session IDs, or sensitive PII.
- Rate limit authentication and expensive endpoints.
- Verify webhooks with signatures and replay protection.
- Encrypt sensitive data when required by business, law, or threat model.

## Common Security Mistakes

- Treating authentication as authorization.
- Trusting user IDs from request bodies instead of auth context.
- Missing object-level authorization, such as users accessing another user's resource by ID.
- Overly broad admin endpoints.
- Returning detailed internal errors to clients.
- No dependency vulnerability management.
- No audit trail for sensitive operations.

---

# Design Patterns

Design patterns are blueprints, not mandatory architecture. Use them when the problem they solve exists. Avoid naming a pattern as justification for complexity.

## Creational Patterns

| Pattern | Intent | Problem It Solves | When to Use | When to Avoid | Backend Example | Related Patterns | Common Misuse |
|---|---|---|---|---|---|---|---|
| Factory Method | Defer object creation to a factory function or subclass. | Callers should not know concrete creation rules. | Creating providers, domain entities with validation, test doubles. | Simple constructors are enough. | `PaymentProviderFactory.create(config.provider)`. | Abstract Factory, Strategy. | Factory that just calls `new` with no added value. |
| Abstract Factory | Create families of related objects. | Multiple related implementations must vary together. | Cloud provider adapters for storage, queues, and signing. | Only one product varies. | `AwsInfrastructureFactory` vs `GcpInfrastructureFactory`. | Factory Method, Adapter. | Hiding configuration complexity behind unclear factories. |
| Builder | Construct complex objects step by step. | Constructors have many optional or ordered parameters. | Test data builders, complex query builders. | Required fields are simple and few. | `OrderTestBuilder.withPaidStatus().build()`. | Factory, Fluent Interface. | Using builder for every DTO. |
| Prototype | Clone existing configured objects. | New object should copy an existing baseline. | Rare in backend; cloning immutable config templates. | Shared mutable state could leak. | Clone notification template and override locale. | Factory. | Shallow cloning objects with nested mutable fields. |
| Singleton | Ensure one instance. | Shared process-local resource management. | Logger, metrics registry, configuration in controlled cases. | Request-scoped data, stateful services, tests needing isolation. | One `TelemetryRegistry` per process. | Dependency Injection. | Global mutable state that makes tests flaky. |

## Structural Patterns

| Pattern | Intent | Problem It Solves | When to Use | When to Avoid | Backend Example | Related Patterns | Common Misuse |
|---|---|---|---|---|---|---|---|
| Adapter | Convert one interface to another. | External API or legacy model does not match internal contract. | Payment gateways, legacy ERP, third-party APIs. | You control both sides and can align contracts. | `StripePaymentGateway` implements `PaymentGateway`. | Anti-Corruption Layer, Facade. | Leaking external provider types through the adapter. |
| Facade | Provide a simpler interface over complex subsystem. | Callers should not coordinate many low-level operations. | Simplify reporting, search, or legacy integration. | It becomes a god service. | `CustomerProfileFacade` reads identity, billing, and preferences for a read-only view. | Adapter, Mediator. | Hiding important failure modes. |
| Proxy | Control access to another object. | Need lazy loading, caching, authorization, or remote access control. | Cached repository, rate-limited API client. | Adds invisible behavior that surprises callers. | `CachedProductCatalog` wraps `ProductCatalog`. | Decorator. | Proxy changes semantics or hides stale data risks. |
| Decorator | Add behavior without changing original object. | Cross-cutting behavior must wrap a service. | Logging, metrics, retries, authorization wrappers. | Simple direct implementation is clearer. | `InstrumentedEmailSender` wraps `EmailSender`. | Proxy, Chain of Responsibility. | Many decorators make execution order unclear. |
| Composite | Treat individual and group objects uniformly. | Tree structures need common operations. | Permission trees, menu structures, organizational hierarchy. | Data is not hierarchical. | `PermissionGroup` contains permissions and groups. | Iterator. | Forcing non-tree business data into a tree. |
| Bridge | Separate abstraction from implementation. | Both abstraction and implementation vary independently. | Notification abstraction over email/SMS/push providers. | One axis varies only. | `Notification` policies separated from delivery channels. | Strategy, Adapter. | Creating two hierarchies without real variation. |

## Behavioral Patterns

| Pattern | Intent | Problem It Solves | When to Use | When to Avoid | Backend Example | Related Patterns | Common Misuse |
|---|---|---|---|---|---|---|---|
| Strategy | Swap algorithms behind a common contract. | Variation in policy or algorithm. | Tax rules, pricing, fraud scoring, shipping rates. | Only one algorithm exists. | `TaxStrategy` per country. | Factory, Bridge. | Strategies that still share giant conditionals. |
| Command | Encapsulate an action as an object. | Need validation, queuing, retries, audit, or undo. | Use cases, background jobs, admin actions. | Direct function call is enough. | `ChargePaymentCommand`. | Saga, CQRS. | Command objects with no behavior or metadata. |
| Observer | Notify dependents when something happens. | Decouple event producer from consumers. | Domain events, internal event bus. | Need immediate transactional consistency across all consumers. | `UserRegistered` triggers welcome email and analytics. | Pub/Sub, Event-Driven Architecture. | Events used as hidden synchronous calls. |
| State | Change behavior based on internal state. | State transitions have rules and behavior. | Order lifecycle, subscription status, dispute workflow. | Simple status checks are enough. | `SubscriptionState.cancel()`. | Strategy. | Overbuilding class per state for trivial flows. |
| Template Method | Define skeleton algorithm with overridable steps. | Similar workflows differ in a few steps. | Import pipeline with source-specific parsing. | Composition would be clearer. | Base CSV import flow with custom validation step. | Strategy. | Inheritance hierarchy becomes rigid. |
| Iterator | Traverse collection without exposing internals. | Collection structure should stay hidden. | Paginated result streams, cursor iteration. | Simple arrays are enough. | Async iterator over paginated API results. | Composite. | Loading all pages into memory. |
| Chain of Responsibility | Pass request through handlers until handled. | Multiple handlers may process or reject a request. | Middleware, validation pipeline, auth checks. | Order-dependent chain becomes hard to reason about. | Fastify/Express middleware, command validators. | Decorator, Pipeline. | Swallowing errors or making handler order implicit. |
| Mediator | Centralize communication between collaborators. | Many components communicate directly. | Complex workflow coordination. | It becomes a god object. | Saga orchestrator coordinating shipment and payment. | Facade, Observer. | Mediator owns all business logic. |
| Specification | Encapsulate business predicates. | Reusable, composable rules. | Eligibility, discounts, access policies. | One-off condition is clearer inline. | `CanRenewSubscriptionSpecification`. | Strategy, Policy. | Abstracting every `if` statement. |

## Architectural Patterns

| Pattern | Intent | Problem It Solves | When to Use | When to Avoid | Backend Example | Related Patterns | Common Misuse |
|---|---|---|---|---|---|---|---|
| Layered Architecture | Separate technical responsibilities. | Mixed HTTP, business, and data code. | Most backend apps. | Tiny scripts. | API, Application, Domain, Infrastructure. | Clean Architecture. | Layers with no dependency discipline. |
| Clean Architecture | Protect use cases and domain from frameworks. | Framework and persistence coupling. | Long-lived business systems. | Simple CRUD would become ceremony. | Use cases depend on repository interfaces. | Hexagonal, Onion. | Domain imports ORM models. |
| Hexagonal Architecture | Isolate core through ports and adapters. | Multiple external adapters and testability. | Apps with replaceable external systems. | One stable adapter and low complexity. | `PaymentGateway` port with Stripe adapter. | Adapter, Clean Architecture. | Port for every class. |
| Modular Monolith | Strict modules in one deployable. | Need boundaries without distributed ops. | Growing teams and domains. | Hard independent scaling requirements. | `Billing`, `Identity`, `Orders` modules in one Node app. | Bounded Context. | Shared internal tables and cross-module imports. |
| Microservices | Independent deployable services. | Independent team autonomy, scaling, release cadence. | Mature teams with clear bounded contexts. | Small teams, unstable domains. | Separate `Billing` and `Catalog` services. | Saga, API Gateway. | Distributed monolith. |
| Event-Driven Architecture | Producers publish facts, consumers react. | Decoupled asynchronous workflows. | Multiple consumers, eventual consistency. | Immediate response required. | `OrderSubmitted` consumed by fulfillment and email. | Observer, Outbox. | Events as synchronous RPC. |
| Backend for Frontend | Tailor backend API to client needs. | Different clients need different shapes. | Web and mobile have divergent needs. | One generic API is sufficient. | `web-bff` aggregates dashboard data. | GraphQL, Facade. | Duplicating business logic per frontend. |
| CQRS | Separate command and query models. | Reads and writes have different needs. | Complex read models or high read scale. | Simple CRUD. | Order writes enforce invariants; dashboard reads denormalized view. | Event Sourcing. | CQRS everywhere. |
| Event Sourcing | Store state as event sequence. | Need complete history and temporal reconstruction. | Ledgers, audit-heavy workflows. | Current state is enough. | Account balance derived from debit/credit events. | CQRS, Saga. | Using events without versioning/replay strategy. |

## Enterprise Integration Patterns

| Pattern | Intent | Problem It Solves | When to Use | When to Avoid | Backend Example | Related Patterns | Common Misuse |
|---|---|---|---|---|---|---|---|
| Message Channel | Move messages between systems. | Producers and consumers need decoupling. | Async workflows and integrations. | Simple synchronous response needed. | Queue for email jobs. | Pub/Sub, Queue. | No dead-letter handling. |
| Message Translator | Convert message formats. | Systems use different schemas. | Legacy integrations, partner APIs. | Same model can be shared safely. | Map ERP customer to internal billing customer. | Adapter, ACL. | Leaking source schema after translation. |
| Content-Based Router | Route by message content. | Different handlers for different message types. | Event routing and workflow branching. | Routing rules are trivial. | Route payment events by provider and status. | Mediator. | Hidden routing rules that no one owns. |
| Aggregator | Combine related messages into one result. | Data arrives in pieces. | Reports, batch imports, BI feeds. | Real-time single request is enough. | Aggregate shipment status updates. | Splitter. | Waiting forever for missing messages. |
| Splitter | Split one message into many. | Large message contains independent work items. | Bulk imports and batch processing. | Items must be transactional together. | Split CSV import into per-row jobs. | Aggregator. | Losing correlation IDs. |
| Idempotent Receiver | Safely process duplicate messages. | Retries can deliver duplicates. | Queues, webhooks, payment events. | Source guarantees exactly-once and business can tolerate duplicates. | Payment webhook deduped by event ID. | Outbox, Inbox. | Assuming queue delivery is exactly once. |
| Transactional Outbox | Persist event with business data atomically. | Database update and message publish must not diverge. | Domain events, integration events. | No async publishing needed. | Save order and `OrderSubmitted` outbox row in same transaction. | Inbox, Saga. | Publishing directly inside transaction without retry plan. |
| Saga | Coordinate distributed transaction through local transactions. | No global ACID across services. | Long-running distributed workflows. | Single database transaction is available. | Order payment, inventory reservation, shipment. | Command, Event-Driven. | Missing compensation and idempotency. |
| Circuit Breaker | Stop calling failing dependency temporarily. | Repeated failures exhaust resources. | External APIs and fragile dependencies. | Failure is rare and cheap. | Pause calls to shipping provider after error threshold. | Retry, Timeout. | Circuit breaker without fallback or alerting. |
| Retry with Backoff | Retry transient failures safely. | Networks and dependencies fail temporarily. | Idempotent operations. | Non-idempotent commands without dedupe. | Retry object storage upload. | Circuit Breaker. | Infinite retries causing overload. |
| Data Migration | Move data once from old to new system. | Legacy decommissioning or cloud migration. | One-time migration with verification. | Ongoing sync is required. | Move users from legacy DB to PostgreSQL. | Strangler. | No reconciliation or rollback plan. |
| Data Synchronization | Keep systems aligned over time. | Multiple systems need shared facts. | Transitional migrations, reporting replicas. | No real consumer need. | Sync customer status to CRM. | Outbox, CDC. | Syncing everything and creating data bloat. |
| Broadcasting | Send one event to many consumers. | Many systems react to same fact. | Price changes, user lifecycle events. | Consumers need command response. | Broadcast `ProductPriceChanged`. | Pub/Sub. | Consumers treat broadcast as required synchronous workflow. |

---

# Common Backend Anti-Patterns

| Anti-Pattern | Detection | Why It Hurts | Preferred Response |
|---|---|---|---|
| Big Ball of Mud | No clear boundaries, everything imports everything. | Changes are risky and slow. | Introduce modules and dependency rules. |
| Distributed Monolith | Services deploy together and fail together. | Distributed cost without autonomy. | Right-size boundaries, version APIs, remove shared DB. |
| Shared Database Between Services | Multiple services write same schema. | Coupling and ownership conflicts. | Database per service or modular ownership with APIs/events. |
| Chatty Microservices | One request triggers many synchronous calls. | Latency and cascading failure. | Redesign boundaries, cache, aggregate read models. |
| Anemic Domain | Entities are data bags; services hold all rules. | Logic duplication and weak invariants. | Move behavior into domain where complexity exists. |
| God Service | One service handles many workflows. | Hard to test, change, and reason about. | Split use cases and domain policies. |
| Repository as Query Dump | Repository contains unrelated queries for every screen. | No ownership or model clarity. | Separate aggregate repositories from read models. |
| Premature Abstraction | Interfaces and factories before variation exists. | Slower change and harder navigation. | Use concrete code until stable variation appears. |
| Over-Generic Error Handling | Everything becomes `500` or generic `Error`. | Clients cannot react; debugging is poor. | Classify validation, conflict, auth, not found, infrastructure. |
| Missing Observability | Cannot trace failures or latency. | Production issues become guesses. | Structured logs, metrics, traces, correlation IDs. |
| No Idempotency | Retries duplicate payments or orders. | Data corruption and user harm. | Idempotency keys, dedupe tables, transaction rules. |

---

# Practical Trade-Off Frameworks

## DDD or CRUD

- Choose CRUD when rules are simple, data shape dominates, and speed matters.
- Choose DDD when invariants, workflows, language, and lifecycle dominate.
- Use a mixed approach when some modules are simple CRUD and others are behavior-rich.

## REST or GraphQL or gRPC

- Choose REST for public APIs and broad compatibility.
- Choose gRPC for internal low-latency service calls with strong contracts.
- Choose GraphQL for frontend-specific composition when clients truly need flexible reads.
- Choose WebSockets only for real-time bidirectional needs.

## SQL or NoSQL

- Choose PostgreSQL or another relational database by default for core business records.
- Choose NoSQL for workload-specific needs such as massive key-value scale, document shape, graph traversal, or time-series ingestion.
- Do not choose NoSQL only to avoid schema design.

## Monolith or Microservices

- Choose monolith for small teams and low complexity.
- Choose modular monolith for growing systems that need boundaries without distributed operations.
- Choose microservices only when independent deployment, scaling, team ownership, and operational maturity justify the cost.

## Queue or Synchronous Call

- Use synchronous calls when the caller needs an immediate answer.
- Use queues when work is slow, retryable, asynchronous, or decoupled from user response.
- Do not use queues to hide unclear ownership or avoid modeling a transaction boundary.

---

# How Concepts Relate

- OOP provides encapsulation mechanics for domain modeling.
- SOLID provides changeability pressure tests for OOP and modular design.
- Clean Code keeps local implementation readable enough to modify safely.
- Clean Architecture controls dependency direction across layers.
- DDD provides modeling tools for complex business behavior within those layers.
- Design patterns provide reusable structures for recurring object, module, and integration problems.
- API design exposes application use cases as stable contracts.
- Persistence stores state while respecting domain and consistency boundaries.
- Transaction management defines what must be correct together.
- Testing proves behavior and protects refactoring.
- Observability makes production behavior measurable.
- Security constrains every boundary, data flow, and operational practice.
- Architecture selection determines operational cost, deployment independence, and data consistency strategy.

---

# Prioritized Learning Path

## Junior Backend Developer

- TypeScript fundamentals: types, narrowing, async/await, modules, errors.
- HTTP basics: methods, status codes, headers, request/response lifecycle.
- Basic API validation and error handling.
- SQL fundamentals: tables, joins, indexes, transactions.
- Unit and integration testing basics.
- Clean Code: naming, function size, duplication, guard clauses.
- Basic security: password hashing, auth vs authorization, SQL injection.

## Mid-Level Backend Developer

- Layered architecture and dependency direction.
- Application services and use case design.
- Repository pattern and persistence trade-offs.
- Transaction boundaries and isolation issues.
- DDD tactical patterns: entities, value objects, aggregates, repositories.
- API versioning, idempotency, pagination, rate limiting.
- Integration testing with real databases and external service fakes.
- Observability fundamentals: logs, metrics, traces.
- Performance diagnosis with SQL plans and event-loop awareness.

## Senior Backend Developer

- Bounded contexts and context mapping.
- Modular monolith design and module boundary enforcement.
- Microservice trade-offs, sagas, outbox/inbox, contract testing.
- Advanced data modeling, denormalized read models, caching strategy.
- Security threat modeling and operational controls.
- Refactoring legacy systems with strangler pattern.
- Designing for failure: timeouts, retries, circuit breakers, backpressure.
- Architecture governance and technical debt management.

## Staff or Architect Level

- Organization-aware architecture and Conway's Law.
- Platform strategy, deployment topology, reliability targets.
- Cross-team API and data ownership governance.
- Cost modeling and operational maturity assessment.
- Evolutionary architecture and fitness functions.
- Incident analysis and systemic risk reduction.

---

# Backend Agent Design and Review Checklist

## Before Designing

- Confirm task scope and acceptance criteria.
- Identify whether the task is CRUD, behavior-rich domain logic, integration work, performance work, or infrastructure work.
- Confirm existing architecture, framework, package manager, and validation commands.
- Identify affected layers and boundaries.
- Ask clarifying questions if business rules, data ownership, consistency, or security requirements are ambiguous.

## During Design

- Keep API validation at the boundary.
- Keep use case orchestration in the application layer.
- Keep business invariants in domain code when the domain is behavior-rich.
- Keep persistence and external providers in infrastructure adapters.
- Define transaction boundaries explicitly.
- Consider idempotency for commands that can be retried.
- Consider authorization at the use-case and resource level.
- Choose the simplest architecture that supports the required change.

## During Implementation

- Modify only task-scoped files.
- Avoid unrelated refactors.
- Use TypeScript types to make illegal states harder to represent.
- Validate runtime input with an explicit schema or framework validation mechanism.
- Map external DTOs to internal models intentionally.
- Handle errors deliberately and consistently.
- Add or update tests for behavior changes.
- Avoid synchronous or CPU-heavy work on request paths.

## During Review

- Verify dependency direction.
- Verify controllers do not contain business rules.
- Verify domain does not import framework, ORM, or infrastructure code.
- Verify repositories do not hide business rules.
- Verify validation, authorization, and error behavior.
- Verify tests cover meaningful success and failure paths.
- Verify performance-sensitive code has query and event-loop considerations.
- Verify secrets and sensitive data are not logged or committed.
- Verify validation commands were run and results are reported.

---

# Questions Before Proposing Implementation

- What business outcome should this change support?
- What are the acceptance criteria and non-goals?
- Which API clients or internal consumers are affected?
- Is this simple CRUD or behavior-rich domain logic?
- What business invariants must always hold?
- What data must be consistent in one transaction?
- Can this operation be retried safely? Does it need an idempotency key?
- What authorization rules apply at resource and action level?
- What validation rules apply to input, state transitions, and persistence?
- What is the expected read/write volume and latency target?
- Are there existing modules, patterns, or conventions to follow?
- Which persistence technology is already approved?
- Are migrations, indexes, or backfills required?
- Are external systems involved? What are their timeout and failure behaviors?
- Does the change require synchronous response or can it be asynchronous?
- What tests are needed to prove behavior and prevent regression?
- What validation commands are available in this repository?
- What operational signals should be logged, measured, or traced?
- Are there security, privacy, compliance, or audit requirements?
- Is any proposed complexity justified by current requirements rather than speculation?

---

# Glossary

| Term | Meaning |
|---|---|
| ACID | Atomicity, Consistency, Isolation, Durability for reliable database transactions. |
| Adapter | Code that converts one interface or model into another. |
| Aggregate | DDD consistency boundary around entities and value objects. |
| Aggregate Root | Entry point used to modify an aggregate. |
| Anemic Domain Model | Data-only domain objects with business logic elsewhere. |
| Anti-Corruption Layer | Translation layer that protects one model from another. |
| API Gateway | Entry point that routes, secures, and manages API traffic. |
| BASE | Basically Available, Soft state, Eventual consistency. |
| Bounded Context | Boundary where a domain model and language are consistent. |
| CQRS | Command Query Responsibility Segregation; separate write and read models. |
| Circuit Breaker | Pattern that stops calls to failing dependencies temporarily. |
| Cohesion | Degree to which code in a module belongs together. |
| Command | Intent to perform an action, often modeled as a use case or message. |
| Compensating Transaction | Action that semantically undoes a prior transaction step in a saga. |
| Contract Test | Test that verifies compatibility between provider and consumer. |
| Coupling | Degree of dependency between modules. |
| DTO | Data Transfer Object used at boundaries. |
| Domain Event | Business-significant fact that already happened. |
| Entity | Object with identity and lifecycle. |
| Event Sourcing | Persisting changes as events rather than only current state. |
| Idempotency | Same operation can be repeated without duplicate side effects. |
| Infrastructure | Layer implementing persistence, messaging, external APIs, and technical adapters. |
| Invariant | Business rule that must always hold. |
| N+1 Query | One query to fetch a list followed by N queries for each item. |
| Outbox | Table or store of messages saved atomically with business data for reliable publishing. |
| Repository | Abstraction for loading and saving aggregates or data models. |
| Saga | Distributed transaction pattern using local transactions and compensation. |
| Strangler Pattern | Gradual replacement of legacy functionality behind routing. |
| Transaction Boundary | Scope of data changes committed atomically. |
| Ubiquitous Language | Shared business language used in code and conversation. |
| Value Object | Immutable object identified by its value. |

---

# Trusted Foundations

## Books

- Eric Evans, `Domain-Driven Design: Tackling Complexity in the Heart of Software`.
- Vaughn Vernon, `Implementing Domain-Driven Design`.
- Vaughn Vernon, `Domain-Driven Design Distilled`.
- Robert C. Martin, `Clean Architecture`.
- Robert C. Martin, `Clean Code`.
- Martin Fowler, `Patterns of Enterprise Application Architecture`.
- Martin Fowler, `Refactoring`.
- Erich Gamma, Richard Helm, Ralph Johnson, John Vlissides, `Design Patterns`.
- Gregor Hohpe and Bobby Woolf, `Enterprise Integration Patterns`.
- Sam Newman, `Building Microservices`.
- Sam Newman, `Monolith to Microservices`.
- Chris Richardson, `Microservices Patterns`.
- Michael Nygard, `Release It!`.
- Brendan Gregg, `Systems Performance`.
- Ross Anderson, `Security Engineering`.

## Authors and References

- Martin Fowler on monolith-first, refactoring, microservices, and enterprise patterns.
- Eric Evans and Vaughn Vernon on DDD.
- Gregor Hohpe on integration architecture.
- Sam Newman on microservices and migration.
- Chris Richardson on sagas and transactional outbox.
- OWASP API Security Top 10.
- OWASP Application Security Verification Standard.
- Node.js official documentation on event loop, async I/O, streams, and worker threads.
- PostgreSQL documentation on transactions, indexing, and query planning.
- Refactoring.Guru for pattern vocabulary and code smell catalog.

---

# Backend Agent System Knowledge

The Backend Developer Agent must always follow these condensed principles:

- Build the smallest correct backend change that satisfies the task.
- Confirm scope, architecture, package manager, runtime, persistence baseline, and validation commands before implementation.
- Keep HTTP concerns in API, use-case orchestration in Application, business rules in Domain, and technical adapters in Infrastructure.
- Use TypeScript types and runtime validation together. Types do not validate untrusted runtime input.
- Do not place business rules in controllers, ORM hooks, SQL snippets, or infrastructure adapters when a domain model exists.
- Prefer rich domain behavior for complex business invariants and simple CRUD for simple data management.
- Prefer a modular monolith unless independent deployment, scaling, ownership, and operational maturity justify microservices.
- Do not introduce GraphQL, CQRS, event sourcing, queues, sagas, or microservices without clear need.
- Define transaction boundaries explicitly and keep transactions short.
- Use idempotency, retries with backoff, outbox/inbox, and compensating transactions when distributed workflows require them.
- Use PostgreSQL or relational persistence by default for core business data unless workload requirements justify another store.
- Measure performance with evidence: query plans, timings, traces, metrics, event-loop behavior, and load tests.
- Avoid blocking the Node.js event loop on request paths.
- Validate authorization and object ownership on the backend for every protected use case.
- Protect secrets and sensitive data in code, logs, tests, and configuration.
- Add meaningful tests for behavior changes, especially domain rules, transaction behavior, authorization, and failure cases.
- Report exact commands run, results, files changed, decisions, and remaining risks.
- Never claim completion without validation evidence.
