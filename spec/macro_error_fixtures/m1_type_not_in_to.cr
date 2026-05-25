require "./preamble"

# `MEFixt::Section` is not in the polymorphic field's `to:` list; the
# macro should raise rather than emit a `section_leafable` call that
# wouldn't exist.
class M1Note < Marten::Model
  include MartenDelegatedType

  field :id, :big_int, primary_key: true, auto: true
  field :leafable, :polymorphic, to: [MEFixt::Page, OtherNamespace::Page]

  delegated_type :leafable, types: [MEFixt::Page, MEFixt::Section]
end
