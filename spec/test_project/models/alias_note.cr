# Exercises the `delegated_type ..., as: [...]` keyword override —
# verifies that aliases can be customized away from the default
# `<type>.underscore` derivation.
#
# Note: the polymorphic field needs at least two target types so Marten
# can infer an `Array(Marten::DB::Model.class)` union for its `to:` arg;
# the `delegated_type` call below intentionally only aliases the first
# of them to keep the `as:`-list test focused.
class AliasNote < Marten::Model
  include MartenDelegatedType

  field :id, :big_int, primary_key: true, auto: true
  field :leafable, :polymorphic, to: [Leafables::Page, Leafables::Section]
  field :title, :string, max_size: 255, blank: false, null: false

  delegated_type :leafable, types: [Leafables::Page], as: ["page_alt"]
end
