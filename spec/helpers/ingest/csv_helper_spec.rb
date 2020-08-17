# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ingest::CsvHelper, '#parse_borthwick_spreadhseet' do
  context 'Process CSV file' do
    let(:entry_rows) { Ingest::CsvHelper.parse_borthwick_spreadsheet(csv_path) }
    let(:csv_path) { './spec/fixtures/Reg_7_132v-entry_6_155-York_EHW_ENTRIES.csv' }
    it 'expect return arrays of data entries' do
      expect(entry_rows.size).to be(20)
      expect(entry_rows[18].subjects).to eq(%w[Wives Women Daughters Sisters])
    end
  end

  context 'Display friendly errors when CSV file does not exist' do
    it 'expect to rails file not exists error'
    it 'expect to raise CSV::MalformedCSVError'
  end
end
