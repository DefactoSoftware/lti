defmodule LTIResult do
  @moduledoc """
  Module to handle incoming HTTP requests from LTI Providers
  """

  @doc """
  Determines a signature using the HTTP method of the request, the url
  of the application's endpoint used by the providers to send the request,
  the oauth parameters used to construct the base string, and the secret of
  the corresponding LTI provider. The parameters are expected to be a list of tuples
  containing a key and corresponding value. The result is a percent encoded signature.

  ## Examples

      iex> signature("post",
      "https://example.com",
      [{"oauth_consumer_key", "key1234"},
      {"oauth_signature_method", "HMAC-SHA1"},
      {"oauth_timestamp", "1525076552"},
      {"oauth_nonce", "123"},
      {"oauth_version", "1.0"}],
      "random_secret")
      {:ok, "iyyQNRQyXTlpLJPJns3ireWjQxo%3D"}
  """
  def signature(method, url, parameters, secret) do
    basestring = base_string(method, url, parameters)

    signature =
      :sha
      |> :crypto.hmac(
        percent_encode(secret) <> "&",
        basestring
      )
      |> Base.encode64()

    {:ok, percent_encode(signature)}
  end

  defp base_string(method, url, parameters) do
    query_string =
      parameters
      |> encode()
      |> Enum.sort()
      |> normalized_string()
      |> percent_encode()

    "#{percent_encode(String.upcase(method))}&#{percent_encode(url)}&" <> query_string
  end

  defp encode(parameters) do
    Enum.map(parameters, fn {key, value} ->
      {percent_encode(key), percent_encode(value)}
    end)
  end

  defp normalized_string(sorted_elements) do
    String.trim_leading(
      Enum.reduce(sorted_elements, "", fn {key, value}, acc ->
        acc <> "&" <> "#{key}" <> "=" <> "#{value}"
      end),
      "&"
    )
  end

  defp percent_encode(other) do
    other
    |> to_string()
    |> URI.encode(&URI.char_unreserved?/1)
  end
end
