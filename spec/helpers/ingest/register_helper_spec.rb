require 'rails_helper'

RSpec.describe Ingest::RegisterHelper do

    context 'When s_get_register_id search Solr index' do
        it 'returns id for existing register' do
            id = Ingest::RegisterHelper.s_get_register_ids('Abp Reg 1A: Walter de Gray (1215-1255) Major roll 1225-1235')
            expect(id[0]).to eq('dz010q943')
        end

        it 'returns empty [] for dumy register' do
            id = Ingest::RegisterHelper.s_get_register_ids('Dummy register')
            expect(id.class).to eq(Array)
        end
    end

end