defmodule GrantlandWeb.EntryLiveTest do
  use GrantlandWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Grantland.Engine

  @create_attrs %{name: "some name", round: 42}
  @update_attrs %{name: "some updated name", round: 43}
  @invalid_attrs %{name: nil, round: nil}

  defp fixture(:entry) do
    {:ok, entry} = Engine.create_entry(@create_attrs)
    entry
  end

  defp create_entry(_) do
    entry = fixture(:entry)
    %{entry: entry}
  end

  describe "Index" do
    setup [:create_entry]

    test "lists all entries", %{conn: conn, entry: entry} do
      {:ok, _index_live, html} = live(conn, Routes.entry_index_path(conn, :index))

      assert html =~ "Listing Entries"
      assert html =~ entry.name
    end

    test "saves new entry", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.entry_index_path(conn, :index))

      assert index_live |> element("a", "New Entry") |> render_click() =~
               "New Entry"

      assert_patch(index_live, Routes.entry_index_path(conn, :new))

      assert index_live
             |> form("#entry-form", entry: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#entry-form", entry: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.entry_index_path(conn, :index))

      assert html =~ "Entry created successfully"
      assert html =~ "some name"
    end

    test "updates entry in listing", %{conn: conn, entry: entry} do
      {:ok, index_live, _html} = live(conn, Routes.entry_index_path(conn, :index))

      assert index_live |> element("#entry-#{entry.id} a", "Edit") |> render_click() =~
               "Edit Entry"

      assert_patch(index_live, Routes.entry_index_path(conn, :edit, entry))

      assert index_live
             |> form("#entry-form", entry: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#entry-form", entry: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.entry_index_path(conn, :index))

      assert html =~ "Entry updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes entry in listing", %{conn: conn, entry: entry} do
      {:ok, index_live, _html} = live(conn, Routes.entry_index_path(conn, :index))

      assert index_live |> element("#entry-#{entry.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#entry-#{entry.id}")
    end
  end

  describe "Show" do
    setup [:create_entry]

    test "displays entry", %{conn: conn, entry: entry} do
      {:ok, _show_live, html} = live(conn, Routes.entry_show_path(conn, :show, entry))

      assert html =~ "Show Entry"
      assert html =~ entry.name
    end

    test "updates entry within modal", %{conn: conn, entry: entry} do
      {:ok, show_live, _html} = live(conn, Routes.entry_show_path(conn, :show, entry))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Entry"

      assert_patch(show_live, Routes.entry_show_path(conn, :edit, entry))

      assert show_live
             |> form("#entry-form", entry: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#entry-form", entry: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.entry_show_path(conn, :show, entry))

      assert html =~ "Entry updated successfully"
      assert html =~ "some updated name"
    end
  end
end
