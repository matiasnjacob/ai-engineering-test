# Frontend Developer Agent Guide

# Purpose

This guide is the source of truth for a specialized Frontend Developer Agent working on modern TypeScript, React, and Next.js applications.

The agent must optimize for user experience, accessibility, maintainability, security, measurable performance, and production-safe architecture. It must prefer practical engineering rules over framework enthusiasm and choose complexity only when it solves a real product or operational problem.

Modern frontend work is not only visual implementation. In a Next.js App Router application, the frontend is a server-client orchestration layer that owns rendering strategy, routing, data access boundaries, cache behavior, interaction quality, SEO, accessibility, and secure exposure of data to the browser.

---

# Operating Principles

- Default to Server Components for data fetching, SEO, layout, and non-interactive UI.
- Use Client Components only for interactivity, browser APIs, stateful UI, effects, refs, event handlers, and client-only libraries.
- Push `use client` to the smallest leaf component possible.
- Treat the server-client boundary as a security and serialization boundary.
- Pass only serializable DTOs from Server Components to Client Components.
- Validate all external data at runtime. TypeScript does not validate runtime input.
- Keep route files thin; delegate business UI composition to features, widgets, or route-specific page modules.
- Keep state as local as possible; separate server state from client UI state.
- Prefer native platform capabilities before adding client JavaScript.
- Preserve semantic HTML, keyboard navigation, focus behavior, and accessible error states.
- Optimize Core Web Vitals through measurement, not guesses.
- Do not introduce FSD, global stores, GraphQL, complex design-system abstractions, or custom architecture without concrete need.

---

# Modern Frontend Knowledge Map

| Topic | Core Question | Production Concern |
|---|---|---|
| Next.js | Where should code execute and how should routes render? | App Router, RSC, caching, streaming, SEO, deployment |
| React | How should UI be composed and updated? | Components, state, effects, Suspense, hydration, performance |
| TypeScript | How do we make invalid states harder to ship? | Strictness, unions, inference, API typing, runtime validation |
| JavaScript | What does the runtime actually do? | Async behavior, modules, browser APIs, closures, event loop |
| Frontend Architecture | How should code be organized for change? | FSD, dependency boundaries, module public APIs, ownership |
| Component Design | How do UI pieces stay reusable and understandable? | Composition, props, variants, accessibility, state ownership |
| Design Patterns | Which recurring frontend problem is present? | Rendering, state, forms, errors, composition, performance |
| State Management | Where should state live? | Local state, URL state, server state, forms, global UI state |
| Data Fetching | How does UI get data safely and efficiently? | DAL, caching, revalidation, loading, errors, contracts |
| Forms | How do users submit valid data? | Native forms, RHF, Server Actions, validation, errors |
| Auth | Who is the user and what can they do? | Sessions, cookies, permissions, object ownership, redirects |
| Error Handling | How do failures become useful UX? | Error boundaries, route errors, toasts, retries, fallbacks |
| Testing | How do we prove frontend behavior? | Unit, component, integration, E2E, visual, accessibility |
| Accessibility | Can all users operate the interface? | Semantic HTML, keyboard, focus, screen readers, contrast |
| Performance | How fast and stable is the experience? | CWV, bundle size, hydration, images, fonts, streaming |
| SEO | Can crawlers and link previews understand pages? | Metadata, semantic content, static rendering, structured data |
| Internationalization | Can the product support languages and locales? | Routing, formatting, pluralization, translations, RTL |
| Security | What can untrusted users or scripts exploit? | XSS, CSRF, secrets, CSP, cookies, client/server leakage |
| Design Systems | How does UI scale consistently? | Tokens, variants, primitives, Radix, shadcn/ui, theming |
| Anti-Patterns | Which familiar solution is harmful here? | Everything client-side, global state sprawl, prop drilling |

---

# Next.js App Router Doctrine

## Concise Explanation

The App Router is the default architecture for new Next.js applications. It combines file-system routing, layouts, React Server Components, streaming, route-level error handling, caching, and server-side mutations. The Pages Router remains relevant for legacy projects, but new work should default to App Router unless the repository already uses Pages Router.

## App Router Concepts

| Concept | Practical Meaning | Use Carefully |
|---|---|---|
| App Router | Route tree under `app/` using layouts, pages, loading, error, and not-found files. | Do not turn every route into client-rendered SPA code. |
| Pages Router | Legacy `pages/` routing model. | Use for existing projects; avoid mixing patterns casually. |
| Server Components | Default components rendered on the server with no client hydration. | Cannot use browser APIs, state, or event handlers. |
| Client Components | Components marked with `use client` and hydrated in the browser. | Increase bundle size and hydration work. |
| Layouts | Shared UI that preserves state across route navigation. | Do not put route-specific logic in global layouts. |
| Templates | Similar to layouts but remount on navigation. | Use when remount behavior is required. |
| Route Groups | Parentheses folders for organization without URL path impact. | Avoid hiding confusing route ownership. |
| Dynamic Routes | `[id]`, `[slug]`, and catch-all segments. | Validate params and handle missing resources. |
| Parallel Routes | Multiple route slots rendered simultaneously. | Useful for dashboards; can add mental overhead. |
| Intercepting Routes | Display a route in another context, such as modal detail pages. | Avoid if regular routing is clearer. |
| Loading UI | `loading.tsx` fallback for route segment loading. | Loading skeletons must avoid layout shift. |
| Error UI | `error.tsx` route-level error boundary. | Must provide recovery or useful next action. |
| Not Found UI | `not-found.tsx` for missing resources. | Use `notFound()` intentionally for unavailable data. |
| Middleware | Edge-executed request logic before route handling. | Keep lightweight; avoid full authorization or heavy data calls. |
| Route Handlers | Server endpoints under `app/api` or route files. | Use for external clients, webhooks, BFF endpoints. |
| Server Actions | Server functions invoked by forms or client transitions. | Good for UI mutations; not a public API replacement. |
| Metadata API | Structured page metadata for SEO and sharing. | Generate from server data safely. |
| Image Optimization | `next/image` for responsive, optimized images. | Provide dimensions and prioritize hero images deliberately. |
| Font Optimization | `next/font` for local or Google font optimization. | Avoid layout shift and excessive font variants. |
| Streaming | Progressive rendering through Suspense boundaries. | Boundaries must map to meaningful UX sections. |
| Partial Prerendering | Static shell with dynamic streamed islands where supported. | Version and hosting support matter; do not assume availability. |
| Static Rendering | Render at build time or cache as static output. | Best for stable content. |
| Dynamic Rendering | Render per request when personalization or request data is needed. | More server cost and less CDN benefit. |
| ISR | Incremental Static Regeneration refreshes static content after time or invalidation. | Needs clear freshness expectations. |
| Edge Runtime | Low-latency runtime with limited Node.js APIs. | Great for middleware and lightweight logic; not heavy server work. |
| Node.js Runtime | Full Node.js runtime for route handlers and server logic. | Use for DB access, SDKs, file processing, complex server work. |

