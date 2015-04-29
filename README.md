clockwork-admin - UI for clustered Clockwork
==========================================================

[Clockwork](https://rubygems.org/gems/clockwork/versions/1.2.0) is a lightweight Cron replacement. The [GoCarrot fork](https://github.com/GoCarrot/clockwork) supports using ZooKeeper to run a high-availability setup, with multiple Clockwork daemons running on separate machines coordinated using ZooKeeper.

This project interacts with the state stored in ZooKeeper to provide a basic admin UI, allowing you to pause jobs and see when they last ran.
