require 'rubygems'
require 'bundler'

Bundler.require

require 'clockwork/admin'

Clockwork::Admin::App.config_file File.join(File.dirname(__FILE__), 'clockwork_admin.yml')

map "/admin/clockwork" do
  run Clockwork::Admin::App
end
