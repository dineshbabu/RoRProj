class CreateDeploymentConfigurations < ActiveRecord::Migration
  def change
    create_table :deployment_configurations do |t|
      t.string :log_dir
      t.integer :idle_timeout
      t.string :database
      t.string :host
      t.string :dmuser
      t.integer :thread_pool_size
      t.integer :enable_logging

      t.timestamps
    end
  end
end
