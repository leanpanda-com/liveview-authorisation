defmodule RealEstateWeb.PropertyLive.FormComponent do
  use RealEstateWeb, :live_component

  alias RealEstate.Properties

  @impl true
  def update(%{property: property} = assigns, socket) do
    changeset = Properties.change_property(property)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"property" => property_params}, socket) do
    changeset =
      socket.assigns.property
      |> Properties.change_property(property_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"property" => property_params}, socket) do
    save_property(socket, socket.assigns.action, property_params)
  end

  defp save_property(socket, :edit, property_params) do
    case Properties.update_property(socket.assigns.property, property_params) do
      {:ok, _property} ->
        {:noreply,
         socket
         |> put_flash(:info, "Property updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_property(socket, :new, property_params) do
    current_user = socket.assigns.current_user
    property_params = Map.put(property_params, "user_id", current_user.id)

    case Properties.create_property(property_params) do
      {:ok, _property} ->
        {:noreply,
         socket
         |> put_flash(:info, "Property created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
