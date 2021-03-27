defmodule FriendsApp.DB.CSV do
  alias Mix.Shell.IO, as: Shell
  alias FriendsApp.CLI.Menu
  alias FriendsApp.CLI.Friend
  alias NimbleCSV.RFC4180, as: CSVParser

  def perform(%Menu{id: id}) do
    case id do
      :create -> create()
      :read -> read()
      :update -> Shell.info(">>> UPDATE <<<")
      :delete -> Shell.info(">>> DELETE <<<")
    end

    FriendsApp.CLI.Menu.Choice.start()
  end

  def perform(_), do: :error

  defp read do
    Application.fetch_env!(:friends_app, :csv_file_path)
    |> File.read!()
    |> CSVParser.parse_string(headers: false)
    |> Enum.map(fn [email, name, phone] ->
      %Friend{
        name: name,
        email: email,
        phone: phone
      }
    end)
    |> Scribe.console(data: [{"Nome", :name}, {"Email", :email}, {"Telefone", :phone}])
  end

  defp create do
    collect_data()
    |> Map.from_struct()
    |> Map.values()
    |> wrap_in_list()
    |> CSVParser.dump_to_iodata()
    |> save_csv_file()
  end

  defp collect_data do
    Shell.cmd("clear")

    %Friend{
      name: prompt_message("Digite o nome: "),
      email: prompt_message("Digite o email: "),
      phone: prompt_message("Digite o phone: ")
    }
  end

  defp prompt_message(message) do
    Shell.prompt(message)
    |> String.trim()
  end

  defp wrap_in_list(list) do
    [list]
  end

  defp save_csv_file(data) do
    Application.fetch_env!(:friends_app, :csv_file_path)
    |> File.write!(data, [:append])
  end
end
