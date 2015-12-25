class RemoveEmailDomainFromOrganizations < ActiveRecord::Migration
  def change
    remove_column :organizations, :domain, :string, null: false
  end
end
