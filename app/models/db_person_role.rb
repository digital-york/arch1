class DbPersonRole < ActiveRecord::Base
  belongs_to :db_related_person_group
end
