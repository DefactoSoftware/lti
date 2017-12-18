defmodule LTITest do
  use ExUnit.Case
  doctest LTI

  alias LTI.{Credentials, LaunchParams}

  @valid_launch_params %LaunchParams{
    context_id: "28938320",
    launch_presentation_locale: "en",
    launch_presentation_return_url: "example.com",
    lti_message_type: "basic-lti-launch-request",
    lti_version: "LTI-1p0",
    resource_link_id: "our_id",
    roles: "student",
    tool_consumer_instance_guid: "",
    user_id: "1"
  }

  test "launch_data/2 contains all needed params" do
    creds = %Credentials{url: "exmaple.com", secret: "secret", key: "key"}
    oauth_params = LTI.oauth_params(creds)
    LTI.launch_data(oauth_params, @valid_launch_params)
  end
end
