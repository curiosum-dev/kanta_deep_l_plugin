defmodule Kanta.DeepL.Plugin.DashboardComponent do
  @moduledoc """
  Phoenix LiveComponent for Kanta dashboard
  """

  use Phoenix.LiveComponent

  alias Kanta.DeepL.Adapter

  def render(assigns) do
    ~H"""
      <div class="col-span-2">
        <div class="bg-white dark:bg-stone-900 overflow-hidden shadow rounded-lg">
          <div class="flex flex-col items-center justify-center px-4 py-5 sm:p-6">
            <div class="text-3xl font-bold text-primary dark:text-accent-light"><%= @deep_l_usage %>%</div>
            <div class="text-slate-600 dark:text-content-light font-medium text-lg">DeepL Usage</div>
          </div>
        </div>
      </div>
    """
  end

  def update(assigns, socket) do
    {:ok, %{"character_count" => character_count, "character_limit" => character_limit}} =
      Adapter.usage()

    socket =
      socket
      |> assign(:deep_l_usage, Float.ceil(character_count / character_limit, 2))

    {:ok, assign(socket, assigns)}
  end
end
