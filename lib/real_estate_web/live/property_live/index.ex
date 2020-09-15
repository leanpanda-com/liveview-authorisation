defmodule RealEstateWeb.PropertyLive.Index do
  use RealEstateWeb, :live_view

  alias RealEstate.Properties
  alias RealEstate.Properties.Property
  alias RealEstateWeb.Roles

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket)
    {:ok, assign(socket, :properties, [])}
  end

  @impl true
  def handle_params(params, _url, socket) do
    current_user = socket.assigns.current_user
    live_action = socket.assigns.live_action
    property = property_from_params(params)

    if Roles.can?(current_user, property, live_action) do
      socket = assign(socket, :properties, list_properties())
      {:noreply, apply_action(socket, live_action, params)}
    else
      {:noreply,
       socket
       |> put_flash(:error, "Unauthorised")
       |> redirect(to: "/")}
    end
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Property")
    |> assign(:property, Properties.get_property!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Property")
    |> assign(:property, %Property{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Properties")
    |> assign(:property, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    current_user = socket.assigns.current_user
    property = Properties.get_property!(id)

    if RealEstateWeb.Roles.can?(current_user, property, :delete) do
      property = Properties.get_property!(id)
      {:ok, _} = Properties.delete_property(property)

      {:noreply, assign(socket, :properties, list_properties())}
    else
      {:noreply,
       socket
       |> put_flash(:error, "Unauthorised")
       |> redirect(to: "/")}
    end
  end

  defp property_from_params(params)

  defp property_from_params(%{"id" => id}),
    do: Properties.get_property!(id)

  defp property_from_params(_params), do: %Property{}

  defp list_properties do
    Properties.list_properties()
  end
end
