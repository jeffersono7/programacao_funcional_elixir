defmodule FriendsApp.CLI.MainTest do
  use ExUnit.Case, async: true

  alias ExUnit.{CaptureIO}
  alias FriendsApp.CLI.Main

  describe "start_app/1" do
    test "when invoke function should print welcome message with menu itens" do
      result = CaptureIO.capture_io("1\n", fn -> Main.start_app() end )

      assert String.contains?(result, "Seja bem-vindo")
    end
  end
end
