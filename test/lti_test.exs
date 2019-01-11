defmodule LTITest do
  use ExUnit.Case
  doctest LTI

  alias LTI.{Credentials, LaunchParams, OAuthData}

  @credentials %Credentials{url: "https://exmaple.com", secret: "secret", key: "key"}
  @credentials_with_query_string %Credentials{
    url: "https://exmaple.com?course=course1&subcourse=subcourse1",
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

  @valid_launch_params %LaunchParams{
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
    submit: "Launch",
    tool_consumer_instance_guid: "lmsng.school.edu",
    user_id: 1234
  }

  test "signature/3 encodes all the variables " do
    assert LTI.signature(@credentials, @oauth_credentials, @valid_launch_params) ==
             "FmlHij11a+wcY4XPmjyRrPGNELg="
  end

  test "signature/3 with url with query string parameters" do
    assert LTI.signature(@credentials_with_query_string, @oauth_credentials, @valid_launch_params) ==
             "+mKFClgWnaHtsQByWMRCFxR8P44="
  end

  test "oauth_params/1 should always be different" do
    refute LTI.oauth_params(@credentials) == LTI.oauth_params(@credentials)
  end
end
