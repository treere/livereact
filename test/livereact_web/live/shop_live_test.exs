defmodule LivereactWeb.ShopLiveTest do
  use LivereactWeb.ConnCase
  import Phoenix.LiveViewTest

  test "GET / renders guscio + isola React", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/")
    assert html =~ "Mercatino"
    assert html =~ "react-island"
    assert html =~ "phx-hook=\"ReactApp\""
    refute html =~ "Baseline LiveView pura"
  end

  test "GET /play is gone", %{conn: conn} do
    conn = get(conn, "/play")
    assert html_response(conn, 404) =~ "Not Found"
  end
end
