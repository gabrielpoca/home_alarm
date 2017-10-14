defmodule Fw.Sensor.GPIO do
  alias ElixirALE.GPIO

  def start_link(pin, direction) do
    GPIO.start_link(pin, direction)
  end

  def set_int(pid, direction) do
    GPIO.set_int(pid, direction)
  end
end
