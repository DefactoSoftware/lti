defmodule LTIResultTest do
  use ExUnit.Case

  test "returns {:ok, determined_signature} if the signature is correct" do
    return =
      LTIResult.signature(
        "post",
        "https://example.com",
        "OAuth oauth_consumer_key=\"key1234\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"1525076552\",oauth_nonce=\"123\",oauth_version=\"1.0\",oauth_signature=\"iyyQNRQyXTlpLJPJns3ireWjQxo%3D\"",
        "random_secret"
      )

    assert return == {:ok, "iyyQNRQyXTlpLJPJns3ireWjQxo%3D"}
  end

  test "returns an error if the signature is incorrect due to difference in key" do
    return =
      LTIResult.signature(
        "post",
        "https://example.com",
        "OAuth oauth_consumer_key=\"key12345\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"1525076552\",oauth_nonce=\"123\",oauth_version=\"1.0\",oauth_signature=\"iyyQNRQyXTlpLJPJns3ireWjQxo%3D\"",
        "random_secret"
      )

    assert return == {:error, :unmatching_signatures}
  end

  test "returns an error if the signature is incorrect due to difference in method" do
    return =
      LTIResult.signature(
        "post",
        "https://example.com",
        "OAuth oauth_consumer_key=\"key1234\",oauth_signature_method=\"HMAC-SHA2\",oauth_timestamp=\"1525076552\",oauth_nonce=\"123\",oauth_version=\"1.0\",oauth_signature=\"iyyQNRQyXTlpLJPJns3ireWjQxo%3D\"",
        "random_secret"
      )

    assert return == {:error, :unmatching_signatures}
  end

  test "returns an error if the signature is incorrect due to difference in timestamp" do
    return =
      LTIResult.signature(
        "post",
        "https://example.com",
        "OAuth oauth_consumer_key=\"key1234\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"152500000\",oauth_nonce=\"123\",oauth_version=\"1.0\",oauth_signature=\"iyyQNRQyXTlpLJPJns3ireWjQxo%3D\"",
        "random_secret"
      )

    assert return == {:error, :unmatching_signatures}
  end

  test "returns an error if the signature is incorrect due to difference in nonce" do
    return =
      LTIResult.signature(
        "post",
        "https://example.com",
        "OAuth oauth_consumer_key=\"key1234\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"1525076552\",oauth_nonce=\"32123\",oauth_version=\"1.0\",oauth_signature=\"iyyQNRQyXTlpLJPJns3ireWjQxo%3D\"",
        "random_secret"
      )

    assert return == {:error, :unmatching_signatures}
  end

  test "returns an error if version is incorrect" do
    return =
      LTIResult.signature(
        "post",
        "https://example.com",
        "OAuth oauth_consumer_key=\"key1234\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"1525076552\",oauth_nonce=\"123\",oauth_version=\"2.0\",oauth_signature=\"iyyQNRQyXTlpLJPJns3ireWjQxo%3D\"",
        "random_secret"
      )

    assert return == {:error, [:incorrect_version]}
  end

  test "returns an error if duplicated parameters are present" do
    return =
      LTIResult.signature(
        "post",
        "https://example.com",
        "OAuth oauth_consumer_key=\"key1234\",oauth_consumer_key=\"key1234\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"1525076552\",oauth_nonce=\"123\",oauth_version=\"1.0\",oauth_signature=\"iyyQNRQyXTlpLJPJns3ireWjQxo%3D\"",
        "random_secret"
      )

    assert return == {:error, [:duplicated_parameters]}
  end

  test "returns an error if the consumer key is missing" do
    return =
      LTIResult.signature(
        "post",
        "https://example.com",
        "OAuth oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"1525076552\",oauth_nonce=\"123\",oauth_version=\"1.0\",oauth_signature=\"iyyQNRQyXTlpLJPJns3ireWjQxo%3D\"",
        "random_secret"
      )

    assert return == {:error, [:missing_required_parameters]}
  end

  test "returns an error if the signature method is missing" do
    return =
      LTIResult.signature(
        "post",
        "https://example.com",
        "OAuth oauth_consumer_key=\"key1234\",oauth_timestamp=\"1525076552\",oauth_nonce=\"123\",oauth_version=\"1.0\",oauth_signature=\"iyyQNRQyXTlpLJPJns3ireWjQxo%3D\"",
        "random_secret"
      )

    assert return == {:error, [:missing_required_parameters]}
  end

  test "returns an error if the timestamp is missing" do
    return =
      LTIResult.signature(
        "post",
        "https://example.com",
        "OAuth oauth_consumer_key=\"key1234\",oauth_signature_method=\"HMAC-SHA1\",oauth_nonce=\"123\",oauth_version=\"1.0\",oauth_signature=\"iyyQNRQyXTlpLJPJns3ireWjQxo%3D\"",
        "random_secret"
      )

    assert return == {:error, [:missing_required_parameters]}
  end

  test "returns an error if oauth version is missing" do
    return =
      LTIResult.signature(
        "post",
        "https://example.com",
        "OAuth oauth_consumer_key=\"key1234\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"1525076552\",oauth_nonce=\"123\",oauth_signature=\"iyyQNRQyXTlpLJPJns3ireWjQxo%3D\"",
        "random_secret"
      )

    assert return == {:error, [:incorrect_version, :missing_required_parameters]}
  end

  test "returns an error if nonce is missing" do
    return =
      LTIResult.signature(
        "post",
        "https://example.com",
        "OAuth oauth_consumer_key=\"key1234\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"1525076552\",oauth_version=\"1.0\",oauth_signature=\"iyyQNRQyXTlpLJPJns3ireWjQxo%3D\"",
        "random_secret"
      )

    assert return == {:error, [:missing_required_parameters]}
  end
end
