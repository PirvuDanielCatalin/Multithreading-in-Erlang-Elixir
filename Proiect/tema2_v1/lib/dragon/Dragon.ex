defmodule Dragon do
  use Agent

  ##################################
  ### Dragon HP ###
  ##################################
  def init_hp(initial_hp) do
    Agent.start_link(fn -> initial_hp end, name: D_HP_PID)
  end

  def get_hp do
    Agent.get(D_HP_PID, fn (dragon_hp) -> dragon_hp end)
  end

  def update_hp(dmg) do
    Agent.get_and_update(D_HP_PID, fn (dragon_hp) -> {dragon_hp - dmg, dragon_hp - dmg} end)
  end

  ##################################
  ### Main PID ###
  ##################################
  def init_main_pid(main_pid) do
    Agent.start_link(fn -> main_pid end, name: D_MAIN_PID)
  end

  def get_main_pid() do
    Agent.get(D_MAIN_PID, fn (x) -> x end)
  end

  def receive_main_pid() do
    receive do
      {:main_pid, main_pid} -> Dragon.init_main_pid(main_pid)
    end

    main_pid = Dragon.get_main_pid()
    if main_pid == nil do
      Dragon.receive_main_pid()
    end
  end

  ##################################
  ### Necromancer PID ###
  ##################################
  def init_necromancer_pid(necromancer_pid) do
    Agent.start_link(fn -> necromancer_pid end, name: D_NECROMANCER_PID)
  end

  def get_necromancer_pid() do
    Agent.get(D_NECROMANCER_PID, fn (x) -> x end)
  end

  def receive_necromancer_pid() do
    receive do
      {:necromancer_pid, necromancer_pid} -> Dragon.init_necromancer_pid(necromancer_pid)
    end

    necromancer_pid = Dragon.get_necromancer_pid()
    if necromancer_pid == nil do
      Dragon.receive_necromancer_pid()
    end
  end

  ##################################
  ### Dragon Actions ###
  ##################################
  def dragon_attack(type, dmg) do
    victim = Dragon.get_necromancer_pid()
    # victim = // Alegere pid victima // Necromancer/Zombie/Archer

    case type do
      :whiptail ->
        IO.puts "Dragonul ataca cu Whiptail de #{dmg} damage."
        send victim, {:from_d_dragon_attack, dmg}

      :dragon_breath ->
        IO.puts "Dragonul ataca cu Dragon Breath de #{dmg} damage."

        # send necromancer_pid, {:dragon_attack, dmg}

        # For each zombie knight
        # send zb_knight, {:dragon_attack, dmg}

        # For each zombie archer
        # send za_knight, {:dragon_attack, dmg}
    end
  end

  def dragon_win() do
    main_pid = Dragon.get_main_pid()
    remaining_hp = Dragon.get_hp()
    send main_pid, {:dragon_wins, remaining_hp}
  end

  ##################################
  ### Receive Loop ###
  ##################################
  def receive_loop() do
    receive do
      {:from_ds_whiptail, dmg} -> Dragon.dragon_attack(:whiptail, dmg)
      {:from_ds_dragon_breath, dmg} -> Dragon.dragon_attack(:dragon_breath, dmg)
      {:from_n_necromancer_attack, dmg} -> Dragon.update_hp(dmg)
      {:from_n_necromancer_lost, _x} -> Dragon.dragon_win()
    end

    d_hp = Dragon.get_hp()
    if d_hp >= 0 do
      Dragon.receive_loop()
    else
      IO.puts "Sa-i fie tarana usoara Dragonului!"
      necromancer_pid = Dragon.get_necromancer_pid()
      send necromancer_pid, {:from_d_dragon_lost, 0}
    end
  end

  ##################################
  ### Main ###
  ##################################
  def run() do
    Dragon.init_hp(1000000)

    # hp = Dragon.get_hp()
    # IO.inspect hp

    Dragon.receive_main_pid()
    Dragon.receive_necromancer_pid()

    Dragon.receive_loop()
  end
end
