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

  test "logs out when force logout on logged user", %{
    conn: conn
  } do
    user = user_fixture()
    conn = conn |> log_in_user(user)

    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Welcome to Phoenix!"
    assert render(page_live) =~ "Welcome to Phoenix!"

    RealEstate.Accounts.logout_user(user)

    # Assert our liveview process is down
    ref = Process.monitor(page_live.pid)
    assert_receive {:DOWN, ^ref, _, _, _}
    refute Process.alive?(page_live.pid)

    # Assert our liveview was redirected, following first to /users/force_logout, then to "/", and then to "/users/log_in"
    assert_redirect(page_live, "/users/force_logout")

    conn = get(conn, "/users/force_logout")
    assert "/" = redir_path = redirected_to(conn, 302)
    conn = get(recycle(conn), redir_path)

    assert "/users/log_in" = redir_path = redirected_to(conn, 302)
    conn = get(recycle(conn), redir_path)

    assert html_response(conn, 200) =~
             "You were logged out. Please login again to continue using our application."
  end

  test "doesn't log out when force logout on another user", %{
    conn: conn
  } do
    user1 = user_fixture()
    user2 = user_fixture()
    conn = conn |> log_in_user(user2)

    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Welcome to Phoenix!"
    assert render(page_live) =~ "Welcome to Phoenix!"

    RealEstate.Accounts.logout_user(user1)

    # Assert our liveview is alive
    ref = Process.monitor(page_live.pid)
    refute_receive {:DOWN, ^ref, _, _, _}
    assert Process.alive?(page_live.pid)

    # If we are able to rerender the page it means nothing happened
    assert render(page_live) =~ "Welcome to Phoenix!"
  end
end
