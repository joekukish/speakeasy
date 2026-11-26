require File.dirname(__FILE__) + "/spec_helper"

describe "Independent capabilities" do
  it "keeps capabilities out of language enumeration" do
    expect(Speakeasy::Capability.supported_capability_ids).to match_array(
      %w[Zmth-basic Zmth-extended Zsym-publishing]
    )
    expect(Speakeasy::Language.supported_language_ids.size).to eq(78)
    expect(Speakeasy::Language.supported_language_ids & Speakeasy::Capability.supported_capability_ids).to be_empty
    expect(Speakeasy::Capability.each.map(&:capability_id)).to match_array(
      %w[Zmth-basic Zmth-extended Zsym-publishing]
    )
  end

  it "requires the exact complete glyph inventories independently of language exclusions" do
    expected = {
      "Zmth-basic" => "0123456789+-*/=−×÷±<>≤≥≠(),.%",
      "Zmth-extended" => "0123456789+-*/=−×÷±<>≤≥≠(),.%∑∏√∞∫∂∇∈∉∅∩∪⊆⊇¬∧∨∀∃≈≡∝≪≫←→↔⇒⇔",
      "Zsym-publishing" => "©®™§¶•†‡…°&@#"
    }
    expected.each do |id, text|
      capability = Speakeasy::Capability.new(id)
      expect(capability.codepoints).to match_array(text.codepoints)
      expect(capability.supported_by?(text.codepoints)).to eq(true)
      expect(capability.supported_by?(text.codepoints.drop(1))).to eq(false)
    end
    expect(Speakeasy::Capability.new("Zmth-basic").supported_by?("+".codepoints)).to eq(false)
    expect {
      Speakeasy::Capability.new("Zmth-basic").supported_by?(nil)
    }.to raise_error(ArgumentError)
  end

  it "retains basic coverage when an extended-only glyph is missing" do
    basic = Speakeasy::Capability.new("Zmth-basic")
    extended = Speakeasy::Capability.new("Zmth-extended")
    glyphs = extended.codepoints.dup
    expect(basic.supported_by?(glyphs)).to eq(true)
    expect(extended.supported_by?(glyphs)).to eq(true)
    glyphs.delete(0x2211)
    expect(extended.supported_by?(glyphs)).to eq(false)
    expect(basic.supported_by?(glyphs)).to eq(true)
  end

  it "does not revoke language support when a capability glyph is missing" do
    english = Speakeasy::Language.new("en")
    math = Speakeasy::Capability.new("Zmth-basic")
    glyphs = (english.codepoints + math.codepoints).uniq
    expect(math.supported_by?(glyphs)).to eq(true)
    glyphs.delete(0x2212)
    expect(math.supported_by?(glyphs)).to eq(false)
    expect(english.codepoints - glyphs).to be_empty
  end

  it "separates only the six experimental symbols in generated languages" do
    preserved = %w[HK IPA Phag ff-Adlm khb km nqo panafrican shi so-Osma tdd zh-Hans zh-Hant]
    Speakeasy::Language.each do |language|
      next if preserved.include?(language.language_id)
      expect(language.codepoints & [35, 38, 61, 64, 215, 247]).to be_empty
    end
    expect(Speakeasy::Language.new("en").codepoints).to include(
      0x0030, 0x0039, 0x0021, 0x003F, 0x0024, 0x00A2, 0x00A3, 0x20AC
    )
  end
end
