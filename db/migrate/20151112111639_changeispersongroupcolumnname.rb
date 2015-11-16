class Changeispersongroupcolumnname < ActiveRecord::Migration
  def change
   rename_column :db_related_agents, :is_person_group, :person_group
  end
end
