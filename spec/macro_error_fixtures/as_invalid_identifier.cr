require "./preamble"

# `as: ["my-page"]` contains a hyphen, which isn't a valid Crystal
# identifier character. Without the shape check the macro would happily
# splice it into emitted `def`s and the user would see an opaque
# "can't define def inside def" expansion trace.
class AsInvalidIdentNote < Marten::Model
  include MartenDelegatedType

  field :id, :big_int, primary_key: true, auto: true
  field :leafable, :polymorphic, to: [MEFixt::Page, MEFixt::Section]

  delegated_type :leafable, types: [MEFixt::Page], as: ["my-page"]
end
