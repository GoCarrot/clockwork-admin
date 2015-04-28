require 'rubygems'
require 'bundler'

Bundler.require

require './clockwork_admin'

map "/admin/clockwork" do
  run ClockworkAdmin
end
