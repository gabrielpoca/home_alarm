defmodule Fw.Mixfile do
  use Mix.Project

  @target System.get_env("MIX_TARGET") || "host"

  Mix.shell.info([:green, """
  Mix environment
    MIX_TARGET:   #{@target}
    MIX_ENV:      #{Mix.env}
  """, :reset])

  def project do
    [app: :fw,
     version: "0.1.0",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(@target),
     target: @target,
     archives: [nerves_bootstrap: "~> 0.6"],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(@target),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application, do: application(@target)

  # Specify target specific application configurations
  # It is common that the application start function will start and supervise
  # applications which could cause the host to fail. Because of this, we only
  # invoke Fw.start/2 when running on a target.
  def application("host") do
    [mod: {Fw.Application, []},
     #applications: [:retry, :httpotion],
     extra_applications: [:logger]]
  end
  def application(_target) do
    [mod: {Fw.Application, []},
     #applications: [:retry, :httpotion],
     extra_applications: [:logger]]
  end

  defp elixirc_paths("custom_rpi"), do: ["lib", "rpi_lib"]
  defp elixirc_paths(_), do: ["lib"]

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  def deps do
    [
      {:gen_stage, "~> 0.12"},
      {:nerves, "~> 0.7", runtime: false},
      {:retry, "~> 0.8"},
      {:httpotion, "~> 3.0.2"},
      {:timex, "~> 3.1"}
    ] ++
    deps(@target)
  end

  # Specify target specific dependencies
  def deps("host"), do: [{:ui, path: "../ui"}]
  def deps(target) do
    [
      {:ui, path: "../ui"},
      {:bootloader, "~> 0.1"},
      {:elixir_ale, "~> 1.0"},
      {:nerves_firmware_ssh, github: "fhunleth/nerves_firmware_ssh"},
      {:nerves_network, "~> 0.3"},
      {:nerves_runtime, "~> 0.4"}
    ] ++ system(target)
  end

  def system("custom_rpi"), do: [{:custom_rpi, path: "../custom_rpi", runtime: false}]
  def system("rpi"), do: [{:nerves_system_rpi, ">= 0.0.0", runtime: false}]
  def system("rpi0"), do: [{:nerves_system_rpi0, ">= 0.0.0", runtime: false}]
  def system("rpi2"), do: [{:nerves_system_rpi2, ">= 0.0.0", runtime: false}]
  def system("rpi3"), do: [{:nerves_system_rpi3, ">= 0.0.0", runtime: false}]
  def system("bbb"), do: [{:nerves_system_bbb, ">= 0.0.0", runtime: false}]
  def system("linkit"), do: [{:nerves_system_linkit, ">= 0.0.0", runtime: false}]
  def system("ev3"), do: [{:nerves_system_ev3, ">= 0.0.0", runtime: false}]
  def system("qemu_arm"), do: [{:nerves_system_qemu_arm, ">= 0.0.0", runtime: false}]
  def system(target), do: Mix.raise "Unknown MIX_TARGET: #{target}"

  # We do not invoke the Nerves Env when running on the Host
  def aliases("host"), do: [
    test: "test --no-start"
  ]
  def aliases(_target) do
    ["deps.precompile": ["nerves.precompile", "deps.precompile"],
     "deps.loadpaths":  ["deps.loadpaths", "nerves.loadpaths"]]
  end

end
