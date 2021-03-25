defmodule Mix.Tasks.Start do
  use Mix.Task

  alias FriendsApp.CLI.Main

  @shortdoc "Start [Friends App]"
  def run(_), do: Main.start_app()
end