## Server-First Rules

- Fetch data in Server Components by default.
- Keep SEO-critical content server-rendered.
- Create small Client Components for interactive islands.
- Use `server-only` in privileged data access modules.
- Do not pass functions, class instances, database records, secrets, or non-serializable values to Client Components.
- Use DTOs to send only the fields the client needs.
- Keep authentication and authorization checks close to data access and mutations.

## Serialization Boundary Example

Bad:

```tsx
// Passing a class instance or DB object to a Client Component risks runtime failure and data leakage.
return <ProfileEditor user={userFromDatabase} />;
```

Better:

```tsx
const userDto = {
  id: user.id,
  displayName: user.displayName,
  email: user.email,
};

return <ProfileEditor user={userDto} />;
```

## Caching and Revalidation

| Layer | Meaning | Rule of Thumb |
|---|---|---|
| Request Memoization | Deduplicates identical fetches during one render pass. | Use to avoid prop drilling through server trees. |
| Data Cache | Persistent server-side fetch cache. | Use tags for domain-aware invalidation. |
| Full Route Cache | Cached rendered static route output. | Use for stable static pages. |
| Router Cache | Browser-side cache for route segments. | Understand stale navigation behavior. |

## Revalidation Rules

- Prefer `revalidateTag` for precise domain invalidation such as `product:123` or `catalog`.
- Use `revalidatePath` when a whole route or layout must refresh.
- Document freshness requirements for each data source.
- Avoid broad invalidation when a narrower tag exists.
- Do not cache personalized or sensitive data unless scope and privacy are explicit.

## Deployment Considerations

- Vercel usually provides the best alignment with cutting-edge Next.js features, edge routing, image optimization, and PPR support.
- Self-hosting provides cost and platform control but increases operational burden around caching, image optimization, serverless behavior, observability, and upgrades.
- Edge runtime is not a general replacement for Node.js runtime.
- Confirm environment variable availability separately for server and browser.
- Validate that middleware, server actions, image domains, and cache invalidation work in the target deployment platform.

## Common Next.js Mistakes

- Adding `use client` to page or layout files by default.
- Fetching all data client-side because it feels familiar from SPA development.
- Storing server data in Zustand or Redux instead of using RSC cache or TanStack Query/SWR where appropriate.
- Using Server Actions as a public API for mobile or third-party consumers.
- Forgetting `loading.tsx`, `error.tsx`, and `not-found.tsx` for production routes.
- Using middleware for heavy database-backed authorization on every request.
- Passing sensitive server objects across the serialization boundary.

---

# React Engineering Rules

## Concise Explanation

React is a composition model for UI. In production, the most important React skill is deciding what owns state, what should render on the server, what should hydrate on the client, and which components should remain dumb, reusable, and accessible.

## Core Concepts

| Concept | Practical Rule |
|---|---|
| Component Composition | Prefer composing small explicit components over large configurable god components. |
| Props | Props are component contracts; keep them minimal and intention-revealing. |
| State | Put state at the lowest owner that needs to change it. |
| Effects | Use effects to synchronize with external systems, not to derive render data. |
| Context | Use for low-frequency cross-tree values like theme, locale, auth shell state. |
| Hooks | Hooks organize reusable stateful behavior, not random utility functions. |
| Custom Hooks | Extract when stateful logic repeats or needs isolation. |
| Controlled Components | Parent owns value; useful for forms needing immediate validation or orchestration. |
| Uncontrolled Components | DOM owns value; useful for simpler forms and file inputs. |
| Error Boundaries | Catch rendering errors and provide recovery UI. |
| Suspense | Coordinate async rendering and progressive loading. |
| Concurrent Rendering | React may interrupt and restart rendering; code must stay pure. |
| Memoization | Use only for proven expensive calculations or stable identity needs. |
| Lifecycle Thinking | Effects replace mount/update/unmount mental models; render must stay pure. |
| Presenter/Container Split | Keep UI rendering separate from data orchestration where it improves clarity. |

## Rules of Thumb

- Components should be pure: same props produce same output.
- Avoid effects for data that can be calculated during render.
- Do not mirror props into state unless the component intentionally forks local editable state.
- Avoid prop drilling by using composition, route-level fetching, request memoization, or context only when justified.
- Do not default to `useMemo` and `useCallback`; use them when identity or computation cost matters.
- Keep Client Components small to reduce bundle and hydration cost.
- Prefer composition slots over boolean prop explosions.

## Avoiding Unnecessary Effects

Bad:

```tsx
const [fullName, setFullName] = useState("");

useEffect(() => {
  setFullName(`${firstName} ${lastName}`);
}, [firstName, lastName]);
```

Better:

```tsx
const fullName = `${firstName} ${lastName}`;
```

## Common React Anti-Patterns

- Derived state stored in `useState` and synchronized with `useEffect`.
- Global state used because props feel inconvenient.
- Context used for frequently changing data causing broad re-renders.
- Mega components mixing data fetching, permissions, layout, forms, and visual primitives.
- Overusing `memo`, `useMemo`, and `useCallback` without measurement.
- Index keys for dynamic lists that can reorder.
- UI libraries used without preserving accessible semantics.

---

# TypeScript and JavaScript Rules

## Concise Explanation

TypeScript should make invalid UI states harder to represent and API assumptions explicit. It is not a replacement for runtime validation. JavaScript runtime behavior still matters: async work, module boundaries, browser APIs, event handlers, and serialization all affect production correctness.

## TypeScript Rules

- Use strict mode.
- Avoid `any`; use `unknown` and narrow.
- Avoid non-null assertions unless a framework invariant is proven and documented.
- Prefer discriminated unions for async and UI states.
- Let inference work for local variables; type public component props, API responses, and exported functions.
- Use `type` for unions, mapped types, and aliases; use `interface` when extension/merging is desirable.
- Use generics for reusable components and helpers only when they preserve real type information.
- Use utility types deliberately: `Pick`, `Omit`, `Partial`, `Required`, `Readonly`, `Record`, `Awaited`, `ReturnType`.
- Validate API responses and form input with schemas such as Zod before trusting data.

## Discriminated Union Example

```ts
type LoadState<T> =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "success"; data: T }
  | { status: "error"; message: string };
```

This prevents impossible states such as `loading: true` and `error` existing at the same time.

## API Response Validation Example

```ts
import { z } from "zod";

const productSchema = z.object({
  id: z.string(),
  name: z.string(),
  priceInCents: z.number().int().nonnegative(),
});

type Product = z.infer<typeof productSchema>;

const response = await fetch("/api/products/123");
const product: Product = productSchema.parse(await response.json());
```

