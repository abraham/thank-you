config = YAML.safe_load(ERB.new(File.read("#{Rails.root}/config/config.yml")).result)
AppConfig = OpenStruct.new(config[Rails.env])
