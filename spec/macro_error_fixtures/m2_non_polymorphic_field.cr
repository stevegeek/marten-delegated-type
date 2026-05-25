require "./preamble"

# `:title` is a string field, not a polymorphic one. The macro should
# reject the call before emitting any code.
class M2Note < Marten::Model
  include MartenDelegatedType

  field :id, :big_int, primary_key: true, auto: true
  field :title, :string, max_size: 255, blank: false, null: false

  delegated_type :title, types: [MEFixt::Page]
end
