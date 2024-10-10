defmodule Kanta.DeepL.Plugin.TranslateAllComponent do
  @moduledoc """
  Phoenix LiveComponent for translating all messages
  """

  use Phoenix.LiveComponent

  alias Kanta.DeepL.Adapter
  alias Kanta.Translations

  require Logger

  @deepl_limit 50

  def render(assigns) do
    ~H"""
    <button type="button" phx-click="translate_all" phx-disable-with="Translating..." phx-target={@myself} class="absolute top-2 right-2 px-2 py-1 bg-primary hover:bg-primary-dark rounded text-white font-semibold">
      Translate all
    </button>
    """
  end

  def handle_event("translate_all", _, socket) do
    singular_messages =
      Translations.list_singular_translations(
        filter: %{locale_id: socket.assigns.locale_id, translated_text: :is_null},
        preloads: [:message],
        skip_pagination: true
      )

    plural_messages =
      Translations.list_plural_translations(
        filter: %{locale_id: socket.assigns.locale_id, translated_text: :is_null},
        preloads: [:message],
        skip_pagination: true
      )

    translate_all(
      singular_messages,
      socket.assigns.locale_code,
      &Translations.update_singular_translation/2
    )

    translate_all(
      plural_messages,
      socket.assigns.locale_code,
      &Translations.update_plural_translation/2
    )

    {:noreply, socket}
  end

  defp translate_all(messages, locale_code, update_fn) do
    messages
    |> Enum.chunk_every(@deepl_limit)
    |> Enum.map(&translate_batch(&1, locale_code, update_fn))
  end

  defp translate_batch(batch, locale_code, update_fn) do
    source_lang = nil
    target_lang = String.upcase(locale_code)
    texts = Enum.map(batch, & &1.message.msgid)

    case Adapter.request_translations(source_lang, target_lang, texts) do
      {:ok, translations} ->
        batch
        |> Enum.zip(translations)
        |> Enum.each(fn {message, %{"text" => translated_text}} ->
          update_fn.(message, %{"translated_text" => translated_text})
        end)

      _ ->
        Logger.error("An error occurred while translating all messages to #{locale_code}")
    end
  end
end
