require "./preamble"

# `as:` array has one entry but `types:` has two — the macro must
# refuse the mismatched-arity call instead of generating partial defs.
class AsLenNote < Marten::Model
  include MartenDelegatedType

  field :id, :big_int, primary_key: true, auto: true
  field :leafable, :polymorphic, to: [MEFixt::Page, MEFixt::Section]

  delegated_type :leafable, types: [MEFixt::Page, MEFixt::Section], as: ["only_one"]
end
