defmodule Mix.Tasks.Utils.AddFakeFriends do
  use Mix.Task

  alias NimbleCSV.RFC4180, as: CSVParser

  @shortdoc "Add Fake Friends on App"
  def run(_) do
    Faker.start(:pt)

    create_friends([], 50_000)
    |> CSVParser.dump_to_iodata()
    |> save_csv_file()

    IO.puts("Amigos cadastrados com sucesso!")
  end

  defp create_friends(lista, count) when count > 0 do
    lista ++ [random_list_friend()] ++ create_friends(lista, count - 1)
  end

  defp create_friends(lista, _count) do
    lista
  end

  defp random_list_friend do
    %{
      name: Faker.Person.PtBr.name(),
      email: Faker.Internet.email(),
      phone: Faker.Phone.EnUs.phone()
    }
    |> Map.values()
  end

  defp save_csv_file(data) do
    File.write!("#{File.cwd!()}/friends.csv", data, [:append])
  end
end
