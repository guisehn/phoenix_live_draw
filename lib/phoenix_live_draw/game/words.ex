defmodule PhoenixLiveDraw.Game.Words do
  use GenServer

  # Client
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def sample do
    index = Enum.random(0..(size() - 1))
    [{_, word}] = :ets.lookup(__MODULE__, index)
    word
  end

  def size do
    :ets.info(__MODULE__, :size)
  end

  # Server
  @impl true
  def init(_) do
    :ets.new(__MODULE__, [:set, :protected, :named_table, read_concurrency: true])
    send(self(), :load_words)
    {:ok, nil}
  end

  @impl true
  def handle_info(:load_words, state) do
    load_words()
    {:noreply, state}
  end

  defp load_words do
    path = words_file_path()
    contents = File.read!(path)
    words = contents |> String.trim() |> String.split("\n")

    for {word, index} <- Enum.with_index(words) do
      :ets.insert(__MODULE__, {index, String.downcase(word)})
    end
  end

  defp words_file_path do
    :code.priv_dir(:phoenix_live_draw)
    |> Path.join("words.txt")
  end
end
