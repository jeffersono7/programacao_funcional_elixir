defmodule FriendsApp do
  @moduledoc """
  Documentation for `FriendsApp`.
  """

  alias FriendsApp.CLI.Main

  def init do
    Main.start_app()
  end
end
