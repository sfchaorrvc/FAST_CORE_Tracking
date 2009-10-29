class AddCommandsTable < ActiveRecord::Migration
  def self.up
    create_table :commands, :force => true do |t|
      t.column :device_id, :integer
      t.column :imei, :string, :limit => 30
      t.column :command, :string, :limit => 100
      t.column :response, :string, :limit => 100
      t.column :status, :string, :limit => 100, :default => 'Processing'
      t.column :start_date_time, :datetime
      t.column :end_date_time, :datetime
      t.column :transaction_id, :string, :limit => 25
    end
  end

  def self.down
    drop_table :commands
  end
end
