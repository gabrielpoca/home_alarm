use Mix.Config

config :fw, Fw.Sensor,
  gpio: Fw.Sensor.TestGPIO

config :fw, Fw.Perception,
  arp_scan: Fw.Perception.FakeArpScan,
  allowed_mac_addresses: ["1:1:1:1"]
