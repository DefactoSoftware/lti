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

  def launch_query(%OAuthData{} = oauth, %LaunchParams{} = launch_params) do
    oauth
    |> launch_data(launch_params)
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      Map.put(acc, key, value)
    end)
    |> Enum.reduce([], fn {key, value}, acc ->
      acc ++ ["#{key}=#{percent_encode(value)}"]
    end)
  end

  def signature(
        %Credentials{secret: secret} = creds,
        %OAuthData{} = oauth_params,
        %LaunchParams{} = launch_params
      ) do
    :sha
    |> :crypto.hmac(
      encode_secret(secret),
      base_string(creds, oauth_params, launch_params)
    )
    |> Base.encode64()
  end

  defp encode_secret(secret) do
    "#{percent_encode(secret)}&"
  end

  defp base_string(%Credentials{url: url}, oauth_params, launch_params) do
    query =
      oauth_params
      |> launch_query(launch_params)
      |> Enum.join("&")
      |> percent_encode()

    "POST&#{percent_encode(url)}&#{query}"
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
      |> strip_nil()

  defp strip_nil(list) do
    Enum.reduce(list, [], fn {_, value} = item, acc ->
      if is_nil(value),
        do: acc,
        else: acc ++ [item]
    end)
  end

  defp nonce do
    24
    |> :crypto.strong_rand_bytes()
    |> Base.encode64()
  end
end
