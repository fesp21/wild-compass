class AddTareWeightToJars < ActiveRecord::Migration
  def change
    add_column :jars, :tare_weight, :decimal, precision: 16, scale: 4, null: false, default: 0.0
  end
end
