require 'ostruct'
require 'yaml'

config = YAML.load_file("#{Rails.root}/config/config.yml")
AppConfig = OpenStruct.new(config[Rails.env])
