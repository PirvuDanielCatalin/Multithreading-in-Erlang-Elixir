defmodule ZombieKnightStrategy do
  use Agent

  ##################################
  ### Zombie Knight PID ###
  ##################################
  def init_zombie_knight_pid(zombie_knight_pid) do
    Agent.start_link(fn -> zombie_knight_pid end, name: ZKS_ZOMBIE_KNIGHT_PID)
  end

  def get_zombie_knight_pid() do
    Agent.get(ZKS_ZOMBIE_KNIGHT_PID, fn x -> x end)
  end

  def receive_zombie_knight_pid() do
    receive do
      {:zombie_knight_pid, zk_pid} -> ZombieKnightStrategy.init_zombie_knight_pid(zk_pid)
    end
  end

  ##################################
  ### Zombie Knight Attacks ###
  ##################################
  def sword_slash() do
    dmg = Enum.random(20..50)

    zk_pid = ZombieKnightStrategy.get_zombie_knight_pid()

    :timer.sleep(5)
    send(zk_pid, {:from_zks_sword_slash, dmg})
  end

  def attack() do
    ZombieKnightStrategy.sword_slash()
    ZombieKnightStrategy.attack()
  end

  ##################################
  ### Main ###
  ##################################
  def run() do
    ZombieKnightStrategy.receive_zombie_knight_pid()
    ZombieKnightStrategy.attack()
  end
end
