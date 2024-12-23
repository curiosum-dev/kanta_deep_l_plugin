defmodule Kanta.DeepL.Adapter do
  @moduledoc """
  DeepL API adapter

  We use XML tag handling to avoid translating the content of curly brackets.
  These curly brackets are used by gettext for variable substitution.
  They look like this:

  ```
  price = Money.new(1000, "EUR")
  gettext("Price: %{price}", price: price)
  ```
  """

  use Tesla

  plug(Tesla.Middleware.BaseUrl, "https://api-free.deepl.com")

  plug(Tesla.Middleware.Headers, [
    {"Authorization", "DeepL-Auth-Key #{deep_l_api_key()}"}
  ])

  plug(Tesla.Middleware.JSON)

  def request_translation(source_lang, target_lang, text, context_name) do
    request_translations(source_lang, target_lang, [text], context_name)
  end

  def request_translations(source_lang, target_lang, texts, context_name) do
    texts = Enum.map(texts, &replace_curly_brackets_with_xml_tags/1)

    post("/v2/translate", %{
      source_lang: source_lang,
      target_lang: target_lang,
      context: context_name,
      tag_handling: "xml",
      ignore_tags: ["gettext_variable"],
      text: texts
    })
    |> case do
      {:ok, %Tesla.Env{body: %{"translations" => translations}}} ->
        translations
        |> Enum.map(fn translation ->
          Map.update!(translation, "text", &replace_xml_tags_with_curly_brackets/1)
        end)
        |> then(&{:ok, &1})

      {_, %Tesla.Env{body: body, status: status}} ->
        {:error, status, body}

      error ->
        {:error, error}
    end
  end

  def usage do
    get("/v2/usage")
    |> case do
      {:ok, %Tesla.Env{body: body}} -> {:ok, body}
      {_, %Tesla.Env{body: body, status: status}} -> {:error, status, body}
      error -> {:error, error}
    end
  end

  defp deep_l_api_key do
    case Enum.find(Kanta.config().plugins, &(elem(&1, 0) == Kanta.DeepL.Plugin)) do
      nil -> raise "missing DeepL API key"
      {_, config} -> Keyword.get(config, :api_key)
    end
  end

  defp replace_curly_brackets_with_xml_tags(text) do
    Regex.replace(~r/%{(.*)}/, text, fn _, x -> "<gettext_variable>#{x}</gettext_variable>" end)
  end

  defp replace_xml_tags_with_curly_brackets(text) do
    Regex.replace(~r/<gettext_variable>(.*)<\/gettext_variable>/, text, fn _, x -> "%{#{x}}" end)
  end
end
