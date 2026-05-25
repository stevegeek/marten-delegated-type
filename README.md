# marten_delegated_type

A Crystal shard for [Marten](https://martenframework.com) that ports Rails'
[`delegated_type`](https://api.rubyonrails.org/classes/ActiveRecord/DelegatedType.html)
macro on top of Marten's built-in `field :polymorphic`.

Marten already supports polymorphic associations natively — declaring

```crystal
field :leafable, :polymorphic, to: [Page, Section, Picture]
```

generates per-type accessors named `<type>_<field>`: `page_leafable`,
`section_leafable`, `picture_leafable` (plus matching `?` predicates).
Rails' `delegated_type` exposes the same thing under the *shorter* `<type>`
form, so call sites read `leaf.page`, `leaf.section`, `leaf.picture`.
This shard provides the one macro that emits those aliases.

## Installation

Add to `shard.yml`:

```yaml
dependencies:
  marten_delegated_type:
    github: stevegeek/marten-delegated-type
```

Then `shards install`.

## Usage

```crystal
require "marten"
require "marten_delegated_type"

class Leaf < Marten::Model
  include MartenDelegatedType

  field :id, :big_int, primary_key: true, auto: true
  field :leafable, :polymorphic, to: [Page, Section, Picture]

  delegated_type :leafable, types: [Page, Section, Picture]
end
```

The `delegated_type` call generates:

| Method           | Returns         |
| ---------------- | --------------- |
| `leaf.page`      | `Page?`         |
| `leaf.page?`     | `Bool`          |
| `leaf.section`   | `Section?`      |
| `leaf.section?`  | `Bool`          |
| `leaf.picture`   | `Picture?`      |
| `leaf.picture?`  | `Bool`          |
| `Leaf.pages`     | `QuerySet`      |
| `Leaf.sections`  | `QuerySet`      |
| `Leaf.pictures`  | `QuerySet`      |

Each non-predicate accessor simply forwards to the underlying
`<type>_<field>` accessor that Marten's polymorphic field already
generated; predicates forward to `<type>_<field>?`; the class-level
pluralized scope (`Leaf.pages` etc.) forwards to Marten's
`with_<type>_<field>` query helper. No type registry, no runtime cost
— purely a compile-time rename for readability.

`leaf.page?` is **not** a DB hit: it compares the type-column string
against the type registered for `Page` (resolved at field declaration
time) — no query is issued. `leaf.page` does load the target on first
access but ivar-caches the result; subsequent reads are free.

`types:` must be an `ArrayLiteral` and every entry must be a subset of
the `to:` list on the polymorphic field declaration — both are
enforced at macro-expansion time with clear errors. Other rejected
inputs:

- A non-polymorphic `field` (e.g. a `:string`).
- Duplicate short names (e.g. `Foo::Page` + `Bar::Page` both deriving
  the alias `page`) without `as:` overrides.
- An alias that collides with an existing method/field on the host
  model.

### Customizing alias names (`as:`)

When the default `<type>.underscore` derivation produces a collision —
two `Page` classes in different namespaces, an existing `def page` on
the host, etc. — pass an `as:` array parallel to `types:`:

```crystal
class Leaf < Marten::Model
  include MartenDelegatedType

  field :leafable, :polymorphic, to: [Books::Page, Photos::Page]

  delegated_type :leafable,
                 types: [Books::Page, Photos::Page],
                 as: ["book_page", "photo_page"]
end
```

Now `leaf.book_page`, `leaf.book_page?`, `Leaf.book_pages` (and
likewise for `photo_page`) are exposed. The underlying delegation
target is still keyed by type, so the `Books::Page` accessor calls
Marten's `page_leafable`.

## Why a separate shard?

Rails' `delegated_type` predates Active Record's polymorphic_type/_id
column convention and bundles "polymorphism + STI-ish behaviour" into one
DSL. In Marten, polymorphism is a first-class field option that already
emits the type-suffixed accessors — all that's left of the Rails idiom is
the short-form alias. Keeping that alias in a tiny shard makes ports
read like the Rails source they came from.

## Development

```sh
shards install
script/cr spec/   # or `crystal spec`
```

## License

MIT — see `LICENSE`.