## JavaScript Runtime Rules

- Understand promises, cancellation patterns, race conditions, and abort signals.
- Avoid blocking the main thread with heavy computation.
- Use browser APIs only inside Client Components or effects.
- Be deliberate with module imports; importing a client-only library into a Server Component can break builds or inflate bundles.
- Treat all `process.env.NEXT_PUBLIC_*` values as public.

---

# Frontend Architecture

## Concise Explanation

Frontend architecture is the discipline of making product change safe. Good architecture decides where code belongs, which modules may import which modules, how state ownership works, how APIs are consumed, and where UI primitives stop and business-specific components begin.

## Feature-Sliced Design

FSD organizes code by business relevance and dependency hierarchy. It is valuable for enterprise-scale or long-lived applications, but it can be too heavy for small marketing sites or prototypes.

| Layer | Responsibility | Examples |
|---|---|---|
| App | Application initialization, providers, route runtime, global styles. | `app/layout.tsx`, providers, global CSS. |
| Pages | Route-specific composition. | `HomePage`, `ProductDetailsPage`. |
| Widgets | Complex UI blocks combining entities and features. | Header, sidebar, dashboard grid. |
| Features | User actions and business workflows. | Login, add to cart, search products. |
| Entities | Domain-specific models, queries, and display pieces. | User, product, order. |
| Shared | Business-agnostic primitives and utilities. | Button, input, fetcher, date formatter. |

## FSD Rules

- Higher layers may import lower layers.
- Lower layers must not import higher layers.
- Same-layer cross-slice imports are forbidden unless explicitly allowed by project convention.
- Every slice exposes an explicit public API through `index.ts`.
- Do not deep-import from another slice's internals.
- Route files should remain thin composition boundaries.
- `shared` is not a dumping ground for business logic.

## When to Use FSD

- Use when the app has many routes, multiple teams, domain complexity, and a multi-year lifespan.
- Use when App Router, Server Components, and business-level composition need strict boundaries.
- Avoid strict FSD for short-lived prototypes, landing pages, and small apps where overhead slows delivery.

## Other Structures
| Structure | Use When | Avoid When |
|---|---|---|
| Feature-Based | Product areas change independently. | Shared primitives are duplicated across features. |
| Layer-Based | Small apps benefit from technical grouping. | App grows and feature ownership becomes unclear. |
| Atomic Design | Building a UI component library or design system. | It becomes detached from product use cases. |
| Container/Presenter | Data orchestration and view rendering need separation. | Split creates pointless pass-through components. |
| Smart/Dumb Components | Useful mental model for data vs display. | Dogmatic split fights Server Components. |

## API Client Organization

- Server-only data access belongs in a DAL or entity/feature API layer protected by `server-only`.
- Browser API clients must not include secrets or privileged headers.
- Normalize API errors at the boundary.
- Keep typed contracts close to the integration boundary.
- Use BFF route handlers when browser clients need a safe facade over backend services.

## Environment Configuration

- Server-only secrets must not use `NEXT_PUBLIC_`.
- Validate required environment variables during startup or build where possible.
- Use separate config modules for server and client env access.
- Never expose privileged endpoints, tokens, or credentials to Client Components.

---

# Component Design

## Rules of Thumb

- Design components around user intent and accessibility semantics.
- Separate design-system primitives from domain-specific components.
- Prefer composition over large prop APIs.
- Use slots or children for flexible layout.
- Keep styling variants finite and typed.
- Avoid components that both fetch data and own complex interaction unless locality clearly wins.
- Components or hooks over roughly 300 lines should be reviewed for decomposition, not blindly split.

## Shared vs Domain-Specific Example

```text
shared/ui/Button          -> business-agnostic primitive
entities/product/ProductCard -> product-aware display
features/cart/AddToCartButton -> user action with business behavior
widgets/header/Header     -> composed UI region
```

## Common Component Mistakes

- A shared component imports product, user, or order logic.
- Variant props become an unbounded design language.
- `div` and `span` replace native buttons, links, labels, and inputs.
- Components expose implementation details instead of stable props.
- Presentational components depend on global stores.

---

# Design Patterns

Patterns are reusable decision templates. Use them when the problem exists, not to make code look senior.

## Component Patterns

| Pattern | Intent | Problem It Solves | When to Use | When to Avoid | Next.js Example | React Example | Related Patterns | Common Misuse |
|---|---|---|---|---|---|---|---|---|
| Composition | Build UI by nesting components. | Avoid rigid inheritance and huge components. | Most reusable UI. | When a single explicit component is simpler. | Server page composes `ProductGrid` and `Filters`. | `<Card><CardHeader /></Card>`. | Slots, compound components. | Too many tiny wrappers. |
| Slots | Let caller inject UI regions. | Flexible layout without prop explosion. | Cards, shells, dialogs. | Layout must be tightly controlled. | `DashboardShell` accepts sidebar and content slots. | `children`, named props. | Composition. | Slots accept incompatible content. |
| Compound Components | Related components share implicit context. | Ergonomic APIs for complex widgets. | Tabs, accordion, menu. | Simpler component is enough. | Client `Tabs` inside a server-rendered page. | `<Tabs><Tabs.List /></Tabs>`. | Context, slots. | Context causes unnecessary re-renders. |
| Controlled Component | Parent owns value. | External orchestration and validation. | Search inputs, form fields with live validation. | DOM can own state simply. | URL-synced filter input. | `value` and `onChange`. | Form state. | Every input controlled without need. |
| Uncontrolled Component | DOM owns value. | Lower overhead and simpler forms. | File input, simple server-action forms. | Need immediate UI state. | Native form posts to Server Action. | `defaultValue`, refs. | Native forms. | Reading DOM manually everywhere. |
| Render Prop | Share rendering behavior through function child. | Caller controls rendering. | Specialized headless utilities. | Hooks or composition are clearer. | Rare in App Router. | `{state => <UI />}`. | Headless components. | Function prop breaks RSC boundaries. |

## State Management Patterns

| Pattern | Intent | Problem It Solves | When to Use | When to Avoid | Next.js Example | React Example | Related Patterns | Common Misuse |
|---|---|---|---|---|---|---|---|---|
| Local State | Keep interaction state near owner. | Avoid global complexity. | Toggle, active tab, local dialog. | Distant components need same state. | Client `SortMenu`. | `useState`. | Lifted state. | Premature store usage. |
| Lifted State | Share state through common parent. | Coordinate siblings. | Small component subtree. | Creates deep prop chains. | Filter shell owns selected filters. | Parent passes props. | Context, URL state. | Lifting too high. |
| Context | Cross-tree low-frequency state. | Avoid prop drilling for stable values. | Theme, locale, auth shell. | High-frequency updates. | `ThemeProvider` in layout. | `useContext`. | Provider pattern. | Server data cache replacement. |
| URL State | Make state shareable and navigable. | Filters, search, pagination. | State should survive reload/share link. | Sensitive or high-frequency state. | `searchParams` drive product filters. | `URLSearchParams`. | Server rendering. | Storing large objects in URL. |
| External Store | Shared client UI state. | Distant interactive components need updates. | Sidebar layout, command palette. | Server data. | Zustand UI store. | `useSyncExternalStore`. | Selectors. | Global dumping ground. |

