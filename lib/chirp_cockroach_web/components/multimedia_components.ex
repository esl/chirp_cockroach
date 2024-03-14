defmodule ChirpCockroachWeb.MultimediaComponents do
  use Phoenix.Component

  attr :id, :string, required: true
  attr :media_streams, :any, required: true
  attr :current_user, :any, required: true
  attr :join_event, :string, default: nil
  def video_call(assigns) do
    ~H"""
      <div>
        <%= if @join_event do %>
          <button id="start-stream-#{id}" phx-click={@join_event} phx-hook="setPeerId">Start Stream</button>
          <.camera_button id="camera">Enable Camera</.camera_button>
          <.microphone_button id="stream-microphone" upload_id="audio_file" control_stream={"enabled"}>Enable Microphone</.microphone_button>
        <% end %>
        <div class="video-grid" id="media_streams" phx-update="stream">
          <%= for {id, media_stream} <- @media_streams do %>
            <div id={id}>
              <%= if media_stream.user_id != @current_user.id do %>
                <.peer_video peer_id={media_stream.peer_id} />
                <h4><%= media_stream.name %></h4>
              <% else %>
                <.multimedia_preview id={"stream-preview-#{@current_user.id}"} />
                <h4>You</h4>
                <% end %>
            </div>
          <% end %>
        </div>
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
  attr :upload_id, :string, default: "false"
  attr :control_stream, :string, default: "false"
  slot :inner_block, required: true
  def microphone_button(assigns) do
    ~H"""
    <button id={@id} phx-hook="microphoneControl" data-control_stream={@control_stream} data-upload={@upload_id} data-endianness={System.endianness()}>
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
