defmodule LtiElixir.Credentials do
  @moduledoc """
  A struct to define the elements that are needed to process most functions
  """

  @enforce_keys [:url, :secret, :key]
  defstruct [:url, :secret, :key]
end
