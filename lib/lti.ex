defmodule LTI do
  @moduledoc """
  A library to launch a LTI request
  """
  alias LTI.{Credentials, OAuthData, LaunchParams}

  def credentials(url, key, secret) do
    %Credentials{url: url, key: key, secret: secret}
  end

  def oauth_params(%Credentials{key: key}) do
    %OAuthData{
      oauth_callback: "about:blank",
      oauth_consumer_key: key,
      oauth_version: "1.0",
      oauth_nonce: nonce(),
      oauth_timestamp: timestamp(),
      oauth_signature_method: "HMAC-SHA1"
    }
  end

  def launch_data(%OAuthData{} = oauth, %LaunchParams{} = launch_params) do
    struct_to_list(launch_params) ++ struct_to_list(oauth)
  end

  def signature(
        %Credentials{secret: secret} = creds,
        %OAuthData{} = oauth_params,
        %LaunchParams{} = launch_params
      ) do
    :sha
    |> hmac_fun(
      encode_secret(secret),
      base_string(creds, oauth_params, launch_params)
    )
    |> Base.encode64()
  end

  defp encode_secret(secret) do
    "#{percent_encode(secret)}&"
  end

  defp base_string(%Credentials{url: url}, oauth_params, launch_params) do
    {normalized_url, query} = normalize(url)
    query_params = to_query_params(query)

    query =
      oauth_params
      |> launch_query(launch_params, query_params)
      |> Enum.join("&")
      |> percent_encode()

    "POST&#{percent_encode(normalized_url)}&#{query}"
  end

  def launch_query(%OAuthData{} = oauth, %LaunchParams{} = launch_params, query_string_params) do
    parameters = launch_data(oauth, launch_params) ++ query_string_params

    parameters
    |> Enum.map(fn {key, value} -> "#{key}=#{percent_encode(value)}" end)
    |> Enum.sort()
  end

  def downcase_scheme_and_host(%URI{scheme: scheme, host: host} = uri),
    do: %URI{uri | scheme: String.downcase(scheme), host: String.downcase(host)}

  defp normalize(url) do
    url
    |> URI.parse()
    |> downcase_scheme_and_host()
    |> split_query_params()
  end

  defp split_query_params(%URI{query: query} = uri),
    do: {URI.to_string(%URI{uri | query: nil}), query}

  defp to_query_params(nil), do: []

  defp to_query_params(query) do
    query
    |> String.split("&")
    |> Enum.map(&to_pairs/1)
    |> Enum.into([])
  end

  defp to_pairs(pair) do
    pair
    |> String.split("=")
    |> get_pairs
  end

  defp get_pairs([key | values]) do
    {key, Enum.join(values, "=")}
  end

  defp timestamp do
    {megasec, sec, _mcs} = :os.timestamp()
    "#{megasec * 1_000_000 + sec}"
  end

  defp percent_encode({key, value}) do
    {percent_encode(key), percent_encode(value)}
  end

  defp percent_encode(other) do
    other
    |> to_string()
    |> URI.encode(&URI.char_unreserved?/1)
  end

  defp struct_to_list(struct),
    do:
      struct
      |> Map.from_struct()
      |> Map.to_list()
      |> Enum.reject(fn {_, v} -> is_nil(v) end)

  defp nonce do
    24
    |> :crypto.strong_rand_bytes()
    |> Base.encode64()
  end

  if Code.ensure_loaded?(:crypto) and function_exported?(:crypto, :mac, 4) do
    def hmac_fun(digest, key, data), do: :crypto.mac(:hmac, digest, key, data)
  else
    def hmac_fun(digest, key, data), do: :crypto.hmac(digest, key, data)
  end
end
