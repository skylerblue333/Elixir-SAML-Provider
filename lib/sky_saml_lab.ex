defmodule SkySamlLab do
  @moduledoc """
  Bounded, dependency-free SAML configuration and assertion-policy validation primitives.

  This module does not parse XML or verify XML signatures. It validates already-decoded
  metadata supplied by a trusted boundary.
  """

  @max_id 256
  @max_url 2_048
  @max_subject 320
  @max_clock_skew 300

  @type sp_config :: %{
          entity_id: String.t(),
          acs_url: String.t(),
          audience: String.t()
        }

  @type assertion :: %{
          issuer: String.t(),
          audience: String.t(),
          subject: String.t(),
          not_before: integer(),
          not_on_or_after: integer()
        }

  @spec validate_sp_config(map()) :: {:ok, sp_config()} | {:error, atom()}
  def validate_sp_config(config) when is_map(config) do
    with {:ok, entity_id} <- bounded_string(config[:entity_id], @max_id),
         {:ok, acs_url} <- https_url(config[:acs_url]),
         {:ok, audience} <- bounded_string(config[:audience], @max_id) do
      {:ok, %{entity_id: entity_id, acs_url: acs_url, audience: audience}}
    end
  end

  def validate_sp_config(_), do: {:error, :invalid_config}

  @spec validate_assertion(map(), sp_config(), String.t(), integer(), non_neg_integer()) ::
          :ok | {:error, atom()}
  def validate_assertion(assertion, config, expected_issuer, now, clock_skew \\ 60)

  def validate_assertion(assertion, config, expected_issuer, now, clock_skew)
      when is_map(assertion) and is_map(config) and is_integer(now) and
             is_integer(clock_skew) and clock_skew >= 0 and clock_skew <= @max_clock_skew do
    with {:ok, issuer} <- bounded_string(assertion[:issuer], @max_id),
         {:ok, audience} <- bounded_string(assertion[:audience], @max_id),
         {:ok, _subject} <- bounded_string(assertion[:subject], @max_subject),
         true <- issuer == expected_issuer || {:error, :issuer_mismatch},
         true <- audience == config.audience || {:error, :audience_mismatch},
         {:ok, not_before} <- integer_field(assertion[:not_before]),
         {:ok, not_on_or_after} <- integer_field(assertion[:not_on_or_after]),
         true <- not_on_or_after > not_before || {:error, :invalid_time_window},
         true <- now + clock_skew >= not_before || {:error, :not_yet_valid},
         true <- now - clock_skew < not_on_or_after || {:error, :expired} do
      :ok
    else
      {:error, reason} -> {:error, reason}
      false -> {:error, :invalid_assertion}
    end
  end

  def validate_assertion(_, _, _, _, _), do: {:error, :invalid_assertion}

  defp bounded_string(value, max) when is_binary(value) do
    trimmed = String.trim(value)

    if byte_size(trimmed) in 1..max do
      {:ok, trimmed}
    else
      {:error, :invalid_string}
    end
  end

  defp bounded_string(_, _), do: {:error, :invalid_string}

  defp https_url(value) do
    with {:ok, url} <- bounded_string(value, @max_url),
         %URI{scheme: "https", host: host, userinfo: nil} when is_binary(host) <- URI.parse(url),
         true <- String.trim(host) != "" do
      {:ok, url}
    else
      _ -> {:error, :invalid_acs_url}
    end
  end

  defp integer_field(value) when is_integer(value), do: {:ok, value}
  defp integer_field(_), do: {:error, :invalid_timestamp}
end
