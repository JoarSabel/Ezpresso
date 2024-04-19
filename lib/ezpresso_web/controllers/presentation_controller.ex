defmodule Ezpresso.PresentationController do
  use EzpressoWeb, :controller
  alias Ezpresso.Presentations.Presentation
  alias Ezpresso.Repo

  def create(_conn, %{"markdown_content" => markdown_content, "title" => title, "user" => user}) do
    res =
      %Presentation{}
      |> Presentation.changeset(%{markdown_content: markdown_content, title: title, user: user})
      |> Repo.insert()

    case res do
      {:ok, struct} -> {:ok, struct}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update(_conn, %{"id" => id, "markdown_content" => markdown_content, "title" => title}) do
    case Repo.exists?(Presentation, id: id) do
      true ->
        res =
          Repo.get!(Presentation, id)
          |> Presentation.changeset(%{markdown_content: markdown_content, title: title})
          |> Repo.update()

        case res do
          {:ok, struct} -> {:ok, struct}
          {:error, changeset} -> {:error, changeset}
        end

      false ->
        {:error, "Item with id #{id} does not exist"}
    end
  end

  def show(conn, %{"id" => id}) do
    presentation = Repo.get!(Presentation, id)

    render(conn, "show.html", presentation: presentation)
  end
end
