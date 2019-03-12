defmodule LTIResultTest do
  use ExUnit.Case
  doctest LTIResult, only: [signature: 4]

  test "returns {:ok, determined_signature} if the signature is correct" do
    return =
      LTIResult.signature(
        "https://example.com",
        "OAuth oauth_consumer_key=\"key1234\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"1525076552\",oauth_nonce=\"123\",oauth_version=\"1.0\",oauth_signature=\"iyyQNRQyXTlpLJPJns3ireWjQxo%3D\"",
        "random_secret"
      )

    assert return == {:ok, "iyyQNRQyXTlpLJPJns3ireWjQxo="}
  end

  test "returns identical signatures for downcase url and url with capitals" do
    return1 =
      LTIResult.signature(
        "https://example.com",
        "OAuth oauth_consumer_key=\"key1234\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"1525076552\",oauth_nonce=\"123\",oauth_version=\"1.0\",oauth_signature=\"iyyQNRQyXTlpLJPJns3ireWjQxo%3D\"",
        "random_secret"
      )

    return2 =
      LTIResult.signature(
        "https://ExamPle.com",
        "OAuth oauth_consumer_key=\"key1234\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"1525076552\",oauth_nonce=\"123\",oauth_version=\"1.0\",oauth_signature=\"iyyQNRQyXTlpLJPJns3ireWjQxo%3D\"",
        "random_secret"
      )

    assert return1 == return2
  end

  test "returns {:ok, determined_signature} if a bodyhash is included" do
    return =
      LTIResult.signature(
        "http://474c3d0e.ngrok.io/capp11/api/v1/lti_results",
        "OAuth oauth_version=\"1.0\",oauth_nonce=\"tjtwip19l78355dl\",oauth_timestamp=\"1528808890\",oauth_consumer_key=\"Defacto\",oauth_body_hash=\"qvrl3dbLTUqxHeCDqof%2Ffz%2Bygc0%3D\",oauth_signature_method=\"HMAC-SHA1\",oauth_signature=\"WF9NUX6QCgKXNb2nNYEZ4evBmSk%3D\"",
        "random_secret"
      )

    assert return == {:ok, "WF9NUX6QCgKXNb2nNYEZ4evBmSk="}
  end

  test "returns an error if the signature is incorrect due to difference in key" do
    return =
      LTIResult.signature(
        "https://example.com",
        "OAuth oauth_consumer_key=\"key12345\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"1525076552\",oauth_nonce=\"123\",oauth_version=\"1.0\",oauth_signature=\"iyyQNRQyXTlpLJPJns3ireWjQxo%3D\"",
        "random_secret"
      )

    assert return == {:error, [:unmatching_signatures]}
  end

  test "returns an error if the signature is incorrect due to difference in method" do
    return =
      LTIResult.signature(
        "https://example.com",
        "OAuth oauth_consumer_key=\"key1234\",oauth_signature_method=\"HMAC-SHA2\",oauth_timestamp=\"1525076552\",oauth_nonce=\"123\",oauth_version=\"1.0\",oauth_signature=\"iyyQNRQyXTlpLJPJns3ireWjQxo%3D\"",
        "random_secret"
      )

    assert return == {:error, [:unmatching_signatures]}
  end

  test "returns an error if the signature is incorrect due to difference in timestamp" do
    return =
      LTIResult.signature(
        "https://example.com",
        "OAuth oauth_consumer_key=\"key1234\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"152500000\",oauth_nonce=\"123\",oauth_version=\"1.0\",oauth_signature=\"iyyQNRQyXTlpLJPJns3ireWjQxo%3D\"",
        "random_secret"
      )

    assert return == {:error, [:unmatching_signatures]}
  end

  test "returns an error if the signature is incorrect due to difference in nonce" do
    return =
      LTIResult.signature(
        "https://example.com",
        "OAuth oauth_consumer_key=\"key1234\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"1525076552\",oauth_nonce=\"32123\",oauth_version=\"1.0\",oauth_signature=\"iyyQNRQyXTlpLJPJns3ireWjQxo%3D\"",
        "random_secret"
      )

    assert return == {:error, [:unmatching_signatures]}
  end

  test "returns an error if version is incorrect" do
    return =
      LTIResult.signature(
        "https://example.com",
        "OAuth oauth_consumer_key=\"key1234\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"1525076552\",oauth_nonce=\"123\",oauth_version=\"2.0\",oauth_signature=\"iyyQNRQyXTlpLJPJns3ireWjQxo%3D\"",
        "random_secret"
      )

    assert return == {:error, [:incorrect_version]}
  end

  test "returns an error if duplicated parameters are present" do
    return =
      LTIResult.signature(
        "https://example.com",
        "OAuth oauth_consumer_key=\"key1234\",oauth_consumer_key=\"key1234\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"1525076552\",oauth_nonce=\"123\",oauth_version=\"1.0\",oauth_signature=\"iyyQNRQyXTlpLJPJns3ireWjQxo%3D\"",
        "random_secret"
      )

    assert return == {:error, [:duplicated_parameters]}
  end

  test "returns an error if the consumer key is missing" do
    return =
      LTIResult.signature(
        "https://example.com",
        "OAuth oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"1525076552\",oauth_nonce=\"123\",oauth_version=\"1.0\",oauth_signature=\"iyyQNRQyXTlpLJPJns3ireWjQxo%3D\"",
        "random_secret"
      )

    assert return == {:error, [:missing_required_parameters]}
  end

  test "returns an error if the signature method is missing" do
    return =
      LTIResult.signature(
        "https://example.com",
        "OAuth oauth_consumer_key=\"key1234\",oauth_timestamp=\"1525076552\",oauth_nonce=\"123\",oauth_version=\"1.0\",oauth_signature=\"iyyQNRQyXTlpLJPJns3ireWjQxo%3D\"",
        "random_secret"
      )

    assert return == {:error, [:missing_required_parameters]}
  end

  test "returns an error if the timestamp is missing" do
    return =
      LTIResult.signature(
        "https://example.com",
        "OAuth oauth_consumer_key=\"key1234\",oauth_signature_method=\"HMAC-SHA1\",oauth_nonce=\"123\",oauth_version=\"1.0\",oauth_signature=\"iyyQNRQyXTlpLJPJns3ireWjQxo%3D\"",
        "random_secret"
      )

    assert return == {:error, [:missing_required_parameters]}
  end

  test "returns an error if oauth version is missing" do
    return =
      LTIResult.signature(
        "https://example.com",
        "OAuth oauth_consumer_key=\"key1234\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"1525076552\",oauth_nonce=\"123\",oauth_signature=\"iyyQNRQyXTlpLJPJns3ireWjQxo%3D\"",
        "random_secret"
      )

    assert return == {:error, [:incorrect_version, :missing_required_parameters]}
  end

  test "returns an error if nonce is missing" do
    return =
      LTIResult.signature(
        "https://example.com",
        "OAuth oauth_consumer_key=\"key1234\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"1525076552\",oauth_version=\"1.0\",oauth_signature=\"iyyQNRQyXTlpLJPJns3ireWjQxo%3D\"",
        "random_secret"
      )

    assert return == {:error, [:missing_required_parameters]}
  end

  test "returns an error if an unsupported parameter is provided" do
    return =
      LTIResult.signature(
        "https://example.com",
        "OAuth unsupported_derpvalue=\"123\",oauth_consumer_key=\"key1234\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"1525076552\",oauth_nonce=\"123\",oauth_version=\"1.0\",oauth_signature=\"iyyQNRQyXTlpLJPJns3ireWjQxo%3D\"",
        "random_secret"
      )

    assert return == {:error, [:unsupported_parameters]}
  end
end
