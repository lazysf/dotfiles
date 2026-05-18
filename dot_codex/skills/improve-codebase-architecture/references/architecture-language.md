# Architecture Language

Use these terms when discussing architecture improvement candidates.

## Terms

**Module**: Anything with an interface and an implementation, from a function to a package or feature slice.
_Avoid_: component, service, unit

**Interface**: Everything a caller must know to use a module correctly, including types, invariants, ordering, error modes, config, and performance expectations.
_Avoid_: API, signature

**Implementation**: The code and behavior hidden behind a module's interface.

**Depth**: The leverage a module provides through its interface; a deep module hides substantial behavior behind a small, stable interface.
_Avoid_: line-count ratio

**Shallow module**: A module whose interface is nearly as complex as the implementation it hides.

**Seam**: The place where behavior can vary through an interface without editing the caller in place.
_Avoid_: boundary

**Adapter**: A concrete implementation that satisfies an interface at a seam.

**Locality**: The degree to which change, bugs, and verification concentrate in one place rather than spreading across callers.

**Leverage**: The benefit callers get when one interface gives access to useful behavior without repeating knowledge.

## Principles

- Depth belongs to the interface, not to the number of implementation lines.
- The interface should be the main test surface.
- One adapter usually means a hypothetical seam; two adapters usually mean the seam is earning its keep.
- If deleting a module only moves the same complexity into callers, the module was probably doing useful work. If deleting it removes complexity, it may have been a pass-through.
