defmodule EzpressoWeb.PresenterPageLive do
  alias Ezpresso.Presentations
  alias Ezpresso.Presentations.Presentation
  alias Ezpresso.Repo
  alias EzpressoWeb.Helpers.MarkdownHelper
  use EzpressoWeb, :live_view
  alias Earmark

  def render(%{loading: true} = assigns) do
    ~H"""
    <h1 class="text-xl">Ezpresso is loading...</h1>
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div
      class="w-full min-h-full justify-center content-center text-center "
      phx-window-keydown="handle-keypress"
    >
      <div class="flex flex-col min-h-full">
        <div class="flex min-h-[65vh] justify-center content-center text-center items-center relative">
          <%= if @draw_mode do %>
            <canvas
              id="presentation_canvas"
              class="bg-transparent absolute z-20"
              phx-hook="canvas"
              width="1500"
              height="700"
            >
            </canvas>
          <% end %>
          <%= for {slide, idx} <- Enum.with_index(@slides) do %>
            <%= if assigns.current_slide == idx do %>
              <div
                id={"slide-" <> Integer.to_string(idx+1)}
                name="slide"
                class="flex justify-center content-center text-center items-center h-full w-full "
              >
                <article class="prose prose-zinc prose-img:rounded-xl prose-2xl prose-a:text-sky-500 descendant:dark:text-white text-left">
                  <%= raw(slide) %>
                </article>
              </div>
            <% end %>
          <% end %>
        </div>
        <span class="flex grow"></span>
        <div class="flex flex-row w-full">
          <div class="flex flex-row justify-center items-end min-h-[10vh]">
            <%= if @current_slide > 0 do %>
              <button
                class="rounded border border-black mr-2 p-2 bg-white-500 max-h-12"
                phx-click="slide-back"
              >
                Prev
              </button>
            <% else %>
              <button class="rounded border border-black mr-2 p-2 bg-white-500 max-h-12 opacity-50 cursor-not-allowed">
                Prev
              </button>
            <% end %>
            <%= if @slides |> Enum.count() > @current_slide + 1 do %>
              <button
                class="rounded border border-black mr-2 p-2 bg-white-500 max-h-12"
                phx-click="slide-forth"
              >
                Next
              </button>
            <% else %>
              <button class="rounded border border-black mr-2 p-2 bg-white-500 opacity-50 cursor-not-allowed max-h-12">
                Next
              </button>
            <% end %>
          </div>
          <span class="flex grow"></span>
          <div class="flex flex-row justify-center items-end min-h-[10vh]">
            <%= if not @draw_mode do %>
            <button
              id="toggle_draw_offversion"
              class="rounded border border-black mr-2 p-2 bg-white-500 max-h-12 transition-all hover:shadow-xl hover:shadow-green-500 duration-300"
              phx-click="toggle_draw"
            >
              Draw
            </button>
            <% else %>
            <button
              id="toggle_draw"
              class="rounded text-white mr-2 p-2 bg-green-500 max-h-12 transition-all hover:shadow-xl hover:shadow-green-500 duration-300"
              phx-click="toggle_draw"
            >
              Draw
            </button>
              <% end %>
            <%= if @draw_mode do %>
              <button
                id="clear_canvas_button"
                class="rounded border border-black mr-2 p-2 bg-white-500 max-h-12"
                phx-hook="clear_canvas_button"
              >
                Clear
              </button>
            <% else %>
              <button
                id="dummy-clear"
                class="rounded border border-black mr-2 p-2 bg-white-500 max-h-12 opacity-50 cursor-not-allowed"
              >
                Clear
              </button>
            <% end %>
          </div>
        </div>
      </div>
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
        {:ok,
         assign(
           socket,
           loading: false,
           slides: MarkdownHelper.collect_slides(presentation.markdown_content),
           current_slide: 0,
           draw_mode: false
         )}
    end
  end

  @impl true
  def handle_event("toggle_draw", _value, socket) do
    {:noreply, assign(socket, draw_mode: not socket.assigns.draw_mode)}
  end

  @impl true
  def handle_event("slide-forth", _value, socket) do
    {:noreply, update(socket, :current_slide, &(&1 + 1))}
  end

  @impl true
  def handle_event("slide-back", _value, socket) do
    {:noreply, update(socket, :current_slide, &(&1 - 1))}
  end

  @impl true
  def handle_event(
        "handle-keypress",
        %{"key" => key},
        socket
      ) do
    current_slide = socket.assigns.current_slide
    slides = socket.assigns.slides

    case key do
      "ArrowRight" ->
        if current_slide + 1 < Enum.count(slides) do
          {:noreply, update(socket, :current_slide, &(&1 + 1))}
        else
          {:noreply, assign(socket, current_slide: current_slide)}
        end

      "ArrowLeft" ->
        if current_slide > 0 do
          {:noreply, update(socket, :current_slide, &(&1 - 1))}
        else
          {:noreply, assign(socket, current_slide: current_slide)}
        end

      _ ->
        {:noreply, assign(socket, current_slide: current_slide)}
    end
  end
end
