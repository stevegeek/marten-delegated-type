require "./preamble"

# Both `MEFixt::Page` and `OtherNamespace::Page` derive the same short
# name ("page"). Without `as:` overrides the macro should reject the
# call rather than emit two clashing `def page` definitions.
class H2Note < Marten::Model
  include MartenDelegatedType

  field :id, :big_int, primary_key: true, auto: true
  field :leafable, :polymorphic, to: [MEFixt::Page, OtherNamespace::Page]

  delegated_type :leafable, types: [MEFixt::Page, OtherNamespace::Page]
end
