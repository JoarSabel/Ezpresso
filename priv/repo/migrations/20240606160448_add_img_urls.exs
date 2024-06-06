defmodule Ezpresso.Repo.Migrations.AddImgUrls do
  use Ecto.Migration

  def change do
    alter table(:presentations) do
      add :image_urls, {:array, :string}
    end
  end
end