## Data Fetching Patterns

| Pattern | Intent | Problem It Solves | When to Use | When to Avoid | Next.js Example | React Example | Related Patterns | Common Misuse |
|---|---|---|---|---|---|---|---|---|
| Server Fetching | Fetch before client hydration. | SEO and less client JS. | Most page data. | Highly interactive client-only data. | `await getProducts()` in Server Component. | RSC async component. | DAL, caching. | Fetching secrets in Client Components. |
| DAL | Centralize secure data access. | Prevent leakage and duplicated auth checks. | Apps with auth/data rules. | Tiny static apps. | `src/shared/api/server/products.ts`. | Server-only module. | DTO, ACL. | DAL returns raw DB objects. |
| TanStack Query/SWR | Manage client server state. | Client refetching, dedupe, stale data. | Interactive client data. | Data can render on server. | Client dashboard widget. | `useQuery`. | Optimistic UI. | Store all API data globally. |
| BFF | Frontend-specific backend facade. | Browser-safe aggregation. | Multiple backend services or secret headers. | Direct public API is enough. | Route Handler `/api/dashboard`. | Fetch from BFF. | Facade, adapter. | Business logic duplicated in BFF. |

## Rendering Patterns

| Pattern | Intent | Problem It Solves | When to Use | When to Avoid | Next.js Example | React Example | Related Patterns | Common Misuse |
|---|---|---|---|---|---|---|---|---|
| Static Rendering | Fast CDN-served output. | Stable content performance. | Marketing, docs, catalogs with ISR. | Personalized request data. | Static product category page. | Server-rendered static tree. | ISR. | Static page with user-specific data. |
| Dynamic Rendering | Per-request render. | Personalized or request-bound data. | Auth dashboards. | Stable content. | `cookies()` or dynamic data route. | Server render per request. | Streaming. | Dynamic by accident. |
| Streaming | Show shell while data loads. | Slow data waterfalls. | Dashboards, search. | Tiny fast pages. | Suspense around slow widget. | `<Suspense fallback />`. | PPR. | Skeletons that shift layout. |
| Partial Prerendering | Static shell plus dynamic islands. | Fast initial shell with personalized data. | E-commerce and landing pages with dynamic sections. | Unsupported hosting/version. | Static page shell streams cart state. | Suspense boundaries. | Streaming, ISR. | Assuming experimental feature is stable. |

## UI Composition Patterns

| Pattern | Intent | Problem It Solves | When to Use | When to Avoid | Next.js Example | React Example | Related Patterns | Common Misuse |
|---|---|---|---|---|---|---|---|---|
| Headless Component | Behavior without imposed styling. | Accessible reusable interactions. | Menus, dialogs, combobox. | Simple native element works. | Radix dialog in Client Component. | Hook plus components. | Compound components. | Styling breaks accessibility. |
| Design-System Primitive | Stable low-level UI. | Consistent look and accessibility. | Buttons, inputs, typography. | One-off visuals. | `shared/ui/Button`. | Variant typed component. | Tokens, variants. | Primitive imports business logic. |
| Domain Component | Business-aware UI. | Reuse within domain. | ProductCard, UserAvatar. | Generic UI primitive is enough. | `entities/product/ProductCard`. | Props use domain DTO. | FSD entities. | Domain component becomes feature action. |

## Form Patterns

| Pattern | Intent | Problem It Solves | When to Use | When to Avoid | Next.js Example | React Example | Related Patterns | Common Misuse |
|---|---|---|---|---|---|---|---|---|
| Native Form | Use browser form behavior. | Low JS, progressive enhancement. | Simple submissions. | Complex client validation. | `<form action={serverAction}>`. | Uncontrolled inputs. | Server Actions. | No accessible errors. |
| React Hook Form | Efficient client form state. | Complex client validation and dirty state. | Multi-field interactive forms. | Simple one-action form. | Client form calls Server Action. | `useForm`. | Zod resolver. | Duplicated server/client schemas. |
| Server Action Form | Secure server-side mutation. | UI-driven mutation without API route. | App-only forms. | Mobile/external clients need API. | Login form action. | `useActionState`. | Revalidation. | Treating action as public API. |
| Multi-Step Form | Divide complex flow. | Reduce cognitive load. | Onboarding, checkout. | Simple form. | Wizard route group. | Step state + validation. | URL state, form store. | Losing partial state or accessibility. |

## Error Handling Patterns

| Pattern | Intent | Problem It Solves | When to Use | When to Avoid | Next.js Example | React Example | Related Patterns | Common Misuse |
|---|---|---|---|---|---|---|---|---|
| Route Error Boundary | Recover route segment failure. | Prevent whole app crash. | Every important route segment. | Expected validation errors. | `error.tsx`. | Error boundary. | Suspense. | Showing generic blank screen. |
| Not Found Boundary | Dedicated missing resource UI. | 404 clarity. | Resource detail pages. | Unauthorized resource should be forbidden. | `notFound()`. | Conditional fallback. | Metadata. | Hiding auth failures as 404 without policy. |
| Error Normalization | Stable error shape. | UI handles errors consistently. | API clients and forms. | One-off local error. | `normalizeApiError`. | Discriminated union. | Toast, field errors. | Leaking raw backend errors. |

## Performance Patterns

| Pattern | Intent | Problem It Solves | When to Use | When to Avoid | Next.js Example | React Example | Related Patterns | Common Misuse |
|---|---|---|---|---|---|---|---|---|
| Dynamic Import | Split rarely used client code. | Large initial bundles. | Modals, charts, editors. | Critical above-fold UI. | `dynamic(() => import(...))`. | `lazy`. | Suspense. | Loading spinner for critical content. |
| Virtualization | Render visible rows only. | Huge lists. | Thousands of rows. | Small lists. | Client table virtualization. | TanStack Virtual. | Pagination. | Breaks accessibility/focus. |
| Debounce | Delay frequent work. | Search input calls. | Typing filters. | Immediate feedback required. | Debounced URL update. | Timer hook. | Throttle. | Debouncing state users expect instantly. |
| Memoization | Avoid expensive recalculation or re-render. | Proven hot paths. | Expensive derived data. | Cheap calculations. | Memoize chart data in Client Component. | `useMemo`, `memo`. | Selectors. | Blanket memoization. |

