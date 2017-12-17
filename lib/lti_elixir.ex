defmodule LtiElixir do
  @moduledoc """
  A library to launch a LTI request
  """
  alias LtiElixir.Credentials

  def credentials(url, key, secret) do
    %Credentials{url: url, key: key, secret: secret}
  end

  def oauth_params(%Credentials{key: key}) do
    [
      lti_version: "LTI-1p0",
      lti_message_type: "basic-lti-launch-request",
      oauth_callback: "about:blank",
      oauth_consumer_key: key,
      oauth_version: "1.0",
      oauth_nonce: "11111111111",
      oauth_timestamp: timestamp(),
      oauth_signature_method: "HMAC-SHA1"
    ] ++ extra_data()
  end

  def extra_data do
    [
      user_id: "292832126",
      roles: "Instructor",
      resource_link_id: "120988f929-274612",
      resource_link_title: "onno schuit",
      resource_link_description: "A weekly blog.",
      lis_person_name_full: "Jane Q. Public",
      lis_person_name_family: "Public",
      lis_person_name_given: "Given",
      lis_person_contact_email_primary: "user@school.edu",
      lis_person_sourcedid: "school.edu:user",
      context_id: "456434513",
      context_title: "Design of Personal Environments",
      context_label: "SI182",
      tool_consumer_instance_guid: "lmsng.school.edu",
      tool_consumer_instance_description: "University of School (LMSng)",
      submit: "Launch"
    ]
  end

  def launch_params(params) do
    launch_data = Enum.reduce(params, %{}, fn({key, value}, acc) ->
      Map.put(acc, key,  value)
    end)

    Enum.reduce(launch_data, [], fn({key, value}, acc) ->
      acc ++ ["#{key}=#{percent_encode(value)}"]
    end)
  end

  def signature(%Credentials{secret: secret} = creds) do
    :sha
    |> :crypto.hmac(encode_secret(secret), base_string(creds))
    |> Base.encode64()
  end

  defp encode_secret(secret) do
    "#{percent_encode(secret)}&"
  end

  defp base_string(%Credentials{url: url} = creds) do
    query =  creds
             |> oauth_params()
             |> launch_params()
             |> Enum.join("&")
             |> percent_encode()
    "POST&#{percent_encode(url)}&#{query}"
  end

  defp timestamp do
    {megasec, sec, _mcs} = :os.timestamp
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
end
