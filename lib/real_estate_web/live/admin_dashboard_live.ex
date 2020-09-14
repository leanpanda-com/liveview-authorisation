defmodule RealEstateWeb.AdminDashboardLive do
  use RealEstateWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket)
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <section class="phx-hero">
      <h1>Welcome to the admin dashboard!</h1>
    </section>
    """
  end
end
