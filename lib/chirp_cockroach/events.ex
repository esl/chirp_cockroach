defmodule ChirpCockroach.Events do
  require Logger
  def publish(event) do
    Logger.info("Event processed: #{inspect(event)}")
    ChirpCockroach.Chats.EventHandler.handle(event)
  end
end
