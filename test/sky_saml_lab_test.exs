ExUnit.start()

defmodule SkySamlLabTest do
  use ExUnit.Case, async: true

  test "validates an HTTPS service-provider config" do
    assert {:ok, config} =
             SkySamlLab.validate_sp_config(%{
               entity_id: "urn:sky:sp",
               acs_url: "https://example.com/saml/acs",
               audience: "urn:sky:audience"
             })

    assert config.audience == "urn:sky:audience"
  end

  test "rejects insecure or credential-bearing ACS URLs" do
    assert {:error, :invalid_acs_url} =
             SkySamlLab.validate_sp_config(%{
               entity_id: "urn:sky:sp",
               acs_url: "http://example.com/acs",
               audience: "urn:sky:audience"
             })

    assert {:error, :invalid_acs_url} =
             SkySamlLab.validate_sp_config(%{
               entity_id: "urn:sky:sp",
               acs_url: "https://user:pass@example.com/acs",
               audience: "urn:sky:audience"
             })
  end

  test "accepts assertion metadata inside audience and time policy" do
    {:ok, config} =
      SkySamlLab.validate_sp_config(%{
        entity_id: "urn:sky:sp",
        acs_url: "https://example.com/saml/acs",
        audience: "urn:sky:audience"
      })

    assertion = %{
      issuer: "urn:sky:idp",
      audience: "urn:sky:audience",
      subject: "user@example.com",
      not_before: 1_000,
      not_on_or_after: 1_600
    }

    assert :ok = SkySamlLab.validate_assertion(assertion, config, "urn:sky:idp", 1_300)
  end

  test "rejects wrong audience and expired assertion metadata" do
    {:ok, config} =
      SkySamlLab.validate_sp_config(%{
        entity_id: "urn:sky:sp",
        acs_url: "https://example.com/saml/acs",
        audience: "urn:sky:audience"
      })

    base = %{
      issuer: "urn:sky:idp",
      audience: "wrong",
      subject: "user@example.com",
      not_before: 1_000,
      not_on_or_after: 1_600
    }

    assert {:error, :audience_mismatch} =
             SkySamlLab.validate_assertion(base, config, "urn:sky:idp", 1_300)

    expired = %{base | audience: "urn:sky:audience"}
    assert {:error, :expired} = SkySamlLab.validate_assertion(expired, config, "urn:sky:idp", 2_000)
  end
end
