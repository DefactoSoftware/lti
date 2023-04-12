defmodule LTITest do
  use ExUnit.Case
  doctest LTI

  alias LTI.{Credentials, OAuthData}

  @credentials %Credentials{
    url:
      "https://resultlaboratorium.cappagile.com/lti/paths/01c04e05-e6ad-48e0-87df-90f1df4b0e6f",
    key: "ASz LTI agile"
  }
  # url: "https://example.com/lti", secret: "secret", key: "key"}
  @credentials_with_query_string %Credentials{
    url: "https://example.com/lti?course=course1&subcourse=subcourse1",
    secret: "secret",
    key: "key"
  }
  @credentials_with_nested_query_string %Credentials{
    url:
      "https://example.com/lti?course=course1&redirect_uri=https://example.com/index.html?page=5",
    secret: "secret",
    key: "key"
  }
  @credentials_with_capitalized_url %Credentials{
    url: "https://ExamPle.com/LTI",
    secret: "secret",
    key: "key"
  }

  @oauth_credentials %OAuthData{
    oauth_callback: "about:blank",
    oauth_consumer_key: "ASz LTI agile",
    oauth_nonce: "d3cf6b7f-3749-4b12-a363-0b8431a35009",
    oauth_signature_method: "HMAC-SHA1",
    oauth_timestamp: "1680859018",
    oauth_version: "1.0"
    # oauth_callback: "about:blank",
    # oauth_consumer_key: "key",
    # oauth_version: "1.0",
    # oauth_nonce: "nonce",
    # oauth_timestamp: "timestamp",
    # oauth_signature_method: "HMAC-SHA1"
  }

  @valid_launch_params %LTI.LaunchParams{
    context_id: "",
    context_label: "",
    context_title: "",
    context_type: "",
    launch_presentation_css_url: "",
    launch_presentation_document_target: "iframe",
    launch_presentation_height: "",
    launch_presentation_locale: "",
    launch_presentation_return_url: "",
    launch_presentation_width: "",
    lis_outcome_service_url: "https://ltip.lmshost.nl/LTIP/OutcomeService",
    lis_person_contact_email_primary: "vanwel@courseware.nl",
    lis_person_name_family: "(DO NOT REMOVE)",
    lis_person_name_full: "LTIP Test-User (DO NOT REMOVE)",
    lis_person_name_given: "LTIP Test-User",
    lis_result_sourcedid:
      "MTliZWM1MmItNzcyMC00NmMxLThmYzgtMDkxMWU1YjJmOGEzDQpFTE81OTUxDQpsdGlwLXRlc3QNCg==",
    lti_message_type: "basic-lti-launch-request",
    lti_version: "LTI-1p0",
    resource_link_description: "",
    resource_link_id: "ELO5951",
    resource_link_title: "Bloedglucose bepaling",
    role_scope_mentor: "",
    roles: "",
    tool_consumer_info_product_family_code: "LTIP",
    tool_consumer_info_version: "18.1",
    tool_consumer_instance_contact_email: "support@courseware.nl",
    tool_consumer_instance_description: "LTIP",
    tool_consumer_instance_guid: "ltip.lmshost.nl",
    tool_consumer_instance_name: "LTIP01",
    tool_consumer_instance_url: "https://ltip.lmshost.nl",
    user_id: "ltip-test",
    user_image: ""
  }

  # %LTI.LaunchParams{
  #   context_id: "456434513",
  #   launch_presentation_locale: "en",
  #   launch_presentation_return_url: "url",
  #   lis_person_contact_email_primary: "user@wtf.nl",
  #   lis_person_name_full: "whoot at waaht",
  #   lti_message_type: "basic-lti-launch-request",
  #   lti_version: "LTI-1p0",
  #   resource_link_description: "A weekly blog.",
  #   resource_link_id: "120988f929-274612",
  #   resource_link_title: "onno schuit",
  #   roles: "Student",
  #   tool_consumer_instance_guid: "lmsng.school.edu",
  #   user_id: 1234
  # }

  test "launch_data/2 contains all needed params" do
    oauth_params = LTI.oauth_params(@credentials)
    launch_data = LTI.launch_query(oauth_params, @valid_launch_params, [])

    assert "roles=Student" in launch_data
    assert "oauth_signature_method=HMAC-SHA1" in launch_data
  end

  test "signature/3 encodes all the variables" do
    assert LTI.signature(@credentials, @oauth_credentials, @valid_launch_params) |> IO.inspect() ==
             "eedGFJ27nJI9UnhNzymqWI3SuHo="

    #  "oZ+tKsx1XXcv6T7TEkgh9Z98iKQ="
  end

  test "signature/3 encodes all the variables, with url with capitals" do
    assert LTI.signature(
             @credentials_with_capitalized_url,
             @oauth_credentials,
             @valid_launch_params
           ) ==
             "847zmolnYszuzzIS5T1OFNpQST0="
  end

  test "signature/3 with url with query string parameters" do
    assert LTI.signature(@credentials_with_query_string, @oauth_credentials, @valid_launch_params) ==
             "qAabG+64siAP8WUeK8ulvE9+9dA="
  end

  test "signature/3 with url with query string with nested query parameters" do
    assert LTI.signature(
             @credentials_with_nested_query_string,
             @oauth_credentials,
             @valid_launch_params
           ) == "zKnEO+SDt++bRcZdFu0ef5H2H8M="
  end

  test "oauth_params/1 should always be different" do
    refute LTI.oauth_params(@credentials) == LTI.oauth_params(@credentials)
  end
end
