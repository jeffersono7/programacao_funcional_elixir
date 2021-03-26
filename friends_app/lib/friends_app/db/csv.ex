defmodule FriendsApp.DB.CSV do
  alias Mix.Shell.IO, as: Shell
  alias FriendsApp.CLI.Menu

  def perform(%Menu{id: id}) do
    case id do
      :create -> Shell.info(">>> CREATE <<<")
      :read -> Shell.info(">>> READ <<<")
      :update -> Shell.info(">>> UPDATE <<<")
      :delete -> Shell.info(">>> DELETE <<<")
    end
  end

  def perform(_), do: :error
end
