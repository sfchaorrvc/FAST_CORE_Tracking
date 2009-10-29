class AddIndexReadingsOnGeocoded < ActiveRecord::Migration
  def self.up
    add_index :readings, [:geocoded], :name => 'index_readings_on_geocoded'
  end

  def self.down
    remove_index :readings, :name => :index_readings_on_geocoded
  end
end
