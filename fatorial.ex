defmodule Factorial do

	def of(n, state \\ 1) when n <= 1, do: state
	
	def of(n, state) do
		of(n-1, state * n)
	end
end

