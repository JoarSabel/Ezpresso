defmodule Ezpresso.Repo do
  use Ecto.Repo,
    otp_app: :ezpresso,
    adapter: Ecto.Adapters.Postgres
end
