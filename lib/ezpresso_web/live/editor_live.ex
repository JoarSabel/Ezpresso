defmodule EzpressoWeb.EditorLive do
  alias Ezpresso.Presentations
  alias Ezpresso.Presentations.Presentation
  alias Ezpresso.Repo
  alias EzpressoWeb.Helpers.MarkdownHelper
  use EzpressoWeb, :live_view
  alias Earmark

  def render(%{loading: true} = assigns) do
    ~H"""
    <h1 class="text-xl">Ezpresso is loading</h1>
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full ">
      <.form for={@form} class="flex flex-row" phx-submit="save-presentation">
        <div class="w-1/2 flex flex-col p-4">
          <div class="flex flex-row">
            <h2 class="text-xl mb-2">Markdown Editor</h2>
            <span class="flex grow"></span>
            <button
              type="submit"
              phx-disable-with="Saving..."
              class="bg-green-500 hover:bg-green-600 rounded w-16 text-white py-2 px-4 mr-2"
            >
              Save
            </button>
            <button class="group transition-all duration-300 ease-in-out" phx-click="present">
              <span class="bg-left-bottom bg-gradient-to-r from-pink-500 to-pink-500 bg-[length:0%_2px] bg-no-repeat group-hover:bg-[length:100%_2px] transition-all duration-500 ease-out">
                Present 🎬
              </span>
            </button>
          </div>
          <div class="invisible h-0">
            <.input type="text" field={@form[:id]} label="ID" />
          </div>
          <.input
            type="text"
            field={@form[:title]}
            label="Presentation Title"
            class="w-full border rounded border-black p-2 mb-4"
            required
          />
          <.input
            field={@form[:markdown_content]}
            label="Markdown Content"
            type="textarea"
            class="w-full border rounded p-2"
            phx-change="update-markdown"
            phx-debounce="500"
            rows="25"
            required
          />
        </div>
        <div class="w-1/2 flex flex-col p-4 max-h-[50rem]">
          <h2 class="text-xl mb-2">Preview</h2>
          <div class="overflow-scroll">
            <%= for {slide_html, index} <- Enum.with_index(@slides_html) do %>
              <div
                id={"preview-" <> Integer.to_string(index+1)}
                name="preview"
                class="bg-slate-50 border rounded p-4 mb-4 min-h-60"
              >
                <article class="prose prose-a:text-sky-500 descendant:dark:text-white">
                  <%= raw(slide_html) %>
                </article>
              </div>
            <% end %>
          </div>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    presentation = Repo.get(Presentation, id)

    case presentation do
      # if we find nothing
      nil ->
        socket =
          socket
          |> put_flash(:error, "No such presentation exists")
          |> push_navigate(to: ~p"/editor")

        form =
          %Presentation{}
          |> Presentation.changeset(%{markdown_content: ""})
          |> to_form(as: "presentation")

        {:ok,
         assign(
           socket,
           loading: false,
           slides_html: MarkdownHelper.collect_slides(""),
           form: to_form(form)
         )}

      # else (basically if we find something)
      _ ->
        res =
          presentation
          |> Presentation.changeset(%{})
          |> to_form(as: "presentation")

        {:ok,
         assign(
           socket,
           loading: false,
           slides_html: MarkdownHelper.collect_slides(presentation.markdown_content),
           form: to_form(res)
         )}
    end
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      tmp = "# Slide One\n\n>Quote of the day \n\n---\n\n# Slide Two\n\nContent"

      form =
        %Presentation{}
        |> Presentation.changeset(%{id: nil, markdown_content: tmp})
        |> to_form(as: "presentation")

      {:ok,
       assign(socket,
         loading: false,
         slides_html: MarkdownHelper.collect_slides(tmp),
         form: to_form(form)
       )}
    else
      form =
        %Presentation{}
        |> Presentation.changeset(%{id: nil, markdown_content: ""})
        |> to_form(as: "presentation")

      {:ok,
       assign(socket,
         loading: true,
         slides_html: MarkdownHelper.collect_slides(""),
         form: to_form(form)
       )}
    end
  end

  @impl true
  def handle_event("present", _values, socket) do
    socket =
      socket
      |> push_navigate(to: ~p"/present/#{socket.assigns.form.data.id}")

    {:noreply, socket}
  end

  @impl true
  def handle_event("update-markdown", %{"presentation" => params}, socket) do
    %{form: form} = socket.assigns

    formb =
      form.data
      |> Presentation.changeset(%{markdown_content: params["markdown_content"]})
      |> to_form(as: "presentation")

    {:noreply,
     assign(socket,
       loading: false,
       slides_html: MarkdownHelper.collect_slides(params["markdown_content"]),
       form: to_form(formb)
     )}
  end

  @impl true
  def handle_event("validate", %{"presentation" => _params}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "save-presentation",
        %{"presentation" => params},
        socket
      ) do
    %{current_user: user} = socket.assigns

    params
    |> Map.put("user_id", user.id)
    |> Presentations.save()
    |> case do
      {:ok, presentation} ->
        socket =
          socket
          |> put_flash(:info, "Presentation saved successfully")
          |> push_navigate(to: ~p"/editor/#{presentation.id}")

        {:noreply, socket}

      # TODO return on success and reset on failure
      {:error, _changeset} ->
        {:noreply, socket}
    end
  end
end
