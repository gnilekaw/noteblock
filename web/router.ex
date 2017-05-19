defmodule Noteblock.Router do
  use Noteblock.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", Noteblock do
    pipe_through :browser # Use the default browser stack

    get "/verify_ledger", BlockController, :verify_ledger

    resources "/", BlockController, param: "hash"
  end
end
