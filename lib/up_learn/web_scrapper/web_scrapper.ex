defmodule UpLearn.WebScrapper do
  alias UpLearn.WebScrapper.Fetcher

  def fetch_and_extract_data(url) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:fetch_url, fn _repo, _changes ->
      {:ok, Fetcher.fetch(url)}
    end)
    |> Ecto.Multi.run(:parse_response, fn _repo, %{fetch_url: response} ->
      parse_response(response)
    end)
    |> Ecto.Multi.run(:parse_document, fn _repo, %{parse_response: body} ->
      Floki.parse_document(body)
    end)
    |> Ecto.Multi.run(:extract_data, fn _repo, %{fetch_url: response, parse_document: document} ->
      extract_data(document, response.request_url)
    end)
    |> UpLearn.Repo.transaction()
    |> case do
      {:ok, %{extract_data: result}} -> {:ok, result}
      {:error, _name, error, _} -> {:error, error}
    end
  end

  defp parse_response(%{status_code: 200, headers: headers, body: body}) do
    {_header, content_type} =
      Enum.find(headers, fn
        {"Content-Type", _} -> true
        {"content-type", _} -> true
        {_, _} -> false
      end)

    case String.contains?(content_type, "text/html") do
      true -> {:ok, body}
      false -> {:error, :invalid_content_type}
    end
  end

  defp parse_response(%{status_code: 404}), do: {:error, :not_found}
  defp parse_response(_response), do: {:error, :invalid_url}

  defp extract_data(document, base_url) do
    assets =
      document
      |> Floki.find("img")
      |> Floki.attribute("src")
      |> Enum.uniq()
      |> Enum.filter(&(&1 !== ""))
      |> Enum.map(&build_absolute_url(base_url, &1))

    links =
      document
      |> Floki.find("a")
      |> Floki.attribute("href")
      |> Enum.uniq()
      |> Enum.map(&build_absolute_url(base_url, &1))

    {:ok, %{assets: assets, links: links}}
  end

  defp build_absolute_url(base_url, url), do: URI.merge(base_url, url) |> to_string()

  def format_error(:invalid_content_type), do: "Invalid Content Type"
  def format_error(:not_found), do: "404 Not Found"
  def format_error(:invalid_url), do: "Invalid Url"
end
