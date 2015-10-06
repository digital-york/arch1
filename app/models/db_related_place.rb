class DbRelatedPlace < ActiveRecord::Base
  belongs_to :db_entry
  has_many :db_place_as_writtens
  has_many :db_place_types
  has_many :db_place_roles
  has_many :db_place_notes
end
