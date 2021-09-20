defmodule UpLearnWeb.HomeLive do
  use UpLearnWeb, :live_view

  alias UpLearn.WebScrapper

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", results: %{}, message_error: "")}
  end

  @impl true
  def handle_event("change-url", %{"q" => query}, socket) do
    {:noreply, assign(socket, query: query)}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    socket =
      WebScrapper.fetch_and_extract_data(query)
      |> case do
        {:ok, results} ->
          assign(socket, results: results, message_error: "")

        {:error, error} ->
          assign(socket, results: %{}, message_error: WebScrapper.format_error(error))
      end

    {:noreply, socket}
  end
end
