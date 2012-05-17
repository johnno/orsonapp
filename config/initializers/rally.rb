config_file = File.join(Rails.root,'config','rally.yml')
data = YAML.load(ERB.new(File.read(config_file)).result)[Rails.env]
RALLY_USER = data['username']
RALLY_PASS = data['password']