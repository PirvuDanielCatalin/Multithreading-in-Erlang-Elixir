defmodule NecromancerStrategy do
  use Agent

  ##################################
  ### Necromancer PID ###
  ##################################
  def init_necromancer_pid(necromancer_pid) do
    Agent.start_link(fn -> necromancer_pid end, name: NS_NECROMANCER_PID)
  end

  def get_necromancer_pid() do
    Agent.get(NS_NECROMANCER_PID, fn x -> x end)
  end

  def receive_necromancer_pid() do
    receive do
      {:necromancer_pid, n_pid} -> NecromancerStrategy.init_necromancer_pid(n_pid)
    end
  end

  ##################################
  ### Necromancer Attacks ###
  ##################################
  def anti_zombie_bolt() do
    dmg = Enum.random(0..1000)

    n_pid = NecromancerStrategy.get_necromancer_pid()

    :timer.sleep(12)
    send(n_pid, {:from_ns_anti_zombie_bolt, dmg})
  end

  def summon_zombie_knight() do
    n_pid = NecromancerStrategy.get_necromancer_pid()

    :timer.sleep(20)
    send(n_pid, {:from_ns_summon_zombie_knight, 0})
  end

  def summon_zombie_archer() do
    n_pid = NecromancerStrategy.get_necromancer_pid()

    :timer.sleep(20)
    send(n_pid, {:from_ns_summon_zombie_archer, 0})
  end

  def attack() do
    type = Enum.random(1..3)

    case type do
      1 -> NecromancerStrategy.anti_zombie_bolt()
      2 -> NecromancerStrategy.summon_zombie_knight()
      3 -> NecromancerStrategy.summon_zombie_archer()
    end

    NecromancerStrategy.attack()
  end

  ##################################
  ### Main ###
  ##################################
  def run() do
    NecromancerStrategy.receive_necromancer_pid()
    NecromancerStrategy.attack()
  end
end
