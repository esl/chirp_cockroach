defmodule ChirpCockroachWeb.TimelineComponents do
  use ChirpCockroachWeb, :component

  attr :id, :string, required: true
  attr :post, ChirpCockroach.Timeline.Post, required: true
  def post(assigns) do
    ~H"""
    <div id={@id} class="post">
      <div class="card">
        <div class="card-body">
          <div class="row">
            <div class="col col-10">
              <div class="post-avatar"></div>
            </div>
            <div class="col col-9 post-body">
              <b>@<%= @post.user.nickname %></b>
              <br/>
              <%= @post.body%>
            </div>
          </div>
          <div class="row">
            <div class="col">
              <a href="#" phx-click="like">
                <i class="far fa-heart"></i> <%= @post.likes_count %>
              </a>
            </div>
            <div class="col">
              <a href="#" phx-click="repost">
                <i class="fas fa-retweet"></i> <%= @post.reposts_count %>
              </a>
            </div>
            <div class="col">
              <.link id={"post-#{@post.id}-edit"} patch={~p"/posts/#{@post.id}/edit"}>
                <i class="far fa-edit"></i>
              </.link>
              <.link
                  id={"post-#{@post.id}-delete"}
                  phx-click="delete"
                  phx-value-post_id={@post.id}
                  data-confirm="Are you sure?">
                <i class="far fa-trash-alt"></i>
              </.link>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
