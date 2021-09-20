defmodule UpLearn.WebScrapperTest do
  @moduledoc false
  use UpLearn.DataCase, async: true

  import Mox

  alias UpLearn.CrawlyMock

  describe "fetch_and_extract_data/1" do
    test "should return error when url is invalid" do
      expect(CrawlyMock, :fetch, fn _url, _opts ->
        %HTTPoison.Response{
          status_code: 301
        }
      end)

      assert {:error, :invalid_url} = UpLearn.WebScrapper.fetch_and_extract_data("invalid_url")
    end

    test "should return not found when status code from response is 404" do
      expect(CrawlyMock, :fetch, fn _url, _opts ->
        %HTTPoison.Response{
          status_code: 404
        }
      end)

      assert {:error, :not_found} = UpLearn.WebScrapper.fetch_and_extract_data("not_found_url")
    end

    test "should return error when content type from response not have text/html" do
      expect(CrawlyMock, :fetch, fn _url, _opts ->
        %HTTPoison.Response{
          status_code: 200,
          body: "",
          headers: [{"Content-Type", "application/json;"}]
        }
      end)

      assert {:error, :invalid_content_type} =
               UpLearn.WebScrapper.fetch_and_extract_data("invalid_content_type")
    end

    test "should return assets and links if response is html" do
      expect(CrawlyMock, :fetch, fn _url, _opts ->
        %HTTPoison.Response{
          status_code: 200,
          body: """
            <html>
              <a href="/test_link">Test Link</a>
              <a href="https://www.full_url.com/external_link">External Link</a>
              <img src="/test_image.jpg" />
              <img src="https://www.full_url.com/image.jpg" />
            </html>
          """,
          headers: [{"Content-Type", "text/html;"}],
          request_url: "http://www.url_test.com"
        }
      end)

      assert {:ok, %{assets: assets, links: links}} =
               UpLearn.WebScrapper.fetch_and_extract_data("www.url_test.com")

      assert Enum.any?(assets, fn asset -> asset == "https://www.full_url.com/image.jpg" end)
      assert Enum.any?(assets, fn asset -> asset == "http://www.url_test.com/test_image.jpg" end)
      assert Enum.any?(links, fn link -> link == "https://www.full_url.com/external_link" end)
      assert Enum.any?(links, fn link -> link == "http://www.url_test.com/test_link" end)
    end
  end
end
