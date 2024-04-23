defmodule Ezpresso.Presentations do
  import Ecto.Query, warn: false
  alias Ezpresso.Repo
  alias Ezpresso.Presentations.Presentation


  @doc """
  Lists all of the presentations.

  ## Returns
    A list of all presentations

  """
  def list_presentations do
    query =
      from p in Presentation,
        select: p,
        order_by: [desc: :inserted_at],
        preload: [:user]

    Repo.all(query)
  end

  def all_by_user(user) do
    from(p in Presentation, where: p.user_id == ^user.id)
    |> Repo.all()
  end

  @doc """
  Saves a presentation to storage

  ## Parameters
    - `post_params`: POST request parameters, in this case a Presentation struct

  ## Returns
    Nada

  """
  def save(post_params) do
    id = post_params["id"]
    if String.trim(id) != "" do
      case Repo.exists?(Presentation, id: id) do
        true ->
          update_exisiting_presentation(post_params, id)
        false ->
          insert_new_presentation(post_params)
      end
    else
      insert_new_presentation(post_params)
    end
  end

  defp update_exisiting_presentation(post_params, id) do
    Repo.get(Presentation, id)
    |> Presentation.changeset(post_params)
    |> Repo.update()
  end

  defp insert_new_presentation(post_params) do
    %Presentation{}
    |> Presentation.changeset(post_params)
    |> Repo.insert()
  end
end
