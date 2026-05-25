require "./spec_helper"

# These specs invoke the Crystal compiler on small fixture programs that
# are expected to fail macro expansion with the targeted `delegated_type`
# error message. We use `crystal build --no-codegen` so the compiler
# stops at the semantic phase — no executable is produced, and the wall
# time per invocation is short (a few seconds against the warm shard
# cache).
#
# Each fixture lives under `spec/macro_error_fixtures/` and is a
# standalone Crystal program that requires the shard, builds a tiny
# Marten model, and invokes `delegated_type` in a way the macro should
# reject. The compiler exit status must be non-zero and the substring
# below must appear in stderr.

private def shard_root
  File.expand_path("..", __DIR__)
end

private def cr_script
  File.join(shard_root, "script", "cr")
end

private def compile_fixture(name : String) : {Int32, String}
  fixture = File.join(shard_root, "spec", "macro_error_fixtures", name)
  out_path = File.tempname("marten_delegated_type_macro_check", ".bin")
  output = IO::Memory.new
  status = Process.run(
    cr_script,
    ["build", "--no-codegen", "--error-trace", fixture],
    output: output,
    error: output,
    chdir: shard_root,
  )
  File.delete?(out_path)
  {status.exit_code, output.to_s}
end

describe "delegated_type macro-time errors" do
  it "M2: rejects a non-polymorphic field" do
    code, out = compile_fixture("m2_non_polymorphic_field.cr")
    code.should_not eq 0
    out.should contain "is not a `:polymorphic` field"
  end

  it "M1: rejects a type outside the polymorphic field's `to:` list" do
    code, out = compile_fixture("m1_type_not_in_to.cr")
    code.should_not eq 0
    out.should contain "is not in the `to:` list"
  end

  it "H2: rejects duplicate short names across types" do
    code, out = compile_fixture("h2_duplicate_short_name.cr")
    code.should_not eq 0
    out.should contain "duplicate short name"
  end

  it "H1: rejects an alias that collides with an existing method" do
    code, out = compile_fixture("h1_alias_collision.cr")
    code.should_not eq 0
    out.should contain "a method with that name already exists"
  end

  it "H1: rejects an alias that collides with a method from an included module (MDR-N1)" do
    code, out = compile_fixture("h1_alias_collision_via_include.cr")
    code.should_not eq 0
    out.should contain "a method with that name already exists"
  end

  it "rejects an `as:` array with a mismatched length" do
    code, out = compile_fixture("as_length_mismatch.cr")
    code.should_not eq 0
    out.should contain "`as:` must have the same length"
  end

  it "rejects an `as:` entry that isn't a valid identifier shape (MDR-N2)" do
    code, out = compile_fixture("as_invalid_identifier.cr")
    code.should_not eq 0
    out.should contain "is not a valid Crystal identifier shape"
  end
end
