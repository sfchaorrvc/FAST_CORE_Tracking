class RemoveImeiFromCommands < ActiveRecord::Migration
  def self.up
    remove_column :commands, :imei
  end

  def self.down
    add_column :commands, :imei, :string, :limit => 30
  end
end
