defmodule ChirpCockroachWeb.PostLive.Index do
  use ChirpCockroachWeb, :live_view

  alias ChirpCockroach.Timeline
  alias ChirpCockroach.Timeline.Post

  import ChirpCockroachWeb.TimelineComponents

  @impl true
  def mount(_params, _session, socket) do
    socket = stream_configure(socket, :posts, dom_id: &"post-#{&1.id}")

    if connected?(socket), do: Timeline.subscribe()

    {:ok, stream(socket, :posts, list_posts())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    if socket.assigns.current_user do
      socket
      |> assign(:page_title, "Edit Post")
      |> assign(:post, Timeline.get_post!(id))
    else
      push_unauthorized(socket)
    end
  end

  defp apply_action(socket, :new, _params) do
    if socket.assigns.current_user do
      socket
      |> assign(:page_title, "New Post")
      |> assign(:post, %Post{})
    else
      push_unauthorized(socket)
    end
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Posts")
    |> assign(:post, nil)
  end

  defp push_unauthorized(socket) do
    socket
    |> put_flash(:error, "Unauthorized")
    |> push_patch(to: ~p"/posts")
  end

  @impl true
  def handle_event("delete", %{"post_id" => id}, socket) do
    post = Timeline.get_post!(id)
    case Timeline.delete_post(socket.assigns.current_user, post) do
      {:ok, post} ->
        {:noreply, stream_delete(socket, :posts, post)}
      {:error, :unauthorized} ->
        push_unauthorized(socket)
    end
  end

  def handle_event("like", %{"post_id" => post_id}, socket) do
    post_id
    |> ChirpCockroach.Timeline.get_post!()
    |> ChirpCockroach.Timeline.inc_likes()

    {:noreply, socket}
  end

  def handle_event("repost", %{"post_id" => post_id}, socket) do
    post_id
    |> ChirpCockroach.Timeline.get_post!()
    |> ChirpCockroach.Timeline.inc_reposts()

    {:noreply, socket}
  end

  @impl true
  def handle_info({:post_created, post}, socket) do
    {:noreply, stream_insert(socket, :posts, post, at: 0)}
  end

  def handle_info({:post_updated, post}, socket) do
    {:noreply, stream_insert(socket, :posts, post)}
  end

  def handle_info({:post_deleted, post}, socket) do
    {:noreply, stream_delete(socket, :posts, post)}
  end



  defp list_posts do
    Timeline.list_posts()
  end
end
