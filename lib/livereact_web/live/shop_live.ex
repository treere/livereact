defmodule LivereactWeb.ShopLive do
  use LivereactWeb, :live_view

  alias Livereact.Shop
  alias Livereact.PubSub

  @topic "demo:lobby"

  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(PubSub, @topic)

    {:ok,
     socket
     |> assign(items: Shop.items(), cart: %{}, total: 0)
     |> assign(detailed: [])}
  end

  # ponytail: validazione centralizzata qui; auth futura = un `if` per evento
  def handle_event("add-to-cart", %{"id" => id}, socket) do
    if Shop.valid_id?(id) do
      {cart, total} = Shop.add(socket.assigns.cart, id)
      broadcast_cart(cart, total)
      {:noreply, assign_cart(socket, cart, total)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("add-to-cart", _params, socket), do: {:noreply, socket}

  def handle_event("remove-from-cart", %{"id" => id}, socket) do
    if Shop.valid_id?(id) do
      {cart, total} = Shop.remove(socket.assigns.cart, id)
      broadcast_cart(cart, total)
      {:noreply, assign_cart(socket, cart, total)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("remove-from-cart", _params, socket), do: {:noreply, socket}

  def handle_event("clear-cart", _params, socket) do
    broadcast_cart(%{}, 0)
    {:noreply, assign_cart(socket, %{}, 0)}
  end

  def handle_info({:cart_updated, cart, total}, socket) do
    {:noreply,
     socket
     |> assign_cart(cart, total)
     |> push_event("cart-updated", %{cart: Shop.detailed(cart), total: total})}
  end

  defp assign_cart(socket, cart, total) do
    assign(socket, cart: cart, total: total, detailed: Shop.detailed(cart))
  end

  defp broadcast_cart(cart, total) do
    Phoenix.PubSub.broadcast(PubSub, @topic, {:cart_updated, cart, total})
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-3xl px-4 py-8">
      <header class="border-b pb-4">
        <h1 class="text-xl font-bold">Mercatino — totale: {@total}€</h1>
      </header>

      <p class="mt-4 text-sm opacity-70">
        Guscio LiveView + isola React. Filtro e selezione vivono solo nel browser.
      </p>
      <div
        id="react-island"
        phx-hook="ReactApp"
        phx-update="ignore"
        data-items={Jason.encode!(@items)}
        class="mt-4 rounded border p-4"
      >
        <p class="text-sm opacity-60">Carico React… (serve JS attivo)</p>
      </div>

      <footer class="mt-6 rounded border p-4">
        <h2 class="font-semibold">Carrello live (server)</h2>
        <%= if @detailed == [] do %>
          <p class="text-sm opacity-60">Vuoto. Aggiungi da React.</p>
        <% else %>
          <ul class="mt-2 text-sm">
            <li :for={row <- @detailed} class="flex items-center justify-between">
              <span>{row.name} x{row.qty} — {row.price * row.qty}€</span>
              <button phx-click="remove-from-cart" phx-value-id={row.id} class="underline">
                rimuovi
              </button>
            </li>
          </ul>
          <button phx-click="clear-cart" class="mt-2 text-sm underline">Svuota</button>
        <% end %>
      </footer>
    </div>
    """
  end
end
