defmodule ChirpCockroachWeb.MultimediaComponents do
  use Phoenix.Component

  attr :id, :string, required: true
  attr :media_streams, :any, required: true
  attr :current_user, :any, required: true
  def video_call(assigns) do
    ~H"""
      <div class="video-grid" id="media_streams" phx-update="stream">
        <%= for {id, media_stream} <- @media_streams do %>
          <div id={id}>
            <%= if media_stream.user_id != @current_user.id do %>
              <.peer_video peer_id={media_stream.peer_id} />
              <h4><%= media_stream.name %></h4>
            <% else %>
              <.multimedia_preview id="preview" />
              <h4>You</h4>
              <% end %>
          </div>
        <% end %>
    </div>
    """
  end


  attr :id, :string, required: true
  slot :inner_block, required: true
  @spec camera_button(map()) :: Phoenix.LiveView.Rendered.t()
  def camera_button(assigns) do
    ~H"""
    <button id={@id} phx-hook="cameraControl">
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  attr :id, :string, required: true
  attr :upload_id, :string, required: true
  slot :inner_block, required: true
  def microphone_button(assigns) do
    ~H"""
    <button id={@id} phx-hook="microphone" data-upload={@upload_id} data-endianness={System.endianness()}>
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  attr :id, :string, required: true
  def multimedia_preview(assigns) do
    ~H"""
      <video id={@id} phx-hook="previewVideo" style="width: 180px; height: 140px; border: 1px solid orange;"/>
    """
  end

  attr :peer_id, :string, required: true
  def peer_video(assigns) do
    ~H"""
      <video id="peer-#{peer_id}"  phx-hook="peerVideo" data-peer_id={@peer_id} style="width: 180px; height: 140px; border: 1px solid orange;" />
    """
  end
end
