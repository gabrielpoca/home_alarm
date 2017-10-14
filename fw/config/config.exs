# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Customize the firmware. Uncomment all or parts of the following
# to add files to the root filesystem or modify the firmware
# archive.

# config :nerves, :firmware,
#   rootfs_overlay: "rootfs_overlay",
#   fwup_conf: "config/fwup.conf"

# Use bootloader to start the main application. See the bootloader
# docs for separating out critical OTP applications such as those
# involved with firmware updates.

config :logger, level: :debug

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# Uncomment to use target specific configurations

config :fw, Fw.Perception,
  arp_scan: Fw.Perception.FakeArpScan,
  allowed_mac_addresses: []

config :fw, Fw.Sensor,
  gpio: Fw.Sensor.FakeGPIO

config :fw, Fw.Notifier,
  url: "http://localhost:3000"

config :ui, UiWeb.Endpoint,
  http: [port: 5000],
  url: [host: "localhost", port: 5000],
  secret_key_base: "fAFFYdXUepZm7IWz/RwgaQqcwqtO/5JvWyyAuy5mFpwfGSlJP/9dpS1G58GG8Mn3",
  render_errors: [view: UiWeb.ErrorView, accepts: ~w(html)],
  pubsub: [name: Ui.PubSub, adapter: Phoenix.PubSub.PG2],
  server: true,
  root: Path.dirname(__DIR__)

config :ui, notifier: Fw.Notifier

import_config "#{Mix.env}.exs"
