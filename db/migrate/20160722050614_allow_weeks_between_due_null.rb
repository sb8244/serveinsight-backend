class AllowWeeksBetweenDueNull < ActiveRecord::Migration
  def up
    change_column :survey_templates, :weeks_between_due, :integer, null: true
  end

  def down
    change_column :survey_templates, :weeks_between_due, :integer, null: false
  end
end
