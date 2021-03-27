defmodule Mix.Tasks.Utils.AddFakeFriends do
  use Mix.Task

  alias NimbleCSV.RFC4180, as: CSVParser

  @shortdoc "Add Fake Friends on App"
  def run(_) do
    time_start = Time.utc_now()

    Faker.start(:pt)

    create_friends(1_500_000)
    |> CSVParser.dump_to_iodata()
    |> save_csv_file()

    IO.puts("Amigos cadastrados com sucesso!")

    time_done = Time.utc_now()

    diff = Time.diff(time_done, time_start)
    IO.puts("\nOperação realizada em #{diff} segundos!\n")
  end

  @partitions 8
  defp create_friends(count) do
    case count > 100 do
      false ->
        create_friends([], count)

      true ->
        get_partitions(count)
        |> Enum.map(&Task.async(fn -> create_friends(&1) end))
        |> Enum.map(&Task.await(&1, 50_000))
        |> Enum.reduce(fn elem, acc -> elem ++ acc end)
    end
  end

  defp create_friends(lista, count) when count > 0 do
    ([random_list_friend()] ++ lista)
    |> create_friends(count - 1)
  end

  defp create_friends(lista, _count) do
    lista
  end

  defp get_partitions(count) do
    chunk = div(count, @partitions)

    [head_partitions_with_size | tail_partitions_with_size] =
      1..@partitions
      |> Enum.map(fn _ -> chunk end)

    resto = rem(count, @partitions)

    [head_partitions_with_size + resto | tail_partitions_with_size]
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
