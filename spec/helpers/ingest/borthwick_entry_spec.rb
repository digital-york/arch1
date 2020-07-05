require "rails_helper"

RSpec.describe Ingest::BorthwickEntry do
  let(:csv_data) do
    { register_no: "Register 7",
      folio_no: 139,
      folio_side: "(recto)",
      entry_no: 2,
      entry_type_1: "Mandate",
      section_type: "Archdeaconry of York",
      summary: "Mandate to the prioress and convent of Nun Appleton to receive Joan de Sandwyz [Sandwich], nominated by the archbishop.",
      subject_1: "Nuns",
      subject_2: "Prioresses",
      subject_3: "Religious Houses, Female",
      subject_4: "Women",
      referenced_by: "Brown, William, and A. Hamilton Thompson. (eds.). 1934. The Register of William Greenfield Lord Archbishop of York 1306-1315 Part II. Surtees Society 149, 58.",
      date_1: "1309/01/07",
      certainty_1: "certain",
      type_1: "single",
      date_role_1: "document date",
      place_as_written: "Cawod",
      place_name_authority: "Cawood",
      place_role: "place of dating",
      place_type: "none given" }
  end
  let(:entry) { Ingest::BorthwickEntry.new(csv_data) }

  context "Assemble RegisterEntryRow" do
    it "returns location of entry at register" do
      expect(entry.to_s).to include('Register 7 / 139 / (recto) / 2 / ["Mandate"]')
    end
    it "returns subjects" do
      expect(entry.subjects.size).to be(4)
      expect(entry.subjects).to eq(["Nuns", "Prioresses", "Religious Houses, Female", "Women"])
    end
    it "returns dates" do
      expect(entry.entry_dates.size).to be(1)
      expect(entry.entry_dates[0].date).to eq("1309/01/07")
    end
    it "returns places" do
      expect(entry.place_name.as_written).to eq("Cawod")
      expect(entry.place_name).to include("Cawood")
    end
    it "returns groups" do
      expect(entry.groups.size).to be(0)
    end
    it "returns pesrons" do
      expec(entry.persons.size).to be(0)
    end
  end
end
