class Addpersongroupcheckboxcolumn < ActiveRecord::Migration
  def change
    add_column :db_related_agents, :is_person_group, :string
  end
end
