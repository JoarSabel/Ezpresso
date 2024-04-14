defmodule EzpressoWeb.Helpers.MarkdownHelper do
  import Earmark
  
  def render_markdown(markdown) do
    markdown
    |> Earmark.as_html!(escape: false, inner_html: true, compact_output: false)
  end

  def collect_slides(blob) do
    String.split(blob, "---")
    |> Enum.map(&render_markdown/1)
  end
end
