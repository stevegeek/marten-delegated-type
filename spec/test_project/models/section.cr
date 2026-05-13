module Leafables
  class Section < Marten::Model
    field :id, :big_int, primary_key: true, auto: true
    field :heading, :string, max_size: 255, blank: true, null: true
  end
end
