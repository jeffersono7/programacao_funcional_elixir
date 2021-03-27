defmodule FriendsApp.DB.CSV do
  alias Mix.Shell.IO, as: Shell
  alias FriendsApp.CLI.Menu
  alias FriendsApp.CLI.Friend
  alias NimbleCSV.RFC4180, as: CSVParser

  def perform(%Menu{id: id}) do
    case id do
      :create -> create()
      :read -> read()
      :update -> update()
      :delete -> delete()
    end

    FriendsApp.CLI.Menu.Choice.start()
  end

  def perform(_), do: :error

  defp update do
    Shell.cmd("clear")

    prompt_message("Digite o email do amigo que deseja atualizar: ")
    |> search_friend_by_email()
    |> check_friend_found()
    |> confirm_update()
    |> do_update()
  end

  defp confirm_update(friend) do
    Shell.cmd("clear")
    Shell.info("Encontramos...")

    show_friend(friend)

    case Shell.yes?("Deseja realmente atualizar esse amigo?") do
      true -> friend
      false -> :error
    end
  end

  defp do_update(friend) do
    Shell.cmd("clear")
    Shell.info("Agora você irá digitar os novos dados do seu amigo...")

    update_friend = collect_data()

    get_struct_list_from_csv()
    |> delete_friend_from_struct_list(friend)
    |> friend_list_to_csv()
    |> prepare_list_to_save_csv()
    |> save_csv_file()

    update_friend
    |> transform_on_wrapped_list()
    |> prepare_list_to_save_csv()
    |> save_csv_file([:append])

    Shell.info("Amigo atualizado com sucesso!")
    Shell.prompt("Pressione ENTER para continuar")
  end

  defp delete do
    Shell.cmd("clear")

    prompt_message("Digite o email do amigo a ser excluído: ")
    |> search_friend_by_email()
    |> check_friend_found()
    |> confirm_delete()
    |> delete_and_save()
  end

  defp search_friend_by_email(email) do
    get_struct_list_from_csv()
    |> Enum.find(:not_found, fn list ->
      list.email == email
    end)
  end

  defp check_friend_found(:not_found) do
    Shell.cmd("clear")
    Shell.error("Amigo não encontrado...")
    Shell.prompt("Pressione ENTER para continuar")

    FriendsApp.CLI.Menu.Choice.start()
  end

  defp check_friend_found(friend), do: friend

  defp confirm_delete(friend) do
    Shell.cmd("clear")
    Shell.info("Encontramos...")

    show_friend(friend)

    case Shell.yes?("Deseja realmente apagar esse amigo da lista?") do
      true -> friend
      false -> :error
    end
  end

  defp show_friend(friend) do
    friend
    |> Scribe.print(data: [{"Nome", :name}, {"Email", :email}, {"Telefone", :phone}])
  end

  defp delete_and_save(:error) do
    Shell.info("Ok, o amigo NÃO será excluído...")
    Shell.info("Pressione ENTER para continuar")
  end

  defp delete_and_save(friend) do
    get_struct_list_from_csv()
    |> delete_friend_from_struct_list(friend)
    |> friend_list_to_csv()
    |> prepare_list_to_save_csv()
    |> save_csv_file()
  end

  defp delete_friend_from_struct_list(list, friend) do
    list
    |> Enum.reject(fn elem -> elem.email == friend.email end)
  end

  defp friend_list_to_csv(list) do
    list
    |> Enum.map(fn item -> [item.email, item.name, item.phone] end)
  end

  defp read do
    get_struct_list_from_csv()
    |> show_friends()
  end

  defp get_struct_list_from_csv do
    read_csv_file()
    |> parse_csv_file_to_list()
    |> csv_list_to_friend_struct_list()
  end

  defp read_csv_file do
    Application.fetch_env!(:friends_app, :csv_file_path)
    |> File.read!()
  end

  defp parse_csv_file_to_list(csv_file) do
    csv_file |> CSVParser.parse_string()
  end

  defp csv_list_to_friend_struct_list(csv_list) do
    csv_list
    |> Enum.map(fn [email, name, phone] ->
      %Friend{
        name: name,
        email: email,
        phone: phone
      }
    end)
  end

  defp show_friends(friends_list) do
    friends_list
    |> Scribe.console(data: [{"Nome", :name}, {"Email", :email}, {"Telefone", :phone}])
  end

  defp create do
    collect_data()
    |> transform_on_wrapped_list()
    |> prepare_list_to_save_csv()
    |> save_csv_file([:append])
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

  defp transform_on_wrapped_list(struct) do
    struct
    |> Map.from_struct()
    |> Map.values()
    |> wrap_in_list()
  end

  defp wrap_in_list(list) do
    [list]
  end

  defp prepare_list_to_save_csv(lista) do
    CSVParser.dump_to_iodata(lista)
  end

  defp save_csv_file(data, mode \\ []) do
    Application.fetch_env!(:friends_app, :csv_file_path)
    |> File.write!(data, mode)
  end
end
