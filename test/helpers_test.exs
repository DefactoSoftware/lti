defmodule HelpersTest do
  use ExUnit.Case

  alias LTI.{Helpers, LaunchParams, OAuthData}

  describe "#base_string/3" do
    test "returns the base string with given params as arrays" do
      oauth_params = [
        oauth_consumer_key: "key",
        oauth_nonce: "nonce"
      ]

      basestring = Helpers.base_string("http://example.com", oauth_params, [])

      assert basestring ==
               "POST&http%3A%2F%2Fexample.com&oauth_consumer_key%3Dkey%26oauth_nonce%3Dnonce"
    end

    test "returns a base string with OAuthData and LaunchParam structs" do
      oauth_credentials = %OAuthData{
        oauth_callback: "about:blank",
        oauth_consumer_key: "key",
        oauth_version: "1.0",
        oauth_nonce: "nonce",
        oauth_timestamp: "timestamp",
        oauth_signature_method: "HMAC-SHA1"
      }

      valid_launch_params = %LaunchParams{
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

      basestring =
        Helpers.base_string("http://example.com", oauth_credentials, valid_launch_params)

      assert basestring ==
               "POST&http%3A%2F%2Fexample.com&context_id%3D456434513%26launch_presentation_locale%3Den%26launch_presentation_return_url%3Durl%26lis_person_contact_email_primary%3Duser%2540wtf.nl%26lis_person_name_full%3Dwhoot%2520at%2520waaht%26lti_message_type%3Dbasic-lti-launch-request%26lti_version%3DLTI-1p0%26oauth_callback%3Dabout%253Ablank%26oauth_consumer_key%3Dkey%26oauth_nonce%3Dnonce%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3Dtimestamp%26oauth_version%3D1.0%26resource_link_description%3DA%2520weekly%2520blog.%26resource_link_id%3D120988f929-274612%26resource_link_title%3Donno%2520schuit%26roles%3DStudent%26submit%3DLaunch%26tool_consumer_instance_guid%3Dlmsng.school.edu%26user_id%3D1234"
    end

    test "returns an error when not supported" do
      assert_raise ArgumentError, fn ->
        Helpers.base_string("some_url", %{key: "value"}, [])
      end
    end
  end

  describe "#percent_encode/1" do
    test "returns a tuple encoded" do
      encoded_value = Helpers.percent_encode({:user_email, "user@wtf.nl"})

      assert encoded_value == {"user_email", "user%40wtf.nl"}
    end

    test "returns an encoded value" do
      assert Helpers.percent_encode("user@wtf.nl") == "user%40wtf.nl"
    end
  end

  describe "#encode_secret/1" do
    test "returns secret encoded" do
      assert Helpers.encode_secret("secret") == "secret&"
    end
  end
end
