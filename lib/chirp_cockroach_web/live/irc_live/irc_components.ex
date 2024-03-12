defmodule ChirpCockroachWeb.IrcLive.IrcComponents do
  use ChirpCockroachWeb, :component

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
    <div class="container">
    <div class="chat">
      <div id="messages-#{@room.id}" class="messages" phx-update="stream">
        <%= for {id, message} <- @messages do %>
          <.irc_message id={id} message={message} current_user={@current_user}/>
        <% end %>
      </div>
    </div>
    <.live_component
    module={ChirpCockroachWeb.IrcLive.SendMessageComponent}
    id={:new_message}
    current_user={@current_user}
    room={@room}
    message={%ChirpCockroach.Chats.Message{}}
    />
    </div>
    """
  end

  def irc_participants(%{users: _} = assigns) do
    ~H"""
      <ul class="users">
      <%= for user <- @users do %>
        <li><i class="fa fa-circle state-online"></i><%= user.nickname %></li>
      <% end %>
    </ul>
    """
  end

  def irc_message(%{id: _, message: _} = assigns) do
    assigns = Map.put(assigns, :class, irc_message_class(assigns))

    case assigns.message.kind do
      :text ->
        ~H"""
        <div id={@id} class={"#{@class} bubble"}>
          <span>[<%= format_message_date(@message.inserted_at) %>] </span> <span class="user"><%= @message.user.nickname %></span>
          <br>
          <span class="bubble"><%= @message.text %></span>
        </div>
        """

      :event ->
        ~H"""
        <div id={@id} class={@class}>
        <span>[<%= format_message_date(@message.inserted_at) %>] </span><span class="user"><%= @message.user.nickname %> </span> <span><%= @message.text %></span>
        </div>
        """

      :voice ->
        ~H"""
        <div id={@id} class={"#{@class} bubble"}>
        <span>[<%= format_message_date(@message.inserted_at) %>] </span><span class="user"><%= @message.user.nickname %></span>
        <br>
          <audio controls src={Routes.static_path(ChirpCockroachWeb.Endpoint, @message.file_path)}></audio>
          <pre><%= @message.text %></pre>
        </div>
        """

      :image ->
        ~H"""
        <div id={@id} class={"#{@class} bubble"}>
        <span>[<%= format_message_date(@message.inserted_at) %>] </span><span class="user"><%= @message.user.nickname %></span><span> <%= @message.text || "said something..." %></span>
        <br>
          <audio controls src={Routes.static_path(ChirpCockroachWeb.Endpoint, @message.file_path)}></audio>
          <pre><%= @message.text %></pre>
        </div>
        """
    end
  end

  def irc_message_class(%{message: %{user_id: user_id}, current_user: %{id: user_id}}) do
    "message me"
  end

  def irc_message_class(_), do: "message"

  def format_message_date(date) do
    Calendar.strftime(date, "%d.%m.%Y %H:%M:%S")
  end
end
