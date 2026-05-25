require "./preamble"

# The colliding `page` method isn't defined directly on the host — it's
# contributed by an `include`d module. The H1 guard must still catch it
# (the original guard, which scanned only `@type.methods`, missed this).
module SneakyPageMixin
  def page
    "from the mixin"
  end
end

class H1IncludeNote < Marten::Model
  include MartenDelegatedType
  include SneakyPageMixin

  field :id, :big_int, primary_key: true, auto: true
  field :leafable, :polymorphic, to: [MEFixt::Page, MEFixt::Section]

  delegated_type :leafable, types: [MEFixt::Page]
end
