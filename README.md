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

| Method        | Returns               |
| ------------- | --------------------- |
| `leaf.page`     | `Page?`             |
| `leaf.page?`    | `Bool`              |
| `leaf.section`  | `Section?`          |
| `leaf.section?` | `Bool`              |
| `leaf.picture`  | `Picture?`          |
| `leaf.picture?` | `Bool`              |

Each non-predicate accessor simply forwards to the underlying
`<type>_<field>` accessor that Marten's polymorphic field already
generated; predicates forward to `<type>_<field>?`. No type registry, no
runtime cost — purely a compile-time rename for readability.

The macro accepts both array literals and tuple-like expressions for the
`types:` argument; the type list must match (or be a subset of) the
`to:` list on the polymorphic field declaration.

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
