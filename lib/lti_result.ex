defmodule LTIResult do
  @moduledoc """
  Module to handle incoming HTTP requests from LTI Providers
  """

  @doc """
  Determines a signature using the HTTP method of the request, the url
  of the application's endpoint used by the providers to send the request,
  the oauth parameters used to construct the base string, and the secret of
  the corresponding LTI provider. The parameters are expected to be a list of tuples
  containing a key and corresponding value.

  ## Examples

      iex> signature("POST",
                     "https://example.com",
                     [{"key_1", "value_1"}, {"key_2", "value_2"}],
                     "stored_secret")
      {:ok, "b1ZRZdHX7947RtX1jbvdZ0Ibmlg"}
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

    {:ok, signature}
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
