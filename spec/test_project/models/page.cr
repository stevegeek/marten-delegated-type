# Leafable types live under a Leafables module so the polymorphic field
# can refer to them as `Leafables::Page` etc. (mirroring the host project
# layout — Marten's polymorphic field is sensitive to relative vs.
# top-level name resolution).
module Leafables
  # A leafable type. Just needs a primary key so the polymorphic field on
  # Note has somewhere to point.
  class Page < Marten::Model
    field :id, :big_int, primary_key: true, auto: true
    field :body, :string, max_size: 255, blank: true, null: true
  end
end
