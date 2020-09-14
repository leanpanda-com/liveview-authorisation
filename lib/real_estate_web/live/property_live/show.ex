defmodule RealEstateWeb.PropertyLive.Show do
  use RealEstateWeb, :live_view

  alias RealEstate.Properties

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:property, Properties.get_property!(id))}
  end

  defp page_title(:show), do: "Show Property"
  defp page_title(:edit), do: "Edit Property"
end
