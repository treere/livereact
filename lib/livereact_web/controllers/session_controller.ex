defmodule LivereactWeb.SessionController do
  use LivereactWeb, :controller

  def create(conn, params) do
    display = params |> Map.get("username", "") |> to_string() |> String.trim()
    username = String.downcase(display)

    cond do
      display == "" ->
        conn |> put_status(422) |> json(%{error: "username richiesto"})

      String.length(display) > 32 ->
        conn |> put_status(422) |> json(%{error: "username troppo lungo"})

      true ->
        conn
        |> configure_session(renew: true)
        |> put_session(:username, username)
        |> put_session(:display_name, display)
        |> put_status(201)
        |> json(%{username: username, display_name: display})
    end
  end

  def delete(conn, _params) do
    conn |> clear_session() |> json(%{ok: true})
  end
end
