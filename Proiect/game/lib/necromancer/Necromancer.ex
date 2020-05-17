defmodule Necromancer do
  use Agent

  ##################################
  ### Necromancer HP ###
  ##################################
  def init_hp(initial_hp) do
    Agent.start_link(fn -> initial_hp end, name: N_HP_PID)
  end

  def get_hp do
    Agent.get(N_HP_PID, fn necromancer_hp -> necromancer_hp end)
  end

  def update_hp(dmg) do
    Agent.get_and_update(N_HP_PID, fn necromancer_hp ->
      {necromancer_hp - dmg, necromancer_hp - dmg}
    end)
  end

  ##################################
  ### Main PID ###
  ##################################
  def init_main_pid(main_pid) do
    Agent.start_link(fn -> main_pid end, name: N_MAIN_PID)
  end

  def get_main_pid() do
    Agent.get(N_MAIN_PID, fn x -> x end)
  end

  def receive_main_pid() do
    receive do
      {:main_pid, main_pid} -> Necromancer.init_main_pid(main_pid)
    end
  end

  ##################################
  ### Dragon PID ###
  ##################################
  def init_dragon_pid(dragon_pid) do
    Agent.start_link(fn -> dragon_pid end, name: N_DRAGON_PID)
  end

  def get_dragon_pid() do
    Agent.get(N_DRAGON_PID, fn x -> x end)
  end

  def receive_dragon_pid() do
    receive do
      {:dragon_pid, dragon_pid} -> Necromancer.init_dragon_pid(dragon_pid)
    end
  end

  ##################################
  ### List of Zombie Knight PIDs ###
  ##################################
  def init_zombie_knight_pids() do
    Agent.start_link(fn -> [] end, name: N_ZOMBIE_KNIGHT_PIDS)
  end

  def get_zombie_knight_pids() do
    Agent.get(N_ZOMBIE_KNIGHT_PIDS, fn x -> x end)
  end

  def add_zombie_knight_pid(zombie_knight_pid) do
    Agent.update(N_ZOMBIE_KNIGHT_PIDS, fn zombie_knight_pids ->
      zombie_knight_pids ++ [zombie_knight_pid]
    end)
  end

  ###########################################
  ### List of Zombie Knight Strategy PIDs ###
  ###########################################
  def init_zombie_knight_strategy_pids() do
    Agent.start_link(fn -> [] end, name: N_ZOMBIE_KNIGHT_STRATEGY_PIDS)
  end

  def get_zombie_knight_strategy_pids() do
    Agent.get(N_ZOMBIE_KNIGHT_STRATEGY_PIDS, fn x -> x end)
  end

  def add_zombie_knight_strategy_pid(zombie_knight_strategy_pid) do
    Agent.update(N_ZOMBIE_KNIGHT_STRATEGY_PIDS, fn zombie_knight_strategy_pids ->
      zombie_knight_strategy_pids ++ [zombie_knight_strategy_pid]
    end)
  end

  ##################################
  ### List of Zombie Archer PIDs ###
  ##################################
  def init_zombie_archer_pids() do
    Agent.start_link(fn -> [] end, name: N_ZOMBIE_ARCHER_PIDS)
  end

  def get_zombie_archer_pids() do
    Agent.get(N_ZOMBIE_ARCHER_PIDS, fn x -> x end)
  end

  def add_zombie_archer_pid(zombie_archer_pid) do
    Agent.update(N_ZOMBIE_ARCHER_PIDS, fn zombie_archer_pids ->
      zombie_archer_pids ++ [zombie_archer_pid]
    end)
  end

  ###########################################
  ### List of Zombie Archer Strategy PIDs ###
  ###########################################
  def init_zombie_archer_strategy_pids() do
    Agent.start_link(fn -> [] end, name: N_ZOMBIE_ARCHER_STRATEGY_PIDS)
  end

  def get_zombie_archer_strategy_pids() do
    Agent.get(N_ZOMBIE_ARCHER_STRATEGY_PIDS, fn x -> x end)
  end

  def add_zombie_archer_strategy_pid(zombie_archer_strategy_pid) do
    Agent.update(N_ZOMBIE_ARCHER_STRATEGY_PIDS, fn zombie_archer_strategy_pids ->
      zombie_archer_strategy_pids ++ [zombie_archer_strategy_pid]
    end)
  end

  ##################################
  ### Utils ###
  ##################################
  def stop_knights_and_archers() do
    zombie_knight_pids = Necromancer.get_zombie_knight_pids()

    Enum.each(zombie_knight_pids, fn zombie_knight_pid ->
      Process.exit(zombie_knight_pid, "Game Over")
    end)

    zombie_knight_strategy_pids = Necromancer.get_zombie_knight_strategy_pids()

    Enum.each(zombie_knight_strategy_pids, fn zombie_knight_strategy_pid ->
      Process.exit(zombie_knight_strategy_pid, "Game Over")
    end)

    zombie_archer_pids = Necromancer.get_zombie_archer_pids()

    Enum.each(zombie_archer_pids, fn zombie_archer_pid ->
      Process.exit(zombie_archer_pid, "Game Over")
    end)

    zombie_archer_strategy_pids = Necromancer.get_zombie_archer_strategy_pids()

    Enum.each(zombie_archer_strategy_pids, fn zombie_archer_strategy_pid ->
      Process.exit(zombie_archer_strategy_pid, "Game Over")
    end)
  end

  ##################################
  ### Necromancer Actions ###
  ##################################
  def necromancer_attack(type, dmg) do
    case type do
      :anti_zombie_bolt ->
        IO.inspect("Necromancerul ataca cu Anti Zombie Bolt de #{dmg} damage.")
        victim = Necromancer.get_dragon_pid()
        send(victim, {:from_n_necromancer_attack, dmg})

      :summon_zombie_knight ->
        IO.inspect("Necromancerul summoneaza un Zombie Knight.")

        zk_pid = spawn(ZombieKnight, :run, [])

        d_pid = Necromancer.get_dragon_pid()
        send(zk_pid, {:dragon_pid, d_pid})

        zks_pid = spawn(ZombieKnightStrategy, :run, [])
        send(zks_pid, {:zombie_knight_pid, zk_pid})

        send(d_pid, {:from_n_new_zombie_knight_enemy, zk_pid})

        Necromancer.add_zombie_knight_pid(zk_pid)
        Necromancer.add_zombie_knight_strategy_pid(zks_pid)

      :summon_zombie_archer ->
        IO.inspect("Necromancerul summoneaza un Zombie Archer.")

        za_pid = spawn(ZombieArcher, :run, [])

        d_pid = Necromancer.get_dragon_pid()
        send(za_pid, {:dragon_pid, d_pid})

        zas_pid = spawn(ZombieArcherStrategy, :run, [])
        send(zas_pid, {:zombie_archer_pid, za_pid})

        send(d_pid, {:from_n_new_zombie_archer_enemy, za_pid})

        Necromancer.add_zombie_archer_pid(za_pid)
        Necromancer.add_zombie_archer_strategy_pid(zas_pid)
    end
  end

  def necromancer_won() do
    main_pid = Necromancer.get_main_pid()
    remaining_hp = Necromancer.get_hp()
    send(main_pid, {:necromancer_won, remaining_hp})
    Necromancer.stop_knights_and_archers()
  end

  ##################################
  ### Receive Loop ###
  ##################################
  def receive_loop() do
    receive do
      {:from_ns_anti_zombie_bolt, dmg} ->
        Necromancer.necromancer_attack(:anti_zombie_bolt, dmg)

      {:from_ns_summon_zombie_knight, _x} ->
        Necromancer.necromancer_attack(:summon_zombie_knight, _x)

      {:from_ns_summon_zombie_archer, _x} ->
        Necromancer.necromancer_attack(:summon_zombie_archer, _x)

      {:from_d_dragon_attack, dmg} ->
        Necromancer.update_hp(dmg)

      {:from_d_dragon_lost, _x} ->
        Necromancer.necromancer_won()
    end

    n_hp = Necromancer.get_hp()

    if n_hp >= 0 do
      Necromancer.receive_loop()
    else
      IO.inspect("Sa-i fie tarana usoara Necromancerului!")
      dragon_pid = Necromancer.get_dragon_pid()
      send(dragon_pid, {:from_n_necromancer_lost, 0})
      Necromancer.stop_knights_and_archers()
    end
  end

  ##################################
  ### Main ###
  ##################################
  def run() do
    Necromancer.init_hp(10000)

    Necromancer.receive_main_pid()

    Necromancer.receive_dragon_pid()

    Necromancer.init_zombie_knight_pids()
    Necromancer.init_zombie_knight_strategy_pids()

    Necromancer.init_zombie_archer_pids()
    Necromancer.init_zombie_archer_strategy_pids()

    Necromancer.receive_loop()
  end
end
