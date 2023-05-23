defmodule Kanta.DeepL.Plugin.FormComponent do
  @moduledoc """
  Phoenix LiveComponent for Kanta translation form
  """

  use Phoenix.LiveComponent

  alias Kanta.DeepL.Adapter
  alias KantaWeb.Components.Shared.Select

  alias Kanta.Translations
  alias Kanta.Translations.Message

  alias Kanta.Translations.Locale.Finders.ListLocales
  alias Kanta.Translations.Locale.Finders.ListLocalesWithTranslatedMessage

  alias Kanta.Translations.SingularTranslations.Finders.GetSingularTranslation

  def render(assigns) do
    ~H"""
      <div>
        <div class="text-slate-600 dark:text-content-light font-semibold text-lg mb-2">DeepL Translator</div>
        <div class="border-b border-stone-600 mb-4" />
        <.form :let={form} for={@form} phx-change="change" phx-submit="submit" phx-target={@myself} class="space-y-4">
          <.live_component
            form={form}
            module={Select}
            id={"source_id"}
            label="Source"
            field={form["source_id"]}
            options={[%{color: "#c3c3c3", label: "Message ID", value: nil}] ++ Enum.map(@locales, & %{color: "#c3c3c3", label: &1.name, value: &1.id})}
          />
          <div>
            <label for="source_text" class="block text-sm font-bold text-slate-700 dark:text-content-light pb-1">Source text</label>
            <textarea
              disabled
              type="text"
              name="source_text"
              id="source_text"
              class="text-black font-semibold tracking-wide bg-slate-100 dark:bg-stone-700 shadow-sm focus:ring-primary focus:dark:ring-accent-dark focus:border-primary focus:dark:border-accent-dark block w-full sm:text-sm border-slate-300 rounded-md"
              ><%= @form["source_text"] %></textarea>
          </div>
          <div>
            <label for="translated_text" class="block text-sm font-bold text-slate-700 dark:text-content-light pb-1">DeepL Translation</label>
            <textarea
              type="text"
              name="translated_text"
              id="translated_text"
              class="text-black font-semibold tracking-wide bg-slate-100 dark:bg-stone-700 shadow-sm focus:ring-primary focus:dark:ring-accent-dark focus:border-primary focus:dark:border-accent-dark block w-full sm:text-sm border-slate-300 rounded-md"
              ><%= @form["translated_text"] %></textarea>
          </div>
          <div class="grid grid-cols-2 gap-4">
            <button type="button" phx-click="translate_via_deep_l" phx-target={@myself} class="col-span-1 w-full flex items-center justify-center px-4 py-4 mt-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-primary dark:bg-accent-dark hover:bg-primary-dark hover:dark:bg-accent-light focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-slate-800 focus:ring-primary focus:dark:ring-accent-dark">
              Translate
            </button>
            <button type="submit" class="col-span-1 w-full flex items-center justify-center px-4 py-4 mt-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-primary dark:bg-accent-dark hover:bg-primary-dark hover:dark:bg-accent-light focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-slate-800 focus:ring-primary focus:dark:ring-accent-dark">
              Save
            </button>
          </div>
        </.form>
      </div>
    """
  end

  def update(assigns, socket) do
    %{entries: locales, metadata: _locales_metadata} = ListLocales.find()
    locales_with_translation = ListLocalesWithTranslatedMessage.find(assigns.message)

    socket =
      socket
      |> assign_new(:form, fn ->
        %{
          "source_text" => assigns.message.msgid,
          "source_id" => nil
        }
      end)
      |> assign(:locales, locales_with_translation)

    {:ok, assign(socket, assigns)}
  end

  def handle_event("change", %{"source_id" => source_locale_id}, socket) do
    source_iso_code =
      unless is_nil(source_locale_id) do
        Enum.find(socket.assigns.locales, &(&1.id == String.to_integer(source_locale_id))).iso639_code
      end

    source_text =
      get_message_source_text(socket.assigns.message, String.to_integer(source_locale_id))

    {:noreply,
     update(
       socket,
       :form,
       &Map.merge(&1, %{
         "source_id" => source_locale_id,
         "source_text" => source_text,
         "source_iso_code" => source_iso_code
       })
     )}
  end

  def handle_event("submit", %{"translated_text" => translated}, socket) do
    locale = socket.assigns.locale
    translation = socket.assigns.translation

    Translations.update_singular_translation(translation, %{"translated_text" => translated})

    {:noreply, socket}
  end

  def handle_event("translate_via_deep_l", _, socket) do
    message = socket.assigns.message

    source_locale = (socket.assigns.form["source_iso_code"] || "en") |> String.upcase()
    source_text = socket.assigns.form["source_text"] || message.msgid

    translate_locale = socket.assigns.locale

    case Adapter.request_translation(
           source_locale,
           String.upcase(translate_locale.iso639_code),
           source_text
         ) do
      {:ok, translations} ->
        %{"text" => translated_text} = List.first(translations)

        {:noreply, update(socket, :form, &Map.merge(&1, %{"translated_text" => translated_text}))}

      _ ->
        {:noreply, socket}
    end
  end

  defp get_message_source_text(%Message{id: message_id, message_type: :singular}, locale_id) do
    {:ok, translation} =
      GetSingularTranslation.find(filter: [message_id: message_id, locale_id: locale_id])

    translation.translated_text || translation.original_text
  end
end
