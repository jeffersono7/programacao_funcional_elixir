total = 876

defmodule Mutante do
	def mutar(valor) do
		valor = 1
		total = 789
		IO.puts "interno- #{valor}" # Aqui será exibido 1 ou 876, R=1
		valor
	end
end

Mutante.mutar(total)
IO.puts "externo A-#{total}" # 876

total = Mutante.mutar(total)
IO.puts "externo B- #{total}" # 1

