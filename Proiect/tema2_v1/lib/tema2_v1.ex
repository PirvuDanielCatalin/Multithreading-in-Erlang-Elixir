defmodule Tema2V1 do
  import Dragon
  import DragonStrategy

  def main_receive_loop() do
    receive do
      {:dragon_wins, dragon_remaining_hp} ->
        IO.puts "A castigat dragonul si a ramas cu #{dragon_remaining_hp} cantitate de viata."
      {:necromancer_wins, necromancer_remaining_hp} ->
        IO.puts "A castigat necromancer-ul si a ramas cu #{necromancer_remaining_hp} cantitate de viata."
    end

    main_receive_loop()
  end

  @doc """
    Tema2V1.main()
  """
  def main do
    main_pid = self()
    # IO.inspect main_pid

    d_pid = spawn(Dragon, :run, [])
    send d_pid, {:main_pid, main_pid}

    ds_pid = spawn(DragonStrategy, :run, [])
    send ds_pid, {:dragon_pid, d_pid}

    # Tema2V1.main_receive_loop()
  end
end

