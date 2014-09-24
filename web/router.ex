defmodule Vestige.Router do

  @moduledoc """
  Vestige takes git repositories and does things do them.
  It's easy to think of it as a simple remote code execution platform.


  To use it clone some project to somewhere on your
  filesystem, in the examples I use `/data/myproject/`

  ## Common use cases

  ### Test server

  Run tests on `/data/myproject` and wait for the results to come back.
  ```
  POST http://vestige/item/myproject/fetch?branch=master&origin=git://github.com/user/myproject
  POST http://vestige/build/myproject/MIX_ENV=test%20mix%20do%20deps.get,test
  POST http://vestige/build/myproject?ref=master <<BODY
    mix deps.get
    mix test
  BODY
  ```

  ### Build docker artifacts

  Run the custom `dock` task in `myproject` then push the fresh docker
  image to somewhere
  sideeffects so the build artifact will be put into a docker registry

  ```
  POST http://vestige/item/myproject/fetch?branch=master&origin=git://github.com/user/myproject
  POST http://vestige/build/myproject?ref=master <<BODY
    mix dock
    mix dock.push some-docker-resgistry:5000/myproject
  BODY
  ```
  """

  use Phoenix.Router

  get "/", Vestige.PageController, :index, as: :pages

  get "/logs/:item/:build", Vestige.LogController, :show

  post "/item", Vestige.ItemController, :create
  get  "/item/:item", Vestige.ItemController, :item
  post "/item/:item/fetch", Vestige.ItemController, :fetch

  post "/build/:item", Vestige.BuildController, :build

end
