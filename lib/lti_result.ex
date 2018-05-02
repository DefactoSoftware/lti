defmodule LTIResult do
  @moduledoc """
  Module to handle incoming HTTP requests from LTI Providers
  """
  @required_oauth_parameters [
    "oauth_consumer_key",
    "oauth_signature_method",
    "oauth_timestamp",
    "oauth_nonce",
    "oauth_version"
  ]

  @doc """
  Determines a signature using the HTTP method of the request, the url
  of the application's endpoint used by the providers to send the request,
  the oauth parameters used to construct the base string, and the secret of
  the corresponding LTI provider. The parameters are expected to be a list of tuples
  containing a key and corresponding value. The result is a percent encoded signature.

  ## Examples

      iex> LTIResult.signature("post", "https://example.com", "OAuth oauth_consumer_key=\"key1234\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"1525076552\",oauth_nonce=\"123\",oauth_version=\"1.0\",oauth_signature=\"iyyQNRQyXTlpLJPJns3ireWjQxo%3D\"", "random_secret")
      {:ok, "iyyQNRQyXTlpLJPJns3ireWjQxo%3D"}
  """
  def signature(method, url, oauth_header, secret) do
    {parameters, [{"oauth_signature", received_signature}]} =
      extract_header_elements(oauth_header)

    with {:ok, _} <- validate_parameters(parameters) do
      basestring = base_string(method, url, parameters)

      signature =
        :sha
        |> :crypto.hmac(
          percent_encode(secret) <> "&",
          basestring
        )
        |> Base.encode64()
        |> percent_encode()

      if signature == received_signature do
        {:ok, signature}
      else
        {:error, :unmatching_signatures}
      end
    end
  end

  defp extract_header_elements(header) do
    header
    |> String.trim_leading("OAuth ")
    |> String.split(",")
    |> string_to_key_and_value()
    |> trim_elements()
    |> remove_realm_parameter()
    |> extract_signature()
  end

  defp validate_parameters(parameters) do
    {_, state} =
      {parameters, []}
      |> validate_oauth_version()
      |> validate_duplication()
      |> validate_required()
      |> validate_supported()

    case state do
      [] -> {:ok, parameters}
      _ -> {:error, state}
    end
  end

  defp validate_oauth_version({parameters, state}) do
    if List.keyfind(parameters, "oauth_version", 0) == {"oauth_version", "1.0"} do
      {parameters, state}
    else
      {parameters, state ++ [:incorrect_version]}
    end
  end

  defp validate_duplication({parameters, state}) do
    if duplicated_elements?(parameters) do
      {parameters, state ++ [:duplicated_parameters]}
    else
      {parameters, state}
    end
  end

  defp validate_required({parameters, state}) do
    if check_for_required_parameters(parameters) do
      {parameters, state}
    else
      {parameters, state ++ [:missing_required_parameters]}
    end
  end

  defp check_for_required_parameters(parameters) do
    Enum.all?(@required_oauth_parameters, fn required_parameter ->
      required_parameter in Enum.map(parameters, fn {key, _} -> key end)
    end)
  end

  defp validate_supported({parameters, state}) do
    if Enum.all?(parameters, fn {key, _} ->
         String.starts_with?(key, "oauth_")
       end) do
      {parameters, state}
    else
      {parameters, state ++ [:unsupported_parameters]}
    end
  end

  defp duplicated_elements?(parameter_list, state \\ [])
  defp duplicated_elements?([], _), do: false

  defp duplicated_elements?([head | tail], existing_elements) do
    if head in existing_elements do
      true
    else
      duplicated_elements?(tail, existing_elements ++ [head])
    end
  end

  defp base_string(method, url, parameters) do
    query_string =
      parameters
      |> percent_encode_pairs()
      |> Enum.sort()
      |> normalized_string()
      |> percent_encode()

    "#{percent_encode(String.upcase(method))}&#{percent_encode(url)}&" <> query_string
  end

  defp percent_encode_pairs(pairs) do
    Enum.map(pairs, fn {key, value} ->
      {percent_encode(key), percent_encode(value)}
    end)
  end

  defp normalized_string(sorted_pairs) when is_list(sorted_pairs) do
    sorted_pairs
    |> Enum.reduce("", fn {key, value}, acc ->
      acc <> "&" <> "#{key}" <> "=" <> "#{value}"
    end)
    |> String.trim_leading("&")
  end

  defp percent_encode(object) do
    object
    |> to_string()
    |> URI.encode(&URI.char_unreserved?/1)
  end

  defp string_to_key_and_value(key_value_strings) when is_list(key_value_strings) do
    Enum.map(key_value_strings, fn key_value_string ->
      [key, value] = String.split(key_value_string, "=")
      {key, value}
    end)
  end

  defp trim_elements(pairs) when is_list(pairs) do
    Enum.map(pairs, fn {key, value} ->
      {String.trim(key), String.trim(value, "\"")}
    end)
  end

  defp extract_signature(pairs) do
    Enum.split(pairs, -1)
  end

  defp remove_realm_parameter(pairs) when is_list(pairs) do
    List.keydelete(pairs, "realm", 0)
  end
end
