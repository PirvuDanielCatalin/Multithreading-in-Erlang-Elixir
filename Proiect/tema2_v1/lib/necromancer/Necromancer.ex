defmodule Necromancer do
  use Agent

  ##################################
  ### Necromancer HP ###
  ##################################
  def init_hp(initial_hp) do
    Agent.start_link(fn -> initial_hp end, name: N_HP_PID)
  end

  def get_hp do
    Agent.get(N_HP_PID, fn (necromancer_hp) -> necromancer_hp end)
  end

  def update_hp(dmg) do
    Agent.get_and_update(N_HP_PID, fn (necromancer_hp) -> {necromancer_hp - dmg, necromancer_hp - dmg} end)
  end

  ##################################
  ### Main PID ###
  ##################################
  def init_main_pid(main_pid) do
    Agent.start_link(fn -> main_pid end, name: N_MAIN_PID)
  end

  def get_main_pid() do
    Agent.get(N_MAIN_PID, fn (x) -> x end)
  end

  def receive_main_pid() do
    receive do
      {:main_pid, main_pid} -> Necromancer.init_main_pid(main_pid)
    end

    main_pid = Necromancer.get_main_pid()
    if main_pid == nil do
      Necromancer.receive_main_pid()
    end
  end

  ##################################
  ### Dragon PID ###
  ##################################
  def init_dragon_pid(dragon_pid) do
    Agent.start_link(fn -> dragon_pid end, name: N_DRAGON_PID)
  end

  def get_dragon_pid() do
    Agent.get(N_DRAGON_PID, fn (x) -> x end)
  end

  def receive_dragon_pid() do
    receive do
      {:dragon_pid, dragon_pid} -> Necromancer.init_dragon_pid(dragon_pid)
    end

    dragon_pid = Necromancer.get_dragon_pid()
    if dragon_pid == nil do
      Necromancer.receive_dragon_pid()
    end
  end

  ##################################
  ### Necromancer Actions ###
  ##################################
  def necromancer_attack(type, dmg) do
    case type do
      :anti_zombie_bolt ->
        IO.puts "Necromancerul ataca cu Anti Zombie Bolt de #{dmg} damage."
        victim = Necromancer.get_dragon_pid()
        send victim, {:from_n_necromancer_attack, dmg}

      :summon_zombie_knight ->
        IO.puts "Necromancerul summoneaza un Zombie Knight."
        # zk_pid = spawn(ZombieKnight, :run, [])

      :summon_zombie_archer ->
        IO.puts "Necromancerul summoneaza un Zombie Archer."
        # za_pid = spawn(ZombieArcher, :run, [])
    end
  end

  def necromancer_win() do
    main_pid = Necromancer.get_main_pid()
    remaining_hp = Necromancer.get_hp()
    send main_pid, {:necromancer_wins, remaining_hp}
  end

  ##################################
  ### Receive Loop ###
  ##################################
  def receive_loop() do
    receive do
      {:from_ns_anti_zombie_bolt, dmg} -> Necromancer.necromancer_attack(:anti_zombie_bolt, dmg)
      {:from_ns_summon_zombie_knight, dmg} -> Necromancer.necromancer_attack(:summon_zombie_knight, dmg)
      {:from_ns_summon_zombie_archer, dmg} -> Necromancer.necromancer_attack(:summon_zombie_archer, dmg)
      {:from_d_dragon_attack, dmg} -> Necromancer.update_hp(dmg)
      {:from_d_dragon_lost, _x} -> Necromancer.necromancer_win()
    end

    n_hp = Necromancer.get_hp()
    if n_hp >= 0 do
      Necromancer.receive_loop()
    else
      IO.puts "Sa-i fie tarana usoara Necromancerului!"
      dragon_pid = Necromancer.get_dragon_pid()
      send dragon_pid, {:from_n_necromancer_lost, 0}
    end
  end

  ##################################
  ### Main ###
  ##################################
  def run() do
    Necromancer.init_hp(10000)

    # hp = Necromancer.get_hp()
    # IO.inspect hp

    Necromancer.receive_main_pid()
    Necromancer.receive_dragon_pid()

    Necromancer.receive_loop()
  end
end
