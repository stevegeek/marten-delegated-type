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

    it "returns nil cleanly when the polymorphic target is unset on a fresh record" do
      note = Note.new(title: "blank")

      # All short-form accessors return nil; predicates return false.
      note.page.should be_nil
      note.section.should be_nil
      note.picture.should be_nil
      note.page?.should be_false
      note.section?.should be_false
      note.picture?.should be_false
    end

    it "exposes a pluralized class-level scope for each type (Rails parity)" do
      page = Leafables::Page.create!(body: "p")
      section = Leafables::Section.create!(heading: "s")
      Note.create!(title: "p-note", leafable: page)
      Note.create!(title: "s-note", leafable: section)

      # Class-level scope: returns only the notes whose polymorphic
      # target is a Page (delegates to Marten's with_page_leafable).
      page_notes = Note.pages.to_a
      page_notes.size.should eq 1
      page_notes.first.title.should eq "p-note"

      section_notes = Note.sections.to_a
      section_notes.size.should eq 1
      section_notes.first.title.should eq "s-note"

      Note.pictures.to_a.should be_empty
    end

    it "supports the `as:` keyword to override the alias name" do
      # `AliasNote` is defined in spec/test_project/models/alias_note.cr
      # with `delegated_type :leafable, types: [Leafables::Page], as: ["page_alt"]`.
      page = Leafables::Page.create!(body: "via alias")
      note = AliasNote.create!(title: "alias", leafable: page)

      # The aliased short-name accessor exists...
      note.page_alt.try(&.id).should eq page.id
      note.page_alt?.should be_true
      typeof(note.page_alt?).should eq ::Bool

      # ...and the class-level scope follows the alias name too.
      AliasNote.page_alts.to_a.size.should eq 1
    end
  end
end
