defmodule RealEstateWeb.PageLiveTest do
  use RealEstateWeb.ConnCase

  import Phoenix.LiveViewTest
  import RealEstate.AccountsFixtures

  test "disconnected and connected render without authentication should redirect to login page",
       %{conn: conn} do
    # If we don't previously log in we will be redirected to the login page
    assert {:error, {:redirect, %{to: "/users/log_in"}}} = live(conn, "/")
  end

  test "disconnected and connected render with authentication should redirect to index page", %{
    conn: conn
  } do
    conn = conn |> log_in_user(user_fixture())

    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Welcome to Phoenix!"
    assert render(page_live) =~ "Welcome to Phoenix!"
  end
end
