---
name: typescript-conventions
description: >
  TypeScript coding conventions for any TS project. Covers types & interfaces
  (interface extends over &, discriminated unions, no enums), functions & error
  handling (Result types, no any, explicit return types), imports (import type,
  no default exports), and naming conventions. Use when writing or reviewing
  TypeScript code.
---

# TypeScript Conventions

## Types & Interfaces

### Prefer `interface extends` over `&`

The `&` (intersection) operator has poor performance in the TypeScript compiler. Use `interface extends` for inheritance — it's faster and produces clearer error messages.

```ts
// Avoid
type C = A & B;

// Prefer
interface C extends A, B {}
```

Only use `&` where `interface extends` is not possible (e.g., combining mapped types).

### Use discriminated unions for variant data

Model data that can be in different shapes with a shared discriminant field. This prevents the "bag of optionals" problem where impossible states are representable.

```ts
// Avoid — allows { status: "idle", data: someValue }
type FetchingState<TData> = {
  status: "idle" | "loading" | "success" | "error";
  data?: TData;
  error?: Error;
};

// Prefer — each status carries exactly the right fields
type FetchingState<TData> =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "success"; data: TData }
  | { status: "error"; error: Error };
```

Handle discriminated unions with `switch` statements:

```ts
const handleEvent = (event: Event) => {
  switch (event.type) {
    case "user.created":
      console.log(event.data.email);
      break;
    case "user.deleted":
      console.log(event.data.id);
      break;
  }
};
```

### Avoid `readonly` unless strictly needed

Do not add `readonly` to properties by default. Only use it when immutability is a critical invariant that must be enforced at compile time (e.g., a shared config object that must never be mutated).

```ts
// Default — no readonly
type User = {
  id: string;
  name: string;
};
```

### Prefer optional properties over `T | undefined`

Use `prop?: T` for optional properties — it's more concise and idiomatic.

```ts
// Avoid
type AuthOptions = {
  userId: string | undefined;
};

// Prefer
type AuthOptions = {
  userId?: string;
};
```

### `noUncheckedIndexedAccess` awareness

When this tsconfig option is enabled, indexing into arrays and records returns `T | undefined` instead of `T`. Handle the `undefined` case — don't assume the value exists.

```ts
const arr: string[] = [];
const value = arr[0]; // string | undefined — check before using
```

### No enums — use `as const` objects

Enums have surprising behavior (numeric reverse mappings, `Object.keys` doubling). Use `as const` objects instead:

```ts
const SIZE = {
  xs: "EXTRA_SMALL",
  sm: "SMALL",
  md: "MEDIUM",
} as const;

type SizeKey = keyof typeof SIZE; // "xs" | "sm" | "md"
type SizeValue = (typeof SIZE)[SizeKey]; // "EXTRA_SMALL" | "SMALL" | "MEDIUM"
```

Retain existing enums in the codebase — don't convert them unless asked.

### Prefix type parameters with `T`

```ts
type RecordOfArrays<TItem> = Record<string, TItem[]>;
```

## Functions & Error Handling

### Declare return types on top-level functions

Explicit return types on module-level functions help both humans and AI assistants understand intent. Exceptions: JSX components and custom hooks don't need a return type annotation.

```ts
const parseInput = (raw: string): ParsedInput => { ... };

// Components — no return type needed
const MyComponent = () => {
  return <div>Hello</div>;
};

// Custom hooks — no return type needed
const useMyHook = () => {
  const [value, setValue] = useState(0);
  return { value, setValue };
};
```

### Use Result types instead of throwing

Thrown errors require manual try-catch and lose type information. Use a Result type for operations that can fail predictably:

```ts
type Result<T, E extends Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };
```

Throwing is fine when the framework handles it (e.g., inside a request handler that catches errors automatically). Use Result when the caller would need a manual try-catch.

### Never use `any` — prefer generics or `unknown`

`any` disables type checking entirely and defeats the purpose of TypeScript. Always use a more precise alternative:

- **Generic types** when the type varies but has structure:

```ts
// Avoid
const first = (arr: any[]): any => arr[0];

// Prefer
const first = <TItem>(arr: TItem[]): TItem | undefined => arr[0];
```

- **`unknown`** when the type is truly unknown — forces the caller to narrow before using:

```ts
// Avoid
const parse = (raw: string): any => JSON.parse(raw);

// Prefer
const parse = (raw: string): unknown => JSON.parse(raw);
```

- **Function overloads** when a generic function has conditional return types that TypeScript can't infer:

```ts
// Avoid — `as any` inside generic body
const toggle = <T extends "on" | "off">(
  input: T,
): T extends "on" ? "off" : "on" => {
  return (input === "on" ? "off" : "on") as any;
};

// Prefer — overloads with a generic implementation signature
function toggle(input: "on"): "off";
function toggle(input: "off"): "on";
function toggle(input: "on" | "off"): "on" | "off" {
  return input === "on" ? "off" : "on";
}
```

If none of the above work, use `as unknown as T` instead of `as any` — it preserves type safety at the boundary.

## Imports & Exports

### Use `import type` for type-only imports

Always use top-level `import type` — not inline `import { type ... }`. Without this, some bundlers leave behind an empty import side-effect.

```ts
// Avoid — may leave behind `import "./user"` after transpilation
import { type User } from "./user";

// Prefer
import type { User } from "./user";
```

### No default exports

Default exports create ambiguity at the import site — the name is arbitrary and disconnected from the source. Use named exports.

```ts
// Avoid
export default function myFunction() { ... }

// Prefer
export function myFunction() { ... }
```

Exception: frameworks that require default exports (e.g., Next.js pages).

## Naming & Style

| Element | Convention | Example |
|---------|-----------|---------|
| Files | kebab-case | `my-component.ts` |
| Variables & functions | camelCase | `myVariable`, `myFunction()` |
| Classes, types, interfaces | PascalCase | `MyClass`, `MyInterface` |
| Constants & `as const` values | ALL_CAPS | `MAX_COUNT`, `"EXTRA_SMALL"` |
| Type parameters | T-prefixed | `TKey`, `TValue` |

### JSDoc comments

Add JSDoc only when the function's behavior isn't self-evident. Be concise. Use `{@link}` to reference related functions.

```ts
/** Subtracts two numbers */
const subtract = (a: number, b: number) => a - b;

/** Does the opposite of {@link subtract} */
const add = (a: number, b: number) => a + b;
```

## Dependencies

When installing libraries, always use the package manager CLI rather than manually editing `package.json`. This ensures you get the latest version, since training data has a cutoff date. Use the package manager the project's lockfile indicates (`pnpm-lock.yaml` → `pnpm add`, `package-lock.json` → `npm install`, `yarn.lock` → `yarn add`).

```bash
pnpm add -D @typescript-eslint/eslint-plugin
```
