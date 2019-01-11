defmodule OAuthTest do
  use ExUnit.Case

  import Mock

  alias LTI
  alias LTI.{Credentials, Helpers, LaunchParams, OAuth, OAuthData}

  @credentials %Credentials{url: "https://exmaple.com", secret: "secret", key: "key"}

  @oauth_credentials %OAuthData{
    oauth_callback: "about:blank",
    oauth_consumer_key: "key",
    oauth_version: "1.0",
    oauth_nonce: "some_nonce",
    oauth_timestamp: 1_029_382,
    oauth_signature_method: "HMAC-SHA1"
  }

  @valid_launch_params %LaunchParams{
    context_id: "456434513",
    launch_presentation_locale: "en",
    launch_presentation_return_url: "https://exmaple.com",
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

  describe "#oauth_verification/5" do
    setup do
      signature = LTI.signature(@credentials, @oauth_credentials, @valid_launch_params)

      {:ok, signature: signature}
    end

    test "returns success when signatures match", %{signature: signature} do
      assert OAuth.oauth_verification(
               "secret",
               "https://exmaple.com",
               @oauth_credentials,
               @valid_launch_params,
               signature
             ) == {:ok, :oauth_successful}
    end

    test "returns error when signatures do not match", %{signature: signature} do
      assert OAuth.oauth_verification(
               "secret",
               "random_url",
               @oauth_credentials,
               @valid_launch_params,
               signature
             ) == {:error, :signatures_not_matching}
    end
  end

  describe "#generate_oauth_header/2" do
    setup_with_mocks [
      {Helpers, [:passthrough], nonce: fn -> "some_nonce" end},
      {Helpers, [:passthrough], timestamp: fn -> 1_029_382 end}
    ] do
      :ok
    end

    test "returns the OAuth header" do
      oauth_header = OAuth.generate_oauth_header("https://exmaple.com", @credentials)

      assert oauth_header ==
               "OAuth oauth_consumer_key=\"key\", oauth_nonce=\"some_nonce\", oauth_signature_method=\"HMAC-SHA1\", oauth_version=\"1.0\", oauth_timestamp=\"1029382\", oauth_signature=\"skUfHD74wpsM9UyCWHrg%2BR1HHWo%3D\""
    end
  end
end
