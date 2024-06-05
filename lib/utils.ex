defmodule Utils do
  @charset "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

  def generateRandomString(n) when n > 0 do
    @charset
    |> String.split("", trim: true)
    |> Enum.take_random(n)
    |> Enum.join()
  end
end
