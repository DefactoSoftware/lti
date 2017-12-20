defmodule LTITest do
  use ExUnit.Case
  doctest LTI

  alias LTI.{Credentials, LaunchParams}

  @valid_launch_params %LTI.LaunchParams{
    context_id: "456434513",
    launch_presentation_locale: "en",
    launch_presentation_return_url: "url",
    lis_person_contact_email_primary: "user@wtf.nl",
    lis_person_name_full: "whoot at waaht",
    resource_link_description: "A weekly blog.",
    resource_link_id: "120988f929-274612",
    resource_link_title: "onno schuit",
    roles: "Student",
    tool_consumer_instance_guid: "lmsng.school.edu",
    user_id: 1234,
    submit: "Launch"
  }

  test "launch_data/2 contains all needed params" do
    creds = %Credentials{url: "exmaple.com", secret: "secret", key: "key"}
    oauth_params = LTI.oauth_params(creds)
    launch_data = LTI.launch_data(oauth_params, @valid_launch_params)
    assert "roles=student" in launch_data
    assert "oauth_signature_method=HMAC-SHA1" in launch_data
  end
end
