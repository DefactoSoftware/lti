defmodule LTI do
  @moduledoc """
  A library to launch a LTI request
  """
  alias LTI.{Credentials, Helpers, OAuthData, LaunchParams}

  def credentials(url, key, secret) do
    %Credentials{url: url, key: key, secret: secret}
  end

  def oauth_params(%Credentials{key: key}) do
    %OAuthData{
      oauth_callback: "about:blank",
      oauth_consumer_key: key,
      oauth_version: "1.0",
      oauth_nonce: Helpers.nonce(),
      oauth_timestamp: Helpers.timestamp(),
      oauth_signature_method: "HMAC-SHA1"
    }
  end

  def signature(
        %Credentials{secret: secret, url: url},
        %OAuthData{} = oauth_params,
        %LaunchParams{} = launch_params
      ) do
    :sha
    |> :crypto.hmac(
      Helpers.encode_secret(secret),
      Helpers.base_string(url, oauth_params, launch_params)
    )
    |> Base.encode64()
  end
end