## Accessibility Patterns

| Pattern | Intent | Problem It Solves | When to Use | When to Avoid | Next.js Example | React Example | Related Patterns | Common Misuse |
|---|---|---|---|---|---|---|---|---|
| Semantic First | Use native elements. | Built-in keyboard and screen reader behavior. | Always. | Rare custom control with full a11y support. | `<button>`, `<nav>`, `<main>`. | Native elements. | ARIA. | `div` with click handler. |
| Focus Trap | Keep focus inside modal. | Keyboard users lost behind overlay. | Dialogs and drawers. | Non-modal popovers. | Radix Dialog. | Ref-based focus management. | Restore focus. | No escape or return focus. |
| Roving Tabindex | Manage keyboard within composite widgets. | Arrow-key navigation. | Menus, tabs, grids. | Native controls suffice. | Headless UI menu. | State + key handlers. | ARIA roles. | Incorrect roles or tab stops. |
| Accessible Field Errors | Connect error text to input. | Screen readers announce errors. | All forms. | Never avoid. | `aria-describedby`. | Field component. | Form validation. | Color-only error state. |

---

# State Management Decision Matrix

| State Type | Best Tool | Use When | Avoid When |
|---|---|---|---|
| Local Component State | `useState`, `useReducer` | One component or close subtree owns it. | Distant components need it. |
| Lifted State | Parent state | Sibling coordination is simple. | Creates deep prop drilling. |
| Context API | React Context | Low-frequency cross-tree values. | High-frequency data or large server data. |
| URL State | Search params/path | State should be shareable, bookmarkable, reloadable. | Sensitive or complex object state. |
| Server State | RSC fetch cache, Data Cache | Data primarily comes from server and can render server-side. | Client must refetch interactively. |
| TanStack Query | React Query | Client-side server state, cache, retries, optimistic updates. | Server Components already solve the data need. |
| SWR | SWR | Lightweight stale-while-revalidate client data. | Complex mutations/cache coordination. |
| Zustand | Zustand | Moderate shared UI state with selective subscriptions. | Server data or strict enterprise audit requirements. |
| Redux Toolkit | RTK | Large enterprise state workflows, strict events, devtools, policies. | Small app or simple UI state. |
| Jotai | Jotai | Fine-grained atomic client state. | Team prefers explicit store structure. |
| Recoil | Recoil | Legacy or existing Recoil apps. | New projects unless strong reason. |
| Form State | RHF/native/useActionState | Input values, dirty state, field errors. | General app state. |

## State Rules

- Do not store server data in client-only stores by default.
- Do not use Redux because the app has more than one component.
- Use URL state for filters, pagination, sorting, and tabs that should survive refresh.
- Use Context for stable concerns such as theme and locale, not high-frequency data streams.
- Form state is not global app state.
- Use TanStack Query or SWR only when client-side refetching and synchronization are needed.

---

# Styling and UI Systems

## Options and Trade-Offs

| Tool | Strength | Risk | Use When |
|---|---|---|---|
| CSS Modules | Local CSS with low runtime cost. | Can become verbose for variants. | Component-scoped styling with CSS fundamentals. |
| Tailwind CSS | Fast utility workflow and consistent constraints. | Class soup and design drift if undisciplined. | Product teams needing speed and consistency. |
| Sass | Mature CSS preprocessing. | Less necessary with modern CSS. | Existing Sass codebase or complex CSS organization. |
| CSS-in-JS | Dynamic styling ergonomics. | Runtime cost and RSC compatibility concerns vary. | Design systems needing runtime theming, after evaluation. |
| Styled Components | Familiar CSS-in-JS. | SSR/RSC complexity and runtime overhead. | Existing app already standardized on it. |
| Emotion | Flexible CSS-in-JS. | Similar runtime and SSR concerns. | Existing design system choice. |
| shadcn/ui | Copyable component starting points on Radix/Tailwind. | Not a packaged design system; ownership is yours. | Fast accessible UI baseline. |
| Radix UI | Accessible headless primitives. | Styling and composition still require discipline. | Dialogs, popovers, menus, selects. |
| Headless UI | Accessible Tailwind-friendly components. | Component constraints may not fit all designs. | Tailwind-based apps. |

## Rules of Thumb

- Styling must preserve accessibility.
- Use design tokens for color, spacing, typography, radius, shadows, and motion.
- Component variants should be finite and typed.
- Responsive design is content-driven, not only breakpoint-driven.
- Dark mode needs token strategy, not ad-hoc inverted colors.
- Respect `prefers-reduced-motion`.
- Do not make visual-only focus indicators disappear.

---

# Forms and Validation

## Concise Explanation

Forms are data-entry workflows, not just inputs. Production forms must handle validation, error messaging, accessibility, pending state, optimistic updates when safe, server failures, auth errors, and data revalidation.

## Tooling

| Tool | Use When | Avoid When |
|---|---|---|
| Native Forms | Simple submissions, progressive enhancement, Server Actions. | Rich client interactivity required. |
| React Hook Form | Complex client-side forms, performance-sensitive forms. | Simple single-action forms. |
| Formik | Existing legacy apps. | New projects where RHF is a better fit. |
| Zod | TypeScript-first runtime validation. | Team standard is another schema library. |
| Yup | Existing legacy apps. | New TypeScript-first projects unless already standardized. |
| Server Actions | App-only secure mutations. | External/mobile clients need the same mutation contract. |

## Form Rules

- Validate on the server even if validating on the client.
- Associate labels with controls.
- Connect field errors using `aria-describedby` and clear text.
- Preserve user input after validation failure.
- Use optimistic updates only when rollback behavior is clear.
- Use direct-to-object-storage flows for large file uploads when possible.
- Multi-step forms need persistence, validation per step, and accessible navigation.
- Never trust hidden inputs for authorization-sensitive values.

## Server Action Pattern

```ts
"use server";

import { z } from "zod";

const schema = z.object({
  email: z.string().email(),
});

export async function updateEmailAction(_: unknown, formData: FormData) {
  const parsed = schema.safeParse({ email: formData.get("email") });

  if (!parsed.success) {
    return { status: "error", message: "Enter a valid email address" };
  }

  // Authorize, mutate, revalidate tag, return serializable state.
  return { status: "success" };
}
```

---

# API and Backend Integration

## Integration Options

| Option | Best For | Watch Out For |
|---|---|---|
| REST | Public APIs, simple contracts, broad tooling. | Over-fetching and weak typing if unmanaged. |
| GraphQL | Client-specific reads and graph-shaped data. | N+1, authorization, caching, complexity limits. |
| tRPC | Type-safe full-stack TypeScript apps. | Not ideal for public or non-TypeScript consumers. |
| BFF | Frontend-specific aggregation and security facade. | Business logic duplication. |
| Route Handlers | Public endpoints, webhooks, BFF endpoints. | Need explicit auth, validation, error normalization. |
| Server Actions | UI-driven mutations inside App Router. | Not a universal API for external consumers. |

