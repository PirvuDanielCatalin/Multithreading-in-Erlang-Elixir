defmodule Dragon do
  use Agent

  def init_hp(initial_hp) do
    Agent.start_link(fn -> initial_hp end, name: D_HP_PID)
  end

  def get_hp do
    Agent.get(D_HP_PID, fn (dragon_hp) -> dragon_hp end)
  end

  def update_hp(dmg) do
    Agent.get_and_update(D_HP_PID, fn (dragon_hp) -> {dragon_hp - dmg, dragon_hp - dmg} end)
  end

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

  def dragon_attack(type, dmg) do
    # victim = // Alegere pid victima // Necromancer/Zombie/Archer
    if type == 1 do
      IO.puts "Dragonul ataca cu Whiptail de #{dmg} damage."
      # send necromancer_pid, {:dragon_attack, dmg}
    else
      if type == 2 do
        IO.puts "Dragonul ataca cu Dragon Breath de #{dmg} damage."

        # send necromancer_pid, {:dragon_attack, dmg}

        # For each zombie knight
        # send zb_knight, {:dragon_attack, dmg}

        # For each zombie archer
        # send za_knight, {:dragon_attack, dmg}
      end
    end

  end

  def receive_loop() do
    receive do
      {:from_ds_whiptail, dmg} -> dragon_attack(1, dmg)
      {:from_ds_dragon_breath, dmg} -> dragon_attack(2, dmg)
    end

    d_hp = Dragon.get_hp()
    if d_hp >= 0 do
      Dragon.receive_loop()
    else
      IO.puts "Sa-i fie tarana usoara Dragonului!"
      # necromancer_pid = Dragon.get_necromancer_pid()
      # remaining_hp = Dragon.get_hp()
      # send necromancer_pid, {:dragon_lost, remaining_hp}
    end
  end

  def run() do
    Dragon.init_hp(1000)

    # hp = Dragon.get_hp()
    # IO.inspect hp

    Dragon.receive_main_pid()
    # Dragon.receive_necromancer_pid()
    Dragon.receive_loop()
  end
end
