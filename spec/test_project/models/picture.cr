module Leafables
  class Picture < Marten::Model
    field :id, :big_int, primary_key: true, auto: true
    field :caption, :string, max_size: 255, blank: true, null: true
  end
end
