defmodule LTI.Helpers do
  @moduledoc """
  A module for helper functions that are used for the OAuth params
  """

  alias LTI.{Credentials, LaunchParams, OAuthData}

  def base_string(url, %OAuthData{} = oauth_params, %LaunchParams{} = launch_params) do
    params = launch_data(oauth_params, launch_params)
    base_string(url, params)
  end

  def base_string(url, oauth_params, launch_params) do
    params = oauth_params ++ launch_params
    base_string(url, params)
  end

  def percent_encode({key, value}) do
    {percent_encode(key), percent_encode(value)}
  end

  def percent_encode(other) do
    other
    |> to_string()
    |> URI.encode(&URI.char_unreserved?/1)
  end

  def nonce do
    24
    |> :crypto.strong_rand_bytes()
    |> Base.encode64()
  end

  def timestamp do
    {megasec, sec, _mcs} = :os.timestamp()
    "#{megasec * 1_000_000 + sec}"
  end

  def encode_secret(secret) do
    "#{percent_encode(secret)}&"
  end

  defp base_string(url, params) do
    {normalized_url, query} = parse_url(url)
    query_params = to_query_params(query)

    query =
      (params ++ query_params)
      |> launch_query()
      |> Enum.join("&")
      |> percent_encode()

    "POST&#{percent_encode(normalized_url)}&#{query}"
  end

  defp launch_query(parameters) do
    parameters
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      Map.put(acc, key, value)
    end)
    |> Enum.reduce([], fn {key, value}, acc ->
      acc ++ ["#{key}=#{percent_encode(value)}"]
    end)
  end

  defp to_query_params(nil), do: []

  defp to_query_params(query) do
    query
    |> String.split("&")
    |> Enum.map(fn pair ->
      [key, value] = String.split(pair, "=")
      {String.to_atom(key), value}
    end)
    |> Keyword.new()
  end

  defp launch_data(%OAuthData{} = oauth, %LaunchParams{} = launch_params) do
    struct_to_list(launch_params) ++ struct_to_list(oauth)
  end

  defp parse_url(url) do
    %URI{scheme: scheme, authority: authority, path: path, query: query} = URI.parse(url)
    normalized_url = "#{scheme}://#{authority}#{path}"
    {normalized_url, query}
  end

  defp struct_to_list(struct),
    do:
      struct
      |> Map.from_struct()
      |> Map.to_list()
      |> strip_nil()

  defp strip_nil(list) do
    Enum.reduce(list, [], fn {_, value} = item, acc ->
      if is_nil(value),
        do: acc,
        else: acc ++ [item]
    end)
  end
end
