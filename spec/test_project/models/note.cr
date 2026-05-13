# The host model — uses the polymorphic field plus the delegated_type
# macro from this shard. Mirrors the Writebook `Leaf` shape.
class Note < Marten::Model
  include MartenDelegatedType

  field :id, :big_int, primary_key: true, auto: true
  field :leafable, :polymorphic, to: [Leafables::Page, Leafables::Section, Leafables::Picture]
  field :title, :string, max_size: 255, blank: false, null: false

  delegated_type :leafable, types: [Leafables::Page, Leafables::Section, Leafables::Picture]
end
