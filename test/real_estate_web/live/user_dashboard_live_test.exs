defmodule RealEstateWeb.UserDashboardLiveTest do
  use RealEstateWeb.ConnCase

  import Phoenix.LiveViewTest
  import RealEstate.AccountsFixtures

  test "disconnected and connected render without authentication should redirect to login page",
       %{conn: conn} do
    # If we don't previously log in we will be redirected to the login page
    assert {:error, {:redirect, %{to: "/users/log_in"}}} = live(conn, "/user_dashboard")
  end

  test "disconnected and connected render authenticated with user role should redirect to index page",
       %{
         conn: conn
       } do
    conn = conn |> log_in_user(user_fixture())
    {:ok, user_dashboard, disconnected_html} = live(conn, "/user_dashboard")
    assert disconnected_html =~ "Welcome to the user dashboard!"
    assert render(user_dashboard) =~ "Welcome to the user dashboard!"
  end

  test "disconnected and connected render authenticated with admin role should redirect to index page",
       %{
         conn: conn
       } do
    conn = conn |> log_in_user(admin_fixture())
    {:ok, user_dashboard, disconnected_html} = live(conn, "/user_dashboard")
    assert disconnected_html =~ "Welcome to the user dashboard!"
    assert render(user_dashboard) =~ "Welcome to the user dashboard!"
  end

  test "logs out when force logout on logged user", %{
    conn: conn
  } do
    user = user_fixture()
    conn = conn |> log_in_user(user)

    {:ok, user_dashboard, disconnected_html} = live(conn, "/user_dashboard")
    assert disconnected_html =~ "Welcome to the user dashboard!"
    assert render(user_dashboard) =~ "Welcome to the user dashboard!"

    RealEstate.Accounts.logout_user(user)

    # Assert our liveview process is down
    ref = Process.monitor(user_dashboard.pid)
    assert_receive {:DOWN, ^ref, _, _, _}
    refute Process.alive?(user_dashboard.pid)

    # Assert our liveview was redirected, following first to /users/force_logout, then to "/", and then to "/users/log_in"
    assert_redirect(user_dashboard, "/users/force_logout")

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
    conn = conn |> log_in_user(user1)

    {:ok, user_dashboard, disconnected_html} = live(conn, "/user_dashboard")
    assert disconnected_html =~ "Welcome to the user dashboard!"
    assert render(user_dashboard) =~ "Welcome to the user dashboard!"

    RealEstate.Accounts.logout_user(user2)

    # Assert our liveview is alive
    ref = Process.monitor(user_dashboard.pid)
    refute_receive {:DOWN, ^ref, _, _, _}
    assert Process.alive?(user_dashboard.pid)

    # If we are able to rerender the page it means nothing happened
    assert render(user_dashboard) =~ "Welcome to the user dashboard!"
  end
end
