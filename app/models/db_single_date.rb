class DbSingleDate < ActiveRecord::Base
  belongs_to :db_entry_date
  has_many :db_date_certainties
end
