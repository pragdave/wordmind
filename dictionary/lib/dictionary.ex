defmodule Dictionary do

  alias Dictionary.Runtime.Server

  @spec pick_target_word() :: String.t
  defdelegate pick_target_word(), to: Server

  @spec is_known_word?(String.t) :: boolean()
  defdelegate is_known_word?(word), to: Server
end