## API Rules

- Normalize errors into stable UI-safe shapes.
- Use abort signals for cancelable client requests.
- Define retry behavior only for idempotent or safe operations.
- Always design loading, empty, error, and success states.
- Use pagination for unbounded lists.
- Use infinite scrolling only when it improves UX and remains accessible.
- Keep filtering and sorting in URL state when shareable.
- Use optimistic UI for reversible or low-risk operations only.
- Auth flows must handle expired sessions, redirects, and forbidden resource access.

---

# Authentication and Authorization

## Rules of Thumb

- Store session tokens in secure, HttpOnly cookies when possible.
- Do not store sensitive tokens in `localStorage`.
- Middleware can redirect unauthenticated users, but it should not be the only authorization layer.
- Verify permissions at data access and mutation boundaries.
- Check operation permission, resource ownership, and workspace/context membership.
- Do not send privileged fields to Client Components.
- Treat UI hiding as convenience, not security.
- Protect Server Actions against CSRF and unauthorized use.

## Authorization Planes

| Plane | Question |
|---|---|
| Operation/RBAC | Can this user perform this action? |
| Resource Ownership | Does this user own or have access to this object? |
| Context/Workspace | Is this action within the correct organization, tenant, or workspace? |

---

# Error Handling

## Rules of Thumb

- Expected validation errors are not exceptions in UI flow.
- Use `error.tsx` for unexpected route segment failures.
- Use `not-found.tsx` and `notFound()` for true missing resources.
- Use field-level errors for forms, inline errors for local failures, and toasts for transient global feedback.
- Do not expose raw backend stack traces or database messages.
- Provide recovery actions: retry, go back, contact support, sign in again.
- Log enough context server-side to debug without leaking sensitive data client-side.

---

# Testing Strategy

## Test Types

| Test Type | Purpose | Tools |
|---|---|---|
| Unit Tests | Pure functions, schemas, formatters, reducers. | Vitest, Jest. |
| Component Tests | Client component behavior and accessibility. | React Testing Library. |
| Integration Tests | Components with routing/data mocks. | RTL, MSW. |
| End-to-End Tests | Real user journeys and browser behavior. | Playwright, Cypress. |
| Visual Regression | UI appearance changes. | Playwright screenshots, Chromatic, Percy. |
| Accessibility Tests | Automated a11y checks. | axe, Playwright, Testing Library queries. |

## Next.js Testing Rules

- Use Vitest/Jest for pure logic, schemas, utilities, and client hooks.
- Use Playwright for critical flows, auth, routing, forms, and RSC behavior in a real browser.
- Mock network with MSW when testing client-side API behavior.
- Test loading, empty, error, and success states.
- Test form validation and accessible error announcements.
- Test authorization-sensitive UI with allowed and forbidden users.
- Do not rely only on snapshot tests for meaningful UI behavior.
- Async Server Components can be awkward in unit tests; prefer E2E or integration coverage where it provides better confidence.

---

# Accessibility

## Rules of Thumb

- Use semantic HTML before ARIA.
- Interactive elements must be keyboard reachable and operable.
- Buttons perform actions; links navigate.
- Every form input needs a label.
- Error messages must be programmatically associated with fields.
- Modal dialogs must trap focus and restore focus to the trigger.
- Menus, comboboxes, tabs, and dialogs should use proven accessible primitives when possible.
- Maintain visible focus states.
- Meet color contrast requirements.
- Do not communicate state by color alone.
- Respect reduced motion preferences.

## Testing Accessibility

- Navigate flows using only keyboard.
- Check screen reader-friendly names using Testing Library queries.
- Run automated axe checks, but do not treat automation as complete coverage.
- Verify headings are logical and landmarks exist.
- Verify loading and error states are announced when needed.

---

# Performance and Core Web Vitals

## Core Web Vitals

| Metric | Meaning | Common Frontend Causes |
|---|---|---|
| LCP | Largest Contentful Paint. | Slow server response, unoptimized hero image, render-blocking assets. |
| CLS | Cumulative Layout Shift. | Missing image dimensions, late fonts, injected banners. |
| INP | Interaction to Next Paint. | Excessive JavaScript, long tasks, heavy hydration. |

## Performance Rules

- Reduce client JavaScript before micro-optimizing components.
- Keep `use client` boundaries small.
- Use `next/image` with dimensions and appropriate priority/preload for critical images based on framework version.
- Use `next/font` and limit font weights/styles.
- Use streaming and Suspense boundaries for slow data sections.
- Use dynamic imports for non-critical heavy client code.
- Use virtualization for genuinely large lists.
- Debounce or throttle high-frequency interactions.
- Prefetch deliberately; do not waste bandwidth on unlikely navigation.
- Analyze bundle size before adding large dependencies.
- Use Lighthouse and real user monitoring where possible.

## Common Performance Mistakes

- Treating App Router as a client-side SPA.
- Importing chart editors, maps, or rich text editors into initial bundles.
- Fetching data sequentially when requests are independent.
- Rendering thousands of rows without pagination or virtualization.
- Using client-side auth gates that hide content after hydration.
- Optimizing with memoization while the real issue is hydration or network latency.

---

# SEO, Metadata, and Internationalization

## SEO Rules

- Use the Metadata API for titles, descriptions, canonical URLs, robots, Open Graph, and Twitter metadata.
- Keep SEO-critical content server-rendered when possible.
- Use semantic headings and meaningful link text.
- Generate structured data when it helps search features and is accurate.
- Avoid duplicate content without canonical strategy.
- Handle `notFound()` and redirects intentionally.

## Internationalization Rules

- Decide routing strategy early: locale prefix, domain routing, or user preference.
- Use locale-aware date, number, currency, and plural formatting.
- Do not concatenate translated strings when grammar may vary.
- Plan for text expansion and right-to-left layouts.
- Keep translation keys stable and meaningful.
- Validate forms and errors in the user's locale.

---

# Security

## Rules of Thumb

- Prevent XSS by avoiding unsafe HTML; sanitize when rendering trusted rich text is required.
- Use secure, HttpOnly, SameSite cookies for sessions when possible.
- Treat `NEXT_PUBLIC_*` variables as public and non-secret.
- Verify authorization on the server for every protected operation.
- Validate input in Route Handlers and Server Actions.
- Use CSRF protection for state-changing operations when cookie-based auth is used; verify Origin/Host where appropriate.
- Use Content Security Policy with nonces where feasible.
- Add `rel="noopener noreferrer"` for untrusted external links opened in new tabs.
- Audit dependencies and avoid large unmaintained packages.
- Do not log secrets, tokens, sensitive PII, or full payment data.
- Use `server-only` for privileged server modules.
- Consider React taint APIs only when supported and appropriate; treat them as version-dependent safeguards, not a replacement for DTO discipline.

