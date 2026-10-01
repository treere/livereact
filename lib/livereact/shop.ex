defmodule Livereact.Shop do
  @moduledoc """
  Catalogo hardcoded + helper carrello per il toy mercatino.
  Niente DB, niente auth: la validazione resta qui così aggiungere
  auth dopo significa un `if` nei `handle_event`, non un refactor.
  """

  @items [
    %{id: "mela", name: "Mela", price: 3},
    %{id: "pera", name: "Pera", price: 2},
    %{id: "uva", name: "Uva", price: 4},
    %{id: "kiwi", name: "Kiwi", price: 5}
  ]

  def items, do: @items

  def find(id), do: Enum.find(@items, &(&1.id == id))

  def valid_id?(id), do: not is_nil(find(id))

  @doc "cart è %{id => qty}. Ritorna {cart, total}."
  def add(cart, id) when is_map(cart) and is_binary(id) do
    if valid_id?(id) do
      cart = Map.update(cart, id, 1, &(&1 + 1))
      {cart, total(cart)}
    else
      {cart, total(cart)}
    end
  end

  def remove(cart, id) when is_map(cart) and is_binary(id) do
    cart =
      case Map.get(cart, id, 0) do
        0 -> cart
        1 -> Map.delete(cart, id)
        n -> Map.put(cart, id, n - 1)
      end

    {cart, total(cart)}
  end

  def total(cart) when is_map(cart) do
    Enum.reduce(cart, 0, fn {id, qty}, acc ->
      case find(id) do
        %{price: p} -> acc + p * qty
        nil -> acc
      end
    end)
  end

  def detailed(cart) when is_map(cart) do
    cart
    |> Enum.map(fn {id, qty} ->
      case find(id) do
        %{name: name, price: p} -> %{id: id, name: name, price: p, qty: qty}
        nil -> nil
      end
    end)
    |> Enum.reject(&is_nil/1)
  end
end
