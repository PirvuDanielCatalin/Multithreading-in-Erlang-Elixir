defmodule Dragon do
  use Agent

  ##################################
  ### Dragon HP ###
  ##################################
  def init_hp(initial_hp) do
    Agent.start_link(fn -> initial_hp end, name: D_HP_PID)
  end

  def get_hp do
    Agent.get(D_HP_PID, fn dragon_hp -> dragon_hp end)
  end

  def update_hp(dmg) do
    Agent.get_and_update(D_HP_PID, fn dragon_hp -> {dragon_hp - dmg, dragon_hp - dmg} end)
  end

  ##################################
  ### Main PID ###
  ##################################
  def init_main_pid(main_pid) do
    Agent.start_link(fn -> main_pid end, name: D_MAIN_PID)
  end

  def get_main_pid() do
    Agent.get(D_MAIN_PID, fn x -> x end)
  end

  def receive_main_pid() do
    receive do
      {:main_pid, main_pid} -> Dragon.init_main_pid(main_pid)
    end
  end

  ##################################
  ### Necromancer PID ###
  ##################################
  def init_necromancer_pid(necromancer_pid) do
    Agent.start_link(fn -> necromancer_pid end, name: D_NECROMANCER_PID)
  end

  def get_necromancer_pid() do
    Agent.get(D_NECROMANCER_PID, fn x -> x end)
  end

  def receive_necromancer_pid() do
    receive do
      {:necromancer_pid, necromancer_pid} -> Dragon.init_necromancer_pid(necromancer_pid)
    end
  end

  ##################################
  ### List of Zombie Knight PIDs ###
  ##################################
  def init_zombie_knight_pids() do
    Agent.start_link(fn -> [] end, name: D_ZOMBIE_KNIGHT_PIDS)
  end

  def get_zombie_knight_pids() do
    Agent.get(D_ZOMBIE_KNIGHT_PIDS, fn x -> x end)
  end

  def add_zombie_knight_pid(zombie_knight_pid) do
    Agent.update(D_ZOMBIE_KNIGHT_PIDS, fn zombie_knight_pids ->
      zombie_knight_pids ++ [zombie_knight_pid]
    end)
  end

  def remove_zombie_knight_pid(zombie_knight_pid) do
    Agent.update(D_ZOMBIE_KNIGHT_PIDS, fn zombie_knight_pids ->
      List.delete(zombie_knight_pids, zombie_knight_pid)
    end)
  end

  ##################################
  ### List of Zombie Archer PIDs ###
  ##################################
  def init_zombie_archer_pids() do
    Agent.start_link(fn -> [] end, name: D_ZOMBIE_ARCHER_PIDS)
  end

  def get_zombie_archer_pids() do
    Agent.get(D_ZOMBIE_ARCHER_PIDS, fn x -> x end)
  end

  def add_zombie_archer_pid(zombie_archer_pid) do
    Agent.update(D_ZOMBIE_ARCHER_PIDS, fn zombie_archer_pids ->
      zombie_archer_pids ++ [zombie_archer_pid]
    end)
  end

  def remove_zombie_archer_pid(zombie_archer_pid) do
    Agent.update(D_ZOMBIE_ARCHER_PIDS, fn zombie_archer_pids ->
      List.delete(zombie_archer_pids, zombie_archer_pid)
    end)
  end

  ##################################
  ### Dragon Actions ###
  ##################################
  def dragon_attack(type, dmg) do
    necromancer_pid = Dragon.get_necromancer_pid()
    zombie_knight_pids = Dragon.get_zombie_knight_pids()
    zombie_archer_pids = Dragon.get_zombie_archer_pids()

    case type do
      :whiptail ->
        zombie_knights_no = length(zombie_knight_pids)
        zombie_archers_no = length(zombie_archer_pids)

        if zombie_knights_no > 0 do
          idx = Enum.random(0..(zombie_knights_no - 1))
          victim = Enum.at(zombie_knight_pids, idx)

          IO.inspect("Dragonul ataca cu Whiptail de #{dmg} damage.")
          send(victim, {:from_d_dragon_attack, dmg})
        else
          if zombie_archers_no > 0 do
            necromancer_or_archer = Enum.random([:necromancer, :archer])

            case necromancer_or_archer do
              :necromancer ->
                victim = necromancer_pid

                IO.inspect("Dragonul ataca cu Whiptail de #{dmg} damage.")
                send(victim, {:from_d_dragon_attack, dmg})

              :archer ->
                idx = Enum.random(0..(zombie_archers_no - 1))
                victim = Enum.at(zombie_archer_pids, idx)

                IO.inspect("Dragonul ataca cu Whiptail de #{dmg} damage.")
                send(victim, {:from_d_dragon_attack, dmg})
            end
          else
            victim = necromancer_pid

            IO.inspect("Dragonul ataca cu Whiptail de #{dmg} damage.")
            send(victim, {:from_d_dragon_attack, dmg})
          end
        end

      :dragon_breath ->
        IO.inspect("Dragonul ataca cu Dragon Breath de #{dmg} damage.")

        send(necromancer_pid, {:from_d_dragon_attack, dmg})

        Enum.each(zombie_knight_pids, fn zombie_knight_pid ->
          send(zombie_knight_pid, {:from_d_dragon_attack, dmg})
        end)

        Enum.each(zombie_archer_pids, fn zombie_archer_pid ->
          send(zombie_archer_pid, {:from_d_dragon_attack, dmg})
        end)
    end
  end

  def dragon_won() do
    main_pid = Dragon.get_main_pid()
    remaining_hp = Dragon.get_hp()
    send(main_pid, {:dragon_won, remaining_hp})
  end

  ##################################
  ### Receive Loop ###
  ##################################
  def receive_loop() do
    receive do
      {:from_ds_whiptail, dmg} -> Dragon.dragon_attack(:whiptail, dmg)
      {:from_ds_dragon_breath, dmg} -> Dragon.dragon_attack(:dragon_breath, dmg)
      {:from_n_necromancer_attack, dmg} -> Dragon.update_hp(dmg)
      {:from_n_necromancer_lost, _x} -> Dragon.dragon_won()
      {:from_n_new_zombie_knight_enemy, zk_pid} -> Dragon.add_zombie_knight_pid(zk_pid)
      {:from_zk_zombie_knight_attack, dmg} -> Dragon.update_hp(dmg)
      {:from_zk_zombie_knight_lost, zk_pid} -> Dragon.remove_zombie_knight_pid(zk_pid)
      {:from_n_new_zombie_archer_enemy, za_pid} -> Dragon.add_zombie_archer_pid(za_pid)
      {:from_za_zombie_archer_attack, dmg} -> Dragon.update_hp(dmg)
      {:from_za_zombie_archer_lost, za_pid} -> Dragon.remove_zombie_archer_pid(za_pid)
    end

    d_hp = Dragon.get_hp()

    if d_hp >= 0 do
      Dragon.receive_loop()
    else
      IO.inspect("Sa-i fie tarana usoara Dragonului!")
      necromancer_pid = Dragon.get_necromancer_pid()
      send(necromancer_pid, {:from_d_dragon_lost, 0})
    end
  end

  ##################################
  ### Main ###
  ##################################
  def run() do
    Dragon.init_hp(1_000_000)

    Dragon.receive_main_pid()

    Dragon.receive_necromancer_pid()

    Dragon.init_zombie_knight_pids()
    Dragon.init_zombie_archer_pids()

    Dragon.receive_loop()
  end
end
