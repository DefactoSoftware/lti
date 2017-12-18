defmodule LtiElixir.OAuthData do
  @moduledoc """
  A struct to define the OAuth credentials to be passed around
  """
  @enforce_keys [
    :oauth_callback,
    :oauth_consumer_key,
    :oauth_version,
    :oauth_nonce,
    :oauth_timestamp,
    :oauth_signature_method
  ]
  defstruct [
    :oauth_callback,
    :oauth_consumer_key,
    :oauth_version,
    :oauth_nonce,
    :oauth_timestamp,
    :oauth_signature_method
  ]
end
