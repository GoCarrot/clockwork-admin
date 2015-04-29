clockwork-admin - UI for clustered Clockwork
==========================================================

[Clockwork](https://rubygems.org/gems/clockwork/versions/1.2.0) is a lightweight Cron replacement. A [fork](https://github.com/GoCarrot/clockwork) supports using ZooKeeper to run a high-availability setup, with multiple Clockwork daemons running on separate machines coordinated using ZooKeeper.

This project interacts with the state stored in ZooKeeper to provide a basic admin UI, allowing you to pause jobs and see when they last ran.

## Usage

An example configuration file is provided in `examples/clockwork_admin.yml`. The path to this file must be passed to `Clockwork::Admin::App.config_file`.

### Stand-alone

An example rackup configuration file is provided `in examples/config.ru`.

### Rails

This project is designed to be embedded in any other Rack application. For rails, in particular:

`config/initializers/clockwork_admin.rb`:

    Clockwork::Admin::App.config_file File.join(Rails.root, 'config', 'clockwork_admin.yml')

`config/routes.rb`:

    Rails.application.routes.draw do
      mount Clockwork::Admin::App, at: 'admin/clockwork'
    end
