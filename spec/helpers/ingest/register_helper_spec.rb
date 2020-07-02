require 'spec_helper'
require_relative "../../../app/helpers/ingest/register_helper"

# RSpec.describe MyMath do
#     it 'returns five' do
#         expect(MyMath.number).to eq(5)
#     end
# end

#module Ingest
#     module Register
        describe Ingest::RegisterHelper do

            it "has get_register_id" do
                id = Ingest::RegisterHelper.get_register_ids('Abp Reg 1A: Walter de Gray (1215-1255) Major roll 1225-1235')
                expect(id[0]).to eq('dz010q943')
            end
        end
#     end
#end