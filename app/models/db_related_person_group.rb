class DbRelatedPersonGroup < ActiveRecord::Base
  belongs_to :db_entry
  has_many :db_person_as_writtens
  has_many :db_person_roles
  has_many :db_person_descriptors
  has_many :db_person_descriptor_as_writtens
  has_many :db_person_notes
  has_many :db_person_related_places
end
