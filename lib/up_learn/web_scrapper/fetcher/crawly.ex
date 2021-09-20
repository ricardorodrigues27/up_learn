defmodule UpLearn.WebScrapper.Fetcher.Crawly do
  @moduledoc """
  Implements UpLearn.WebScrapper.Fetcher behavior for Crawly.
  """

  @behaviour UpLearn.WebScrapper.Fetcher

  @impl true
  def fetch(url, options) do
    Crawly.fetch(url, options)
  end
end
