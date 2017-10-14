use Mix.Config

config :ui, UiWeb.Endpoint,
  http: [port: 80],
  url: [host: "localhost", port: 80],
  secret_key_base: System.get_env("SECRET_KEY_BASE")

config :nerves_network,
  regulatory_domain: "PT"

config :nerves_network, :default,
  wlan0: [
    ssid: System.get_env("NERVES_NETWORK_SSID"),
    psk: System.get_env("NERVES_NETWORK_PSK"),
    key_mgmt: :"WPA-PSK"
  ],
  eth0: [
    ipv4_address_method: :dhcp
  ]

config :nerves_firmware_ssh,
  authorized_keys: [
    File.read!(Path.join(System.user_home!, ".ssh/id_rsa.pub"))
  ]

config :fw, Fw.Sensor,
  gpio: Fw.Sensor.GPIO

config :fw, Fw.Perception,
  arp_scan: Fw.Perception.ArpScan,
  allowed_mac_addresses: []

config :bootloader,
  init: [:nerves_runtime, :nerves_network],
  app: :fw

import_config "prod.secrets.exs"
