defmodule LivereactWeb.ShopLiveTest do
  use LivereactWeb.ConnCase
  import Phoenix.LiveViewTest

  test "GET / renders baseline LV pura", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/")
    assert html =~ "Mercatino"
    assert html =~ "Baseline LiveView pura"
  end

  test "GET /play renders guscio + isola React", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/play")
    assert html =~ "react-island"
    assert html =~ "phx-hook=\"ReactApp\""
  end
end
