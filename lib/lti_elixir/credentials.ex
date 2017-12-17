defmodule LtiElixir.Credentials do
  @enforce_keys [:url, :secret, :key]
  defstruct [:url, :secret, :key]
end
