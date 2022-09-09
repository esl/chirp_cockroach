# ChirpCockroach

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix


## TODO

- add setup readme
- maybe implement Changefeed messages https://www.cockroachlabs.com/docs/stable/changefeed-messages.html
- changefeed -> create separate channel and publish statistics
- check out scaffold, podman or kind to use with deployment and implement
- add info about docker volumes prune

## CDC pipeline
- new component on page with statistics: total likes, total retweets
- connected to live view event
- when like/retweet use changedfeed to track data and update counter via webhook
- update info on DB and send to live view
