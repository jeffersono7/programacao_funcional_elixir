use Mix.Config

config :friends_app, csv_file_path: "#{File.cwd!}/friends.csv"

import_config "#{Mix.env}.exs"
