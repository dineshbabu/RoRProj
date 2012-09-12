class DeploymentConfiguration < ActiveRecord::Base
  attr_accessible :database, :dmuser, :enable_logging, :host, :idle_timeout, :log_dir, :thread_pool_size
  validates :database, :dmuser,:enable_logging, :host, :idle_timeout, :log_dir, :thread_pool_size, presence: true
  
  #For ActiveRecord::Base object initialize not called when new() is invoked. 
  #def initialize(attributes = {})
  #  attributes.each do |name, value|
  #    send("#{name}=", value)
  #  end
  #end
  
  #def after_initialize(attributes = {})
  #  attributes.each do |name, value|
  #    send("#{name}=", value)
  #  end
  #end
  
  #def create(attributes = {})
  #  attributes.each do |name, value|
  #    send("#{name}=", value)
  #  end
  #end
  
end
