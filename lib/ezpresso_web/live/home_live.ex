defmodule EzpressoWeb.HomeLive do
  alias EzpressoWeb.Helpers.MarkdownHelper
  alias Ezpresso.Presentations
  use EzpressoWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col">
      <div>
        <div class="text-3xl p-2 flex flex-row">
          <h1 class="underline decoration-pink-500">Ezpresso</h1>
          <h1>☕</h1>
        </div>
        <div class="border-l border-pink-500 rounded bg-gradient-to-r from-slate-100">
          <q class="pl-2 italic"> The worlds (easiest*) markdowniest presentation tool </q>
          <p class="pl-2 text-[10px]">*not supported by any scientific facts</p>
        </div>
      </div>

      <%= if @current_user do %>
        <div class="mt-8">
          <div>
            <h2 class="text-2xl mb-4">Your presentations</h2>
          </div>
          <div class="flex flex-wrap">
            <ul class="flex flex-wrap list-none">
              <%= for presentation <- @presentations do %>
                <a class="p-2 w-1/3 min-h-40" href={"/editor/" <> Integer.to_string(presentation.id) }>
                  <li class="flex flex-col min-h-60 bg-white-800 border-2 border-black rounded transition-all hover:shadow-2xl hover:-translate-y-1 hover:-translate-x-1 duration-300">
                    <div class="w-full min-h-full">
                      <div class="min-h-36 bg-green-200">
                        <article class="ml-1 prose prose-sm prose-a:text-blue-600 descendant:dark:text-white">
                          <%= raw(hd(MarkdownHelper.collect_slides(presentation.markdown_content))) %>
                        </article>
                      </div>
                      <div>
                        <%= presentation.title %>
                      </div>
                    </div>
                  </li>
                </a>
              <% end %>
            </ul>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    %{current_user: user} = socket.assigns
    presentations = Presentations.all_by_user(user)
    IO.puts("\n\n\n" <> inspect(presentations) <> "\n\n\n")
    {:ok, assign(socket, :presentations, presentations)}
  end
end
