defmodule LivereactWeb.SessionControllerTest do
  use LivereactWeb.ConnCase

  defp csrf_conn(conn) do
    conn = get(conn, "/")
    html = html_response(conn, 200)
    [_, csrf] = Regex.run(~r/name="csrf-token" content="([^"]+)"/, html)
    {conn, csrf}
  end

  defp post_session(conn, csrf, params) do
    conn
    |> recycle()
    |> put_req_header("x-csrf-token", csrf)
    |> post(~p"/api/session", params)
  end

  test "login valido normalizza e imposta cookie", %{conn: conn} do
    {conn, csrf} = csrf_conn(conn)
    conn = post_session(conn, csrf, %{username: "  Mario "})
    assert %{"username" => "mario", "display_name" => "Mario"} = json_response(conn, 201)
    assert get_resp_header(conn, "set-cookie") != []
  end

  test "stesso username normalizzato = stesso utente", %{conn: conn} do
    {conn, csrf} = csrf_conn(conn)
    conn = post_session(conn, csrf, %{username: "MARIO"})
    assert %{"username" => "mario"} = json_response(conn, 201)
  end

  test "username vuoto respinto 422", %{conn: conn} do
    {conn, csrf} = csrf_conn(conn)
    conn = post_session(conn, csrf, %{username: "   "})
    assert %{"error" => _} = json_response(conn, 422)
  end

  test "username mancante respinto 422", %{conn: conn} do
    {conn, csrf} = csrf_conn(conn)
    conn = post_session(conn, csrf, %{})
    assert %{"error" => _} = json_response(conn, 422)
  end

  test "username troppo lungo respinto 422", %{conn: conn} do
    {conn, csrf} = csrf_conn(conn)
    conn = post_session(conn, csrf, %{username: String.duplicate("a", 33)})
    assert json_response(conn, 422)
  end

  test "login funziona anche con solo cookie SameSite (flusso fetch same-origin)", %{conn: conn} do
    {conn, csrf} = csrf_conn(conn)
    conn = post_session(conn, csrf, %{username: "mario"})
    assert %{"username" => "mario"} = json_response(conn, 201)
  end

  test "logout pulisce la sessione", %{conn: conn} do
    {conn, csrf} = csrf_conn(conn)
    conn = post_session(conn, csrf, %{username: "mario"})
    assert json_response(conn, 201)

    conn =
      conn
      |> recycle()
      |> put_req_header("x-csrf-token", csrf)
      |> delete(~p"/api/session")

    assert %{"ok" => true} = json_response(conn, 200)
  end
end
