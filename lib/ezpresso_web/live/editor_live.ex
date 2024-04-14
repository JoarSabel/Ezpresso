defmodule EzpressoWeb.EditorLive do
  alias EzpressoWeb.Helpers.MarkdownHelper
  use EzpressoWeb, :live_view
  alias Earmark

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full ">
      <.form class="flex flex-row">
        <div class="w-1/2 flex flex-col p-4">
          <h2 class="text-xl mb-2">Markdown Editor</h2>
          <textarea
            id="markdown-editor"
            name="markdown-content"
            rows="30"
            class="w-full border rounded p-2"
            phx-change="update-markdown"
            phx-debounce="500"
            phx-target="#preview"
          ><%= @markdown %></textarea>
        </div>
        <div class="w-1/2 flex flex-col p-4 max-h-[50rem]">
          <h2 class="text-xl mb-2">Preview</h2>
          <div class="overflow-scroll">
            <%= for slide_html <- @slides_html do %>
              <div id="preview" name="preview" class="border rounded p-4 mb-4 min-h-60">
                <article class="prose prose-a:text-blue-600 descendant:dark:text-white">
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
  def mount(_params, _session, socket) do
    tmp = "# Slide One\n\n>Quote of the day \n\n---\n\n# Slide Two\n\nContent"
    # {:ok, assign(socket, markdown: tmp, html: MarkdownHelper.render_markdown(tmp))}
    {:ok, assign(socket, markdown: tmp, slides_html: MarkdownHelper.collect_slides(tmp))}
  end

  @impl true
  def handle_event("update-markdown", %{"markdown-content" => markdown}, socket) do
    # res = MarkdownHelper.render_markdown(markdown)
    # {:noreply, assign(socket, markdown: markdown, html: res)}
    {:noreply,
     assign(socket, markdown: markdown, slides_html: MarkdownHelper.collect_slides(markdown))}
  end
end
