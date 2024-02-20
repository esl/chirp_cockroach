defmodule ChirpCockroachWeb.PostLive.PostComponent do
  use ChirpCockroachWeb, :live_component

  def render(assigns) do
    ~H"""
    <div id={@id} class="post">
      <script>
      </script>
      <div class="card">
        <div class="card-body">
          <div class="row">
            <div class="col col-10">
              <div class="post-avatar"></div>
            </div>
            <div class="col col-9 post-body">
              <b>@<%= @post.username %></b>
              <br/>
              <%= @post.body%>
            </div>
          </div>
          <div class="row">
            <div class="col">
              <a href="#" phx-click="like" phx-target={@myself}>
                <i class="far fa-heart"></i> <%= @post.likes_count %>
              </a>
            </div>
            <div class="col">
              <a href="#" phx-click="repost" phx-target={@myself}>
                <i class="fas fa-retweet"></i> <%= @post.reposts_count %>
              </a>
            </div>
            <div class="col">
              <.link id={"post-#{@post.id}-edit"} patch={Routes.post_index_path(@socket, :edit, @post.id)}>
                <i class="far fa-edit"></i>
              </.link>
              <%= link to: "#", id: "post-#{@post.id}-delete", phx_click: "delete", phx_value_id: @post.id, data: [confirm: "Are you sure?"] do %>
              <i class="far fa-trash-alt"></i>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("like", _, socket) do
    ChirpCockroach.Timeline.inc_likes(socket.assigns.post)
    {:noreply, socket}
  end

  def handle_event("repost", _, socket) do
    ChirpCockroach.Timeline.inc_reposts(socket.assigns.post)
    {:noreply, socket}
  end
end
