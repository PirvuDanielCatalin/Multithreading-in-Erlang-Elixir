# defmodule DragonStrategy do
#   @callback init(state :: term) ::
#               {:ok, new_state :: term} |
#               {:error, reason :: term}

#   @callback perform(args :: term, state :: term) ::
#               {:ok, result :: term, new_state :: term} |
#               {:error, reason :: term, new_state :: term}
# end

defmodule DragonStrategy do

  def init_hp(initial_hp) do
    Agent.start_link(fn -> initial_hp end, name: HP)
  end

  def get_hp do
    Agent.get(HP, fn (x) -> x end)
  end

  def update_hp(value) do
    Agent.get_and_update(HP, fn (x) -> {x + value, x + value} end)
  end
end

defmodule Dragon do
  import DragonStrategy

  def run do
    DragonStrategy.init_hp(1000)
    Dragon_HP = DragonStrategy.get_hp
    IO.inspect Dragon_HP

    DragonStrategy.update_hp(20)
    IO.inspect Dragon_HP
  end

  def get_rand do
    IO.puts :rand.uniform(50) + 50
  end
end
