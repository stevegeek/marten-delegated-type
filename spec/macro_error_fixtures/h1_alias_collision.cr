require "./preamble"

# A method named `page` is already defined on the host model before
# `delegated_type` is called — the macro must refuse to silently
# shadow it.
class H1Note < Marten::Model
  include MartenDelegatedType

  field :id, :big_int, primary_key: true, auto: true
  field :leafable, :polymorphic, to: [MEFixt::Page, MEFixt::Section]

  def page
    "pre-existing implementation"
  end

  delegated_type :leafable, types: [MEFixt::Page]
end
