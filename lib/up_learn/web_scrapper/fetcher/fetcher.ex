defmodule UpLearn.WebScrapper.Fetcher do
  @moduledoc """
  A behaviour module for defining Crawly Fetchers
  """

  @type with_opt :: {:with, nil | module()}
  @type request_opt :: {:request_options, list(Crawly.Request.option())}
  @type headers_opt :: {:headers, list(Crawly.Request.header())}

  @type parsed_item_result :: Crawly.ParsedItem.t()
  @type parsed_items :: list(any())
  @type pipeline_state :: %{optional(atom()) => any()}

  @callback fetch(url, opts) ::
          HTTPoison.Response.t()
          | {HTTPoison.Response.t(), parsed_item_result, parsed_items,
             pipeline_state}
        when url: binary(),
             opts: [
               with_opt
               | request_opt
               | headers_opt
             ]

  def fetch(url, opts \\ []) do
    adapter().fetch(url, opts)
  end

  defp adapter, do: :adapter |> config() |> Keyword.get(:adapter)

  defp config(key), do: Application.get_env(:up_learn, __MODULE__) |> Keyword.take([key])
end