## Server/Client Boundary Risks

- Importing server modules into Client Components can leak secrets or break builds.
- Returning raw database records can expose fields the UI does not need.
- Passing class instances or functions across the RSC boundary fails serialization.
- Client-side authorization checks can be bypassed.

---

# Maintainability and Scalability

## Rules of Thumb

- Keep route files thin.
- Enforce module public APIs in large apps.
- Use dependency boundaries and lint rules when possible.
- Keep business-related UI colocated with the relevant feature or entity.
- Keep shared UI business-agnostic.
- Document non-obvious rendering and caching decisions.
- Prefer boring tools unless product needs justify specialized ones.
- Automate standards: formatting, linting, typecheck, tests, accessibility checks where possible.

## Monorepo Considerations

- Shared packages need clear ownership and versioning discipline.
- Avoid leaking app-specific assumptions into shared packages.
- Keep design tokens and UI primitives stable.
- Do not create shared packages before reuse is real.
- Watch bundle boundaries when importing workspace packages.

---

# Frontend Anti-Patterns

| Anti-Pattern | Detection | Why It Hurts | Preferred Response |
|---|---|---|---|
| Everything Is Client | `use client` in layouts/pages and large subtrees. | High bundle and hydration cost. | Move data and structure to Server Components. |
| Global Store Dumping Ground | Unrelated data in one store. | Re-renders, stale data, unclear ownership. | Local, URL, server, or scoped store state. |
| Server Data in Client Store | API responses copied into Zustand/Redux by default. | Stale cache and sync bugs. | Use RSC cache, TanStack Query, or SWR. |
| Prop Drilling Through Server Tree | Data passed through many server layers. | Noise and coupling. | Fetch where needed with request memoization. |
| Fat Route Files | `page.tsx` owns data, UI, forms, and state. | Hard to test and refactor. | Delegate to page modules, widgets, features. |
| Shared Folder Gravity Well | Everything goes into `shared`. | Business coupling and hidden dependencies. | Move logic to feature/entity slices. |
| Div Soup | Clickable divs and non-semantic markup. | Broken keyboard/screen reader UX. | Use semantic elements and accessible primitives. |
| Boolean Prop Explosion | Many flags control component modes. | Impossible combinations. | Use variants, composition, or discriminated props. |
| Over-Memoization | `memo` everywhere. | Cognitive overhead with little gain. | Measure and optimize hot paths. |
| Client-Only Auth Gate | Protected content flashes or waits for hydration. | Security and UX issues. | Server-side auth checks and redirects. |
| No Empty/Error States | Only happy path designed. | Poor production UX. | Explicit state design and tests. |

---

# How Concepts Relate

- Next.js determines execution and routing strategy.
- React determines component composition and client interaction behavior.
- TypeScript constrains contracts and state shape.
- Runtime validation protects boundaries TypeScript cannot see.
- Architecture determines where code belongs and which modules may depend on others.
- FSD provides scalable business-oriented boundaries when the app is large enough.
- State management depends on ownership: local, URL, server, form, or shared UI.
- Data fetching, caching, and rendering strategy directly affect performance and UX.
- Forms combine validation, accessibility, mutation, error handling, and revalidation.
- Security constrains data access, auth, server/client boundaries, and environment configuration.
- Accessibility and performance are not polish; they are acceptance criteria for production UI.
- Testing proves behavior across pure logic, components, browser flows, and accessibility states.

---

# Prioritized Learning Path

## Junior Frontend Developer

- HTML semantics, forms, links, buttons, headings, and landmarks.
- CSS layout, responsive design, focus states, and accessible styling.
- JavaScript fundamentals: modules, async/await, arrays, objects, DOM events.
- React basics: components, props, state, events, controlled forms.
- TypeScript basics: props typing, unions, narrowing, avoiding `any`.
- Next.js basics: App Router pages, layouts, images, metadata.
- Testing basics with React Testing Library and Playwright smoke flows.

## Mid-Level Frontend Developer

- Server vs Client Components and serialization boundaries.
- Data fetching, caching, loading, error, and empty states.
- Form architecture with Zod, React Hook Form, and Server Actions.
- URL state, server state, and client UI state separation.
- Component composition, variants, and design-system primitives.
- Accessibility patterns for modals, menus, and forms.
- Performance fundamentals: Core Web Vitals, bundle analysis, images, fonts.
- API integration patterns and error normalization.

## Senior Frontend Developer

- Feature-Sliced Design and dependency boundary enforcement.
- Advanced App Router routing: route groups, parallel routes, intercepting routes.
- Streaming, ISR, PPR trade-offs, and deployment constraints.
- Auth and authorization at data access boundaries.
- Design-system governance, tokens, theming, dark mode.
- Testing strategy across unit, integration, E2E, visual, and a11y.
- Security hardening: CSP, CSRF, XSS, secrets, server-only modules.
- Performance measurement with Lighthouse, RUM, traces, and bundle budgets.

## Staff or Architect Level

- Frontend platform strategy and monorepo governance.
- Cross-team architecture standards and automated fitness checks.
- Design system ownership and migration strategy.
- Rendering, caching, and deployment policy by route class.
- Internationalization and multi-tenant frontend architecture.
- Incident analysis for frontend performance and availability.
- Product-aware trade-offs between delivery speed, UX quality, and technical debt.

---

# Frontend Agent Checklist

## Before Designing

- Confirm task scope, acceptance criteria, and non-goals.
- Identify whether the task is route, component, form, data, state, styling, auth, performance, or accessibility work.
- Confirm App Router or Pages Router baseline.
- Confirm package manager, styling system, test tools, and design-system conventions.
- Confirm whether FSD or another architecture is already used.
- Identify server/client boundaries and data sensitivity.
- Ask questions when behavior, permissions, responsiveness, or data freshness are ambiguous.

## During Design

- Choose Server Component by default.
- Add Client Component only for interaction or browser-only requirements.
- Keep route files thin.
- Place code in the correct feature/entity/widget/shared layer when FSD is used.
- Define loading, empty, error, success, and unauthorized states.
- Define validation and authorization boundaries.
- Decide cache behavior and revalidation strategy.
- Choose state owner: local, lifted, URL, server, form, or global UI store.
- Preserve accessibility and keyboard behavior in the design.

## During Implementation

- Use strict TypeScript and avoid `any`.
- Validate runtime input and API responses where trust boundaries exist.
- Keep `use client` at leaf boundaries.
- Avoid importing server-only modules into Client Components.
- Use semantic HTML and accessible primitives.
- Use existing design-system components and tokens.
- Add or update tests for behavior changes.
- Avoid unrelated refactors and new dependencies unless justified.

