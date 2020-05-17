defmodule ZombieArcherStrategy do
  use Agent

  ##################################
  ### Zombie Archer PID ###
  ##################################
  def init_zombie_archer_pid(zombie_archer_pid) do
    Agent.start_link(fn -> zombie_archer_pid end, name: ZAS_ZOMBIE_ARCHER_PID)
  end

  def get_zombie_archer_pid() do
    Agent.get(ZAS_ZOMBIE_ARCHER_PID, fn x -> x end)
  end

  def receive_zombie_archer_pid() do
    receive do
      {:zombie_archer_pid, za_pid} -> ZombieArcherStrategy.init_zombie_archer_pid(za_pid)
    end
  end

  ##################################
  ### Zombie Archer Attacks ###
  ##################################
  def shot() do
    dmg = Enum.random(100..200)

    za_pid = ZombieArcherStrategy.get_zombie_archer_pid()

    :timer.sleep(10)
    send(za_pid, {:from_zas_shot, dmg})
  end

  def attack() do
    ZombieArcherStrategy.shot()
    ZombieArcherStrategy.attack()
  end

  ##################################
  ### Main ###
  ##################################
  def run() do
    ZombieArcherStrategy.receive_zombie_archer_pid()
    ZombieArcherStrategy.attack()
  end
end
