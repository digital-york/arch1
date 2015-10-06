class DbEntryDate < ActiveRecord::Base
  belongs_to :db_entry
  has_many :db_single_dates
end
