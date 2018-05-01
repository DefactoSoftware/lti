defmodule LTIResult do
  @moduledoc """
  Module to handle incoming HTTP requests from LTI Providers
  """
  @required_parameters [
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
  def signature(method, url, oauth_header, secret) do
    {parameters, received_signature} =
      oauth_header
      |> String.trim_leading("OAuth ")
      |> String.split(",")
      |> to_key_value()
      |> trim_values()
      |> remove_realm()
      |> extract_signature()

    with {:ok, _} <- validate_parameters(parameters) do
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
    cond do
      List.keyfind(parameters, "oauth_version", 0) == {"oauth_version", "1.0"} ->
        {parameters, state}

      true ->
        {parameters, state ++ [:incorrect_version]}
    end
  end

  defp validate_duplication({parameters, state}) do
    cond do
      duplicated_elements?(parameters) ->
        {parameters, state ++ [:duplicated_parameters]}

      true ->
        {parameters, state}
    end
  end

  defp duplicated_elements?([], _), do: false

  defp duplicated_elements?([head | tail], existing_elements \\ []) do
    if head in existing_elements do
      true
    else
      duplicated_elements?(tail, existing_elements ++ [head])
    end
  end

  defp validate_required({parameters, state}) do
    cond do
      Enum.all?(@required_parameters, fn required_parameter ->
        required_parameter in Enum.map(parameters, fn {key, _} -> key end)
      end) ->
        {parameters, state}

      true ->
        {parameters, state ++ [:missing_required_parameters]}
    end
  end

  defp validate_supported({parameters, state}) do
    cond do
      Enum.all?(parameters, fn {key, _} ->
        String.starts_with?(key, "oauth_")
      end) ->
        {parameters, state}

      true ->
        {parameters, state ++ [:unsupported_parameters]}
    end
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
    sorted_elements
    |> Enum.reduce("", fn {key, value}, acc ->
      acc <> "&" <> "#{key}" <> "=" <> "#{value}"
    end)
    |> String.trim_leading("&")
  end

  defp percent_encode(other) do
    other
    |> to_string()
    |> URI.encode(&URI.char_unreserved?/1)
  end

  defp to_key_value(key_value_list) do
    Enum.map(key_value_list, fn key_value ->
      [key, value] = String.split(key_value, "=")
      {key, value}
    end)
  end

  defp trim_values(pairs) do
    Enum.map(pairs, fn {key, value} ->
      trimmed_key = String.trim(key)
      trimmed_value = String.trim(value, "\"")
      {trimmed_key, trimmed_value}
    end)
  end

  defp extract_signature(key_value_pairs) do
    {parameters, their_signature} = Enum.split(key_value_pairs, -1)
  end

  defp remove_realm(key_value_pairs) do
    List.keydelete(parameters, "realm", 0)
  end
end
