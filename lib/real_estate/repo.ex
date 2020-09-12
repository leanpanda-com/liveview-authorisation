defmodule RealEstate.Repo do
  use Ecto.Repo,
    otp_app: :real_estate,
    adapter: Ecto.Adapters.Postgres
end
