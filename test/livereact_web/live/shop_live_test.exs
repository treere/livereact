defmodule LivereactWeb.ShopLiveTest do
  use LivereactWeb.ConnCase
  import Phoenix.LiveViewTest

  test "GET / anonimo vede solo login React", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/")
    assert html =~ "Mercatino"
    assert html =~ "react-island"
    assert html =~ "phx-hook=\"ReactApp\""
    assert html =~ "data-current-user=\"\""
    refute html =~ "Carrello live"
    refute html =~ "Baseline LiveView pura"
  end

  test "loggato vede market + footer server", %{conn: conn} do
    conn = Plug.Test.init_test_session(conn, %{"username" => "mario", "display_name" => "Mario"})
    {:ok, _view, html} = live(conn, ~p"/")
    assert html =~ "data-current-user=\"mario\""
    assert html =~ "Carrello live"
  end

  test "evento add-to-cart da anonimo ignorato", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    html = render_click(view, "add-to-cart", %{"id" => "mela"})
    refute html =~ "Carrello live"
  end

  test "evento add-to-cart da loggato aggiorna", %{conn: conn} do
    conn = Plug.Test.init_test_session(conn, %{"username" => "mario", "display_name" => "Mario"})
    {:ok, view, _html} = live(conn, ~p"/")
    html = render_click(view, "add-to-cart", %{"id" => "mela"})
    assert html =~ "Mela"
  end

  test "GET /play is gone", %{conn: conn} do
    conn = get(conn, "/play")
    assert html_response(conn, 404) =~ "Not Found"
  end
end
