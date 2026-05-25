# Shared preamble for compile-time-failure fixtures. Each fixture
# requires this then defines a Marten model in a way that should make
# the `delegated_type` macro raise. We deliberately do not call
# `Marten.configure` — the macro errors fire during semantic analysis,
# well before configure-time would run, so wiring an app/database here
# would just slow the compile and obscure the real failure.
ENV["MARTEN_ENV"] = "test"

require "marten"
require "../../src/marten_delegated_type"

class MacroErrorSpecApp < Marten::App
  label :marten_delegated_type_macro_errors
end

module MEFixt
  class Page < Marten::Model
    field :id, :big_int, primary_key: true, auto: true
    field :body, :string, max_size: 255, blank: true, null: true
  end

  class Section < Marten::Model
    field :id, :big_int, primary_key: true, auto: true
    field :heading, :string, max_size: 255, blank: true, null: true
  end
end

module OtherNamespace
  class Page < Marten::Model
    field :id, :big_int, primary_key: true, auto: true
    field :body, :string, max_size: 255, blank: true, null: true
  end
end
