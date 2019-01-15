defmodule LTI.OAuth do
  @moduledoc """
  Module containing functions to determine and compare oauth 1.0 signatures.
  """
  alias LTI.{Credentials, Helpers}

  def oauth_verification(secret, url, oauth_params, regular_params, signature) do
    with basestring <- Helpers.base_string(url, oauth_params, regular_params),
         {:ok, calculated_signature} <- signature(secret, basestring) do
      if calculated_signature == signature do
        {:ok, :oauth_successful}
      else
        {:error, :signatures_not_matching}
      end
    end
  end

  def generate_oauth_header(lis_outcome_service_url, %Credentials{key: key, secret: secret}) do
    nonce = Helpers.nonce()
    timestamp = Helpers.timestamp()

    oauth_params = [
      oauth_consumer_key: key,
      oauth_nonce: nonce,
      oauth_signature_method: "HMAC-SHA1",
      oauth_version: "1.0",
      oauth_timestamp: timestamp
    ]

    basestring = Helpers.base_string(lis_outcome_service_url, oauth_params, [])
    {:ok, calculated_signature} = signature(secret, basestring)

    ~s(OAuth oauth_consumer_key="#{key}", oauth_nonce="#{Helpers.percent_encode(nonce)}", oauth_signature_method="HMAC-SHA1", oauth_version="1.0", oauth_timestamp="#{
      timestamp
    }", oauth_signature="#{Helpers.percent_encode(calculated_signature)}")
  end

  defp signature(secret, basestring) do
    signature =
      :sha
      |> :crypto.hmac(
        Helpers.encode_secret(secret),
        basestring
      )
      |> Base.encode64()

    {:ok, signature}
  end
end
