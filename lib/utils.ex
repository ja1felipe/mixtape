defmodule Utils do
  def generate_random_string(length) do
    possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

    values =
      :crypto.strong_rand_bytes(length)
      |> :binary.bin_to_list()

    Enum.reduce(values, "", fn x, acc ->
      acc <> String.at(possible, rem(x, String.length(possible)))
    end)
  end

  def sha256(plain) do
    :crypto.hash(:sha256, plain)
  end

  def base64encode(input) do
    input
    |> Base.encode64()
    |> String.replace("+", "-")
    |> String.replace("/", "_")
    |> String.replace(~r/=+$/, "")
    |> String.trim()
  end
end
