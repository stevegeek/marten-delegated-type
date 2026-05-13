require "./spec_helper"

describe MartenDelegatedType do
  describe "the delegated_type macro" do
    it "exposes the short-form accessor that returns the typed instance when set" do
      page = Leafables::Page.create!(body: "hello")
      note = Note.create!(title: "with page", leafable: page)

      result = note.page
      result.should be_a(Leafables::Page?)
      result.try(&.id).should eq page.id
    end

    it "returns nil from the short-form accessor when the polymorphic target is a different type" do
      section = Leafables::Section.create!(heading: "section one")
      note = Note.create!(title: "with section", leafable: section)

      note.page.should be_nil
      note.picture.should be_nil
      # The matching short-form returns the record.
      note.section.try(&.id).should eq section.id
    end

    it "predicate (?) returns Bool true for the matching type" do
      picture = Leafables::Picture.create!(caption: "snap")
      note = Note.create!(title: "with picture", leafable: picture)

      note.picture?.should be_true
      note.picture?.should be_a(::Bool)
    end

    it "predicate (?) returns Bool false for the non-matching types" do
      page = Leafables::Page.create!(body: "p")
      note = Note.create!(title: "with page", leafable: page)

      note.section?.should be_false
      note.picture?.should be_false
      note.page?.should be_true
    end

    it "predicate accessors are typed as ::Bool (matches Rails' delegated_type signature)" do
      page = Leafables::Page.create!(body: "x")
      note = Note.create!(title: "n", leafable: page)
      # If the macro forgot the `: ::Bool` annotation this would be Bool?
      typeof(note.page?).should eq ::Bool
      typeof(note.section?).should eq ::Bool
      typeof(note.picture?).should eq ::Bool
    end

    it "short-form accessor type matches the polymorphic field's per-type accessor" do
      page = Leafables::Page.create!(body: "x")
      note = Note.create!(title: "n", leafable: page)
      # Both should be Leafables::Page? (nilable).
      typeof(note.page).should eq typeof(note.page_leafable)
    end
  end
end
