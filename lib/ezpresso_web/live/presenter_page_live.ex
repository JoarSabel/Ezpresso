defmodule EzpressoWeb.PresenterPageLive do
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
      id="fullscreen-container"
      phx-hook="FullscreenToggle"
      phx-window-keydown="handle-keypress"
    >
      <div class="flex flex-col min-h-full">
        <div class="flex min-h-[65vh] justify-center content-center text-center items-center relative">
          <%= if assigns.is_fullscreen do %>
            <div id="presenter-mode-dropdown-container" class="relative inline-block z-30">
              <div id="dropdown-content" class="absolute right-0 mt-2">
                <button
                  id="fullscreen-toggle-draw-button"
                  class="block w-full mb-2 p-4 text-left rounded-full border text-lg text-gray-700 hover:bg-gray-100 transition duration-300 hover:-translate-x-1 hover:-translate-y-1"
                  phx-click="toggle_draw"
                >
                  🖊️
                </button>
                <button
                  id="fullscreen-toggle-erase-button"
                  class="block w-full text-left p-4 rounded-full border text-lg text-gray-700 hover:bg-gray-100 transition duration-300 hover:-translate-x-1 hover:-translate-y-1"
                  phx-click="toggle_draw"
                >
                  💥
                </button>
              </div>
            </div>
          <% end %>
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
        <!-- Button Row -->
        <%= if not assigns.is_fullscreen do %>
          <div class="flex flex-row w-full">
            <div class="flex flex-row justify-center items-end min-h-[10vh]">
              <%= if @current_slide > 0 do %>
                <button
                  class="rounded border border-black mr-2 p-2 bg-white-500 max-h-12"
                  phx-click="slide-back"
                >
                  &lt-
                </button>
              <% else %>
                <button class="rounded border border-black mr-2 p-2 bg-white-500 max-h-12 opacity-50 cursor-not-allowed">
                  &lt-
                </button>
              <% end %>
              <%= if @slides |> Enum.count() > @current_slide + 1 do %>
                <button
                  class="rounded border border-black mr-2 p-2 bg-white-500 max-h-12"
                  phx-click="slide-forth"
                >
                  -&gt
                </button>
              <% else %>
                <button class="rounded border border-black mr-2 p-2 bg-white-500 opacity-50 cursor-not-allowed max-h-12">
                  -&gt
                </button>
              <% end %>
            </div>
            <span class="flex grow"></span>
            <div class="flex items-end">
              <button class="group  transition-all duration-300 ease-in-out pr-4" phx-click="conf">
                <span class="bg-left-bottom bg-gradient-to-r from-blue-500 to-blue-500 bg-[length:0%_2px] bg-no-repeat group-hover:bg-[length:100%_2px] transition-all duration-500 ease-out">
                  🔧 Conf
                </span>
              </button>
              <button
                class="group transition-all duration-300 ease-in-out"
                phx-click="toggle-fullscreen"
              >
                <span class="bg-left-bottom bg-gradient-to-r from-pink-500 to-pink-500 bg-[length:0%_2px] bg-no-repeat group-hover:bg-[length:100%_2px] transition-all duration-500 ease-out">
                  Present 🎬
                </span>
              </button>
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
        <% end %>
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
           presentation_id: presentation.id,
           slides: MarkdownHelper.collect_slides(presentation.markdown_content),
           current_slide: 0,
           draw_mode: false,
           is_fullscreen: false
         )}
    end
  end

  @impl true
  def handle_event("conf", _value, socket) do
    socket =
      socket
      |> push_navigate(to: ~p"/editor/#{socket.assigns.presentation_id}")

    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_draw", _value, socket) do
    {:noreply, assign(socket, draw_mode: not socket.assigns.draw_mode)}
  end

  @impl true
  def handle_event("toggle-fullscreen", _value, socket) do
    case socket.assigns.is_fullscreen do
      # realistically this will never fire
      true ->
        socket =
          socket
          |> assign(:is_fullscreen, false)
          |> push_event("toggle-fullscreen", %{action: "exit"})

        {:noreply, socket}

      false ->
        socket =
          socket
          |> assign(:is_fullscreen, true)
          |> push_event("toggle-fullscreen", %{action: "enter"})

        {:noreply, socket}

      # realistically this will never fire 
      nil ->
        socket =
          socket
          |> assign(:is_fullscreen, true)
          |> push_event("toggle-fullscreen", %{action: "enter"})

        {:noreply, socket}
    end
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

      # I love that browsers don't register keypresses when fullscreen mode is on 
      # even thought keypresses can take you out of fullscreen mode 
      "Escape" ->
        if socket.assigns.is_fullscreen do
          socket =
            socket
            |> assign(:is_fullscreen, false)
            |> push_event("toggle-fullscreen", %{action: "exit"})

          {:noreply, socket}
        else
          {:noreply, socket}
        end

      _ ->
        {:noreply, assign(socket, current_slide: current_slide)}
    end
  end
end
