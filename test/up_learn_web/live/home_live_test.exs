defmodule UpLearnWeb.HomeLiveTest do
  use UpLearnWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, home_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Up Learn"
    assert render(home_live) =~ "Search"
  end
end
