defmodule LTITest do
  use ExUnit.Case
  doctest LTI

  alias LTI.{Credentials, OAuthData}

  @credentials %Credentials{url: "https://example.com", secret: "secret", key: "key"}
  @credentials_with_query_string %Credentials{
    url: "https://example.com?course=course1&subcourse=subcourse1",
    secret: "secret",
    key: "key"
  }
  @credentials_with_nested_query_string %Credentials{
    url: "https://example.com?course=course1&redirect_uri=https://example.com/index.html?page=5",
    secret: "secret",
    key: "key"
  }
  @credentials_with_capitalized_url %Credentials{
    url: "https://ExamPle.com",
    secret: "secret",
    key: "key"
  }

  @oauth_credentials %OAuthData{
    oauth_callback: "about:blank",
    oauth_consumer_key: "key",
    oauth_version: "1.0",
    oauth_nonce: "nonce",
    oauth_timestamp: "timestamp",
    oauth_signature_method: "HMAC-SHA1"
  }

  @valid_launch_params %LTI.LaunchParams{
    context_id: "456434513",
    launch_presentation_locale: "en",
    launch_presentation_return_url: "url",
    lis_person_contact_email_primary: "user@wtf.nl",
    lis_person_name_full: "whoot at waaht",
    lti_message_type: "basic-lti-launch-request",
    lti_version: "LTI-1p0",
    resource_link_description: "A weekly blog.",
    resource_link_id: "120988f929-274612",
    resource_link_title: "onno schuit",
    roles: "Student",
    tool_consumer_instance_guid: "lmsng.school.edu",
    user_id: 1234
  }

  test "launch_data/2 contains all needed params" do
    oauth_params = LTI.oauth_params(@credentials)
    launch_data = LTI.launch_query(oauth_params, @valid_launch_params, [])

    assert "roles=Student" in launch_data
    assert "oauth_signature_method=HMAC-SHA1" in launch_data
  end

  test "signature/3 encodes all the variables" do
    assert LTI.signature(@credentials, @oauth_credentials, @valid_launch_params) ==
             "NgK2X7WQb+CwHikcJMjqnJTsSBk="
  end

  test "signature/3 encodes all the variables, with url with capitals" do
    assert LTI.signature(
             @credentials_with_capitalized_url,
             @oauth_credentials,
             @valid_launch_params
           ) ==
             "NgK2X7WQb+CwHikcJMjqnJTsSBk="
  end

  test "signature/3 with url with query string parameters" do
    assert LTI.signature(@credentials_with_query_string, @oauth_credentials, @valid_launch_params) ==
             "68JVqL7aRC1meflszD8p+onIvWI="
  end

  test "signature/3 with url with query string with nested query parameters" do
    assert LTI.signature(
             @credentials_with_nested_query_string,
             @oauth_credentials,
             @valid_launch_params
           ) == "f/DC8AEzcDcMUPs07nc0tPG8/CM="
  end

  test "oauth_params/1 should always be different" do
    refute LTI.oauth_params(@credentials) == LTI.oauth_params(@credentials)
  end
end
