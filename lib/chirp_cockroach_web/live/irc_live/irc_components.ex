defmodule ChirpCockroachWeb.IrcLive.IrcComponents do
  use ChirpCockroachWeb, :component
  import ChirpCockroachWeb.MultimediaComponents

  def irc_room_list(%{rooms: _} = assigns) do
    ~H"""
      <ul class="list" id="rooms-list" phx-update="stream">
      <%= for {id, room} <- @rooms do %>
        <li id={id}>
          <.link navigate={~p"/irc/#{room.id}"}><%= room.name %><span class="new"><%= Enum.count(room.users) %></span></.link>
        </li>
      <% end %>
      </ul>
      <ul class="list">
      <li>
        <.link patch={~p"/irc"}>Browse Rooms</.link>
      </li>
      <li>
        <.link patch={~p"/irc/new"}>New Room</.link>
      </li>
    </ul>
    """
  end

  def irc_messages(%{messages: _, room: _, current_user: _current_user} = assigns) do
    ~H"""
    <div>
      <.live_component
      module={ChirpCockroachWeb.IrcLive.SendMessageComponent}
      id={:new_message}
      current_user={@current_user}
      room={@room}
      message={%ChirpCockroach.Chats.Message{}}
      />
      <div class="chat">
        <div id="messages-#{@room.id}" class="messages" phx-update="stream">
          <%= for {id, message} <- @messages do %>
            <.irc_message id={id} message={message} current_user={@current_user}/>
          <% end %>
        </div>
      </div>

      </div>
    """
  end

  def irc_participants(%{users: _} = assigns) do
    ~H"""
      <ul class="users">
      <%= for user <- @users do %>
        <li><i class="fa fa-circle state-online"></i><%= user.nickname %></li>
        <%= if user.id == @current_user.id do %>
          <.camera_button id="camera">C</.camera_button>
          <.microphone_button id="stream-microphone" upload_id="stream">M</.microphone_button>

          <.multimedia_preview id={"stream-preview-#{user.id}"} />
        <% end %>
      <% end %>
    </ul>
    """
  end

  def irc_message(%{id: _, message: _} = assigns) do
    assigns =
      assigns
      |> Map.put(:message_class, irc_message_class(assigns))
      |> Map.put(:message_container_class, irc_message_container_class(assigns))

    case assigns.message.kind do
      :text ->
        ~H"""
        <div id={@id} class={@message_container_class}>
          <div class={"#{@message_class} bubble"}>
            <span class="user"><%= @message.user.nickname %></span><span>(<%= format_message_date(@message.inserted_at) %>)</span>

            <br>
            <span><%= @message.text %></span>
          </div>
        </div>
        """

      :event ->
        ~H"""
        <div id={@id} class={@message_container_class}>
          <p>
            <%= format_message_date(@message.inserted_at) %>
            <br>
            <span class="user"><%= @message.user.nickname %> </span> <%= @message.text %>
          </p>
        </div>
        """

      :voice ->
        ~H"""
        <div id={@id}>
          <div class={@message_container_class}>
          <div class={"#{@message_class} bubble"}>
          <span>[<%= format_message_date(@message.inserted_at) %>] </span> <span class="user"><%= @message.user.nickname %></span>
              <br>
                <audio controls src={Routes.static_path(ChirpCockroachWeb.Endpoint, @message.file_path)}></audio>
                <%= if @message.audio_transcription do %>
                <p class="transcription">
                <span>Transcription:</span> "<%= @message.audio_transcription %>"
              </p>
              <% end %>
            </div>
          </div>

        </div>


        """

      :image ->
        ~H"""
        <div id={@id} class={@message_container_class}>
        <span>[<%= format_message_date(@message.inserted_at) %>] </span><span class="user"><%= @message.user.nickname %></span><span> <%= @message.text || "said something..." %></span>
        <br>
          <audio controls src={Routes.static_path(ChirpCockroachWeb.Endpoint, @message.file_path)}></audio>
          <pre><%= @message.text %></pre>
        </div>
        """
    end
  end

  def irc_message_class(assigns) do
    if own_message?(assigns) do
      "message message-me"
    else
      "message message-other-user"
    end
  end

  def irc_message_container_class(%{message: %{kind: :event}}) do
    "message-container message-container-event"
  end

  def irc_message_container_class(assigns) do
    if own_message?(assigns) do
      "message-container message-container-me"
    else
      "message-container message-container-other-user"
    end
  end

  defp own_message?(%{message: %{user_id: user_id}, current_user: %{id: user_id}}) do
    true
  end

  defp own_message?(_), do: false

  def format_message_date(date) do
    Calendar.strftime(date, "%d.%m.%Y %H:%M:%S")
  end
end
