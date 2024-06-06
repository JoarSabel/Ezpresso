defmodule Ezpresso.Presentations.Presentation do
  alias Ezpresso.Accounts.User
  use Ecto.Schema
  import Ecto.Changeset

  schema "presentations" do
    field :title, :string
    field :markdown_content, :string
    field :image_urls, {:array, :string}
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(presentation, attrs) do
    presentation
    |> cast(attrs, [:title, :markdown_content, :user_id, :image_urls])
    |> validate_required([:title, :markdown_content, :user_id, :image_urls])
  end
end
