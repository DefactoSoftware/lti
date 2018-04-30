defmodule LTIResultTest do
  use ExUnit.Case
  alias LTIResult

  @signature "iyyQNRQyXTlpLJPJns3ireWjQxo="
  @method "post"
  @parameters [
    {"oauth_consumer_key", "key1234"},
    {"oauth_signature_method", "HMAC-SHA1"},
    {"oauth_timestamp", "1525076552"},
    {"oauth_nonce", "123"},
    {"oauth_version", "1.0"}
  ]
  @secret "random_secret"
  @url "https://example.com"

  test "produces the correct signature" do
    {:ok, signature} = LTIResult.signature(@method, @url, @parameters, @secret)

    assert signature == @signature
  end
end
