# LTI for elixir

A package to easily launch LTI modules.

## Installation

add

```ex
def deps do
  [
    {:lti, "~> 0.1.2"}
  ]
end
```

## Usage LTI Launch

```eex
# in the template
<%
credentials = LTI.credentials(your_given_consumer_key, your_given_consumer_secret, your_lti_url)
oauth_params = LTI.oauth_params(credentials)
launch_params = launch_params(@current_user)
%>

<form id="ltiLaunchForm" name="ltiLaunchForm" method="POST" action="<%= your_lti_url %>">
  <%= for ({key, value} <- LTI.launch_data(oauth_params, launch_params)) do %>
    <input type="hidden" name="<%= key %>" value="<%= value %>">
  <% end %>
  <input type="hidden" name="oauth_signature" value="<%= LTI.signature(credentials, oauth_params, launch_params) %>">
	<button type="submit">Launch</button>
  <br>
</form>
```

```ex
  # in the view

  def launch_params(user) do
    %LTI.LaunchParams{
      user_id: "292832126",
      roles: the_role_of_the_user,
      launch_presentation_locale: users_language,
      launch_presentation_return_url: callback_url_for_results,
      resource_link_id: resource_link_id_of_your_module,
      resource_link_title: "onno schuit",
      resource_link_description: "A weekly blog.",
      lis_person_contact_email_primary: user.email,
      lis_person_name_family: "Public",
      lis_person_name_full: Accounts.full_name(user),
      lis_person_name_given: "Given",
      lis_person_sourcedid: your_person_source_id,
      lti_message_type: "basic-lti-launch-request",
      lti_version: "LTI-1p0",
      context_id: context_id_of_your_module,
      context_title: title_of_the_module,
      context_label: label_of_the_module,
      tool_consumer_instance_guid: tool_consumer_instance_guid,
      tool_consumer_instance_description: "some description of yours instance",
      submit: "Launch"
    }
  end
```

## Usage LTI Receive
Verify the received signature by passing the url, oauth header and secret.
This function will either return an :ok tuple together with the verified signature or
an :error tuple with a list with one or more of the error atoms (:unmatching_signatures, :incorrect_version, :duplicated_parameters, :missing_required_parameters or :unsupported_parameters)
By default, the HTTP method is POST.

```ex
  {:ok, signature} =
      LTIResult.signature(
        "https://example.com",
        "OAuth oauth_consumer_key=\"key1234\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"1525076552\",oauth_nonce=\"123\",oauth_version=\"1.0\",oauth_signature=\"iyyQNRQyXTlpLJPJns3ireWjQxo%3D\"",
        "random_secret"
      )
```
