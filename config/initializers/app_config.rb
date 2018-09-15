# frozen_string_literal: true

config = YAML.safe_load(ERB.new(File.read(Rails.root.join('config', 'config.yml'))).result)
AppConfig = OpenStruct.new(config[Rails.env])
