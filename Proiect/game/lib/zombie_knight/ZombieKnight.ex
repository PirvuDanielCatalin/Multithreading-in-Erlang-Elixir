defmodule ZombieKnight do
  use Agent

  ##################################
  ### Zombie Knight HP ###
  ##################################
  def init_hp(initial_hp) do
    Agent.start_link(fn -> initial_hp end, name: ZK_HP_PID)
  end

  def get_hp do
    Agent.get(ZK_HP_PID, fn zombie_knight_hp -> zombie_knight_hp end)
  end

  def update_hp(dmg) do
    Agent.get_and_update(ZK_HP_PID, fn zombie_knight_hp ->
      {zombie_knight_hp - dmg, zombie_knight_hp - dmg}
    end)
  end

  ##################################
  ### Dragon PID ###
  ##################################
  def init_dragon_pid(dragon_pid) do
    Agent.start_link(fn -> dragon_pid end, name: ZK_DRAGON_PID)
  end

  def get_dragon_pid() do
    Agent.get(ZK_DRAGON_PID, fn x -> x end)
  end

  def receive_dragon_pid() do
    receive do
      {:dragon_pid, dragon_pid} -> ZombieKnight.init_dragon_pid(dragon_pid)
    end
  end

  ##################################
  ### Zombie Knight Actions ###
  ##################################
  def zombie_knight_attack(dmg) do
    IO.inspect("Zombie Knightul ataca cu Sword Slash de #{dmg} damage.")
    victim = ZombieKnight.get_dragon_pid()
    send(victim, {:from_zk_zombie_knight_attack, dmg})
  end

  ##################################
  ### Receive Loop ###
  ##################################
  def receive_loop() do
    receive do
      {:from_zks_sword_slash, dmg} ->
        ZombieKnight.zombie_knight_attack(dmg)

      {:from_d_dragon_attack, dmg} ->
        ZombieKnight.update_hp(dmg)
    end

    zk_hp = ZombieKnight.get_hp()

    if zk_hp >= 0 do
      ZombieKnight.receive_loop()
    else
      current_pid = self()
      dragon_pid = ZombieKnight.get_dragon_pid()
      send(dragon_pid, {:from_zk_zombie_knight_lost, current_pid})
    end
  end

  ##################################
  ### Main ###
  ##################################
  def run() do
    ZombieKnight.init_hp(600)

    ZombieKnight.receive_dragon_pid()

    ZombieKnight.receive_loop()
  end
end
