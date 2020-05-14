defmodule Tema2V1 do
  # import Dragon
  # import DragonStrategy
  # import Necromancer
  # import NecromancerStrategy

  def main_receive_loop() do
    receive do
      {:dragon_wins, dragon_remaining_hp} ->
        IO.puts "A castigat dragonul si a ramas cu #{dragon_remaining_hp} cantitate de viata."

      {:necromancer_wins, necromancer_remaining_hp} ->
        IO.puts "A castigat necromancer-ul si a ramas cu #{necromancer_remaining_hp} cantitate de viata."
    end

    main_receive_loop()
  end

  ##################################
  ### Main ###
  ##################################
  def main do
    main_pid = self()
    # IO.inspect main_pid

    d_pid = spawn(Dragon, :run, [])
    send d_pid, {:main_pid, main_pid}

    ds_pid = spawn(DragonStrategy, :run, [])
    send ds_pid, {:dragon_pid, d_pid}

    n_pid = spawn(Necromancer, :run, [])
    send n_pid, {:main_pid, main_pid}

    ns_pid = spawn(NecromancerStrategy, :run, [])
    send ns_pid, {:dragon_pid, n_pid}

    Tema2V1.main_receive_loop()
  end
end

## Tema2V1.main()
