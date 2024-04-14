defmodule Ezpresso.Repo.Migrations.CreatePresentations do
  use Ecto.Migration

  def change do
    create table(:presentations) do
      add :title, :string
      add :markdown_content, :text
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:presentations, [:user_id])
  end
end