## During Review

- Verify route and component boundaries.
- Verify FSD dependency direction and public APIs when applicable.
- Verify no sensitive data crosses server-client boundary.
- Verify forms have labels, errors, pending states, and server validation.
- Verify authorization is enforced on the server.
- Verify images, fonts, and client bundles are not needlessly heavy.
- Verify loading, error, empty, and not-found states.
- Verify keyboard navigation and focus behavior.
- Verify validation commands and test evidence are reported.

---

# Questions Before Proposing Implementation

- Is this application using App Router or Pages Router?
- Should this render on the server, client, edge, or statically?
- What data is needed and who is allowed to see it?
- Is the data public, personalized, sensitive, or tenant-scoped?
- What cache freshness is acceptable?
- Should invalidation use tags, path revalidation, client refetch, or no cache?
- Does the UI need loading, empty, error, unauthorized, or not-found states?
- What interactions require Client Components?
- Can `use client` be isolated to a smaller leaf?
- What state should be local, URL-based, server state, form state, or shared UI state?
- What validation is required client-side and server-side?
- Does the mutation need optimistic UI, idempotency, or rollback behavior?
- Are there authentication, authorization, ownership, or workspace rules?
- Are there SEO or metadata requirements?
- Are there accessibility requirements for keyboard, screen reader, focus, and contrast?
- Are there performance targets or Core Web Vitals concerns?
- Which design-system components and styling conventions already exist?
- What tests should prove the behavior?
- Are new dependencies justified and acceptable for bundle size?
- Are any proposed features experimental or deployment-platform dependent?

---

# Glossary

| Term | Meaning |
|---|---|
| App Router | Next.js routing architecture under `app/` with RSC, layouts, and segment files. |
| RSC | React Server Components, rendered on the server without client hydration. |
| Client Component | React component hydrated in the browser after `use client`. |
| Hydration | Browser process attaching React behavior to server-rendered HTML. |
| Serialization Boundary | Server-to-client boundary where only serializable values can pass. |
| DTO | Data Transfer Object containing only fields intended for transfer. |
| FSD | Feature-Sliced Design, business-oriented frontend architecture with strict layers. |
| Public API | A slice's exported contract, usually `index.ts`. |
| Server State | Data fetched from a server and cached/synchronized with server truth. |
| Client State | Browser-only UI state such as dialog open or selected tab. |
| URL State | State stored in route path or query params. |
| Server Action | Next.js server function callable from forms or client transitions. |
| Route Handler | Next.js server endpoint for HTTP requests. |
| ISR | Incremental Static Regeneration, refreshing static content after build. |
| PPR | Partial Prerendering, static shell with streamed dynamic content where supported. |
| Suspense | React mechanism for rendering fallback UI while async work resolves. |
| Core Web Vitals | User-centric metrics such as LCP, CLS, and INP. |
| LCP | Largest Contentful Paint. |
| CLS | Cumulative Layout Shift. |
| INP | Interaction to Next Paint. |
| CSP | Content Security Policy restricting script and resource execution. |
| CSRF | Cross-Site Request Forgery, unwanted state-changing requests using user's credentials. |
| XSS | Cross-Site Scripting, injection of malicious scripts into pages. |
| A11Y | Accessibility. |
| Design Token | Named design value such as color, spacing, or typography scale. |
| Headless UI | Behavior-focused UI primitive without imposed visual styling. |
| BFF | Backend for Frontend, API facade tailored for frontend needs. |

---

# Trusted Foundations

## Official Documentation

- Next.js official documentation for App Router, Server Components, caching, Server Actions, Metadata API, Image, Font, Middleware, Route Handlers, and deployment.
- React official documentation, especially `react.dev` guidance on effects, state, context, refs, Suspense, and performance.
- TypeScript Handbook and TypeScript release notes.
- MDN Web Docs for HTML, CSS, JavaScript, Web APIs, accessibility, security, and browser behavior.
- WAI-ARIA Authoring Practices Guide.
- Web.dev guidance on Core Web Vitals, performance, images, fonts, and accessibility.
- OWASP Web Security Testing Guide and OWASP Cheat Sheet Series.

## Libraries and Tools

- Zod documentation for runtime schemas.
- React Hook Form documentation for form state.
- TanStack Query documentation for server state.
- SWR documentation for stale-while-revalidate client data.
- Zustand documentation for lightweight client stores.
- Redux Toolkit documentation for enterprise state workflows.
- Radix UI documentation for accessible primitives.
- shadcn/ui documentation for component ownership and composition.
- Tailwind CSS documentation for utility-first styling.
- Playwright documentation for E2E and accessibility-oriented testing.
- React Testing Library documentation for user-centric component tests.
- Mock Service Worker documentation for API mocking.

## Authors and References

- Dan Abramov and the React team on React mental models and effects.
- Kent C. Dodds on testing user behavior and React Testing Library.
- Josh W. Comeau on CSS, UI polish, and frontend mental models.
- Addy Osmani on web performance and JavaScript cost.
- Harry Roberts on CSS architecture and web performance.
- Sara Soueidan and Adrian Roselli on accessibility.
- Feature-Sliced Design official documentation.

---

# Frontend Agent System Knowledge

The Frontend Developer Agent must always follow these condensed principles:

- Build the smallest correct frontend change that satisfies the task.
- Confirm App Router vs Pages Router, package manager, styling system, architecture pattern, and validation commands before implementation.
- Default to Server Components; use Client Components only for interactivity, browser APIs, effects, refs, and client state.
- Push `use client` to the smallest leaf component possible.
- Keep route files thin and delegate product UI to pages, widgets, features, entities, or shared modules according to project architecture.
- Enforce FSD dependency direction and public APIs when FSD is used.
- Pass only serializable DTOs across the server-client boundary.
- Protect server-only code with `server-only` where privileged data access exists.
- Validate all external data and form input at runtime; TypeScript types are not runtime validation.
- Keep state local by default; separate server state, client UI state, URL state, and form state.
- Do not store server data in client global stores without clear justification.
- Design loading, empty, error, success, unauthorized, and not-found states intentionally.
- Preserve semantic HTML, keyboard navigation, focus management, contrast, labels, and accessible errors.
- Authorize protected operations on the server at data access and mutation boundaries.
- Optimize by reducing client JavaScript first, then measure images, fonts, caching, streaming, and bundle size.
- Use precise cache revalidation such as `revalidateTag` when domain tags exist; avoid broad invalidation by default.
- Add meaningful tests for changed behavior, especially forms, auth, error states, accessibility, and critical user flows.
- Avoid new dependencies, global stores, GraphQL, complex design systems, or experimental Next.js features unless the task justifies them.
- Report exact commands run, results, files changed, decisions, and remaining risks.
- Never claim completion without validation evidence.
