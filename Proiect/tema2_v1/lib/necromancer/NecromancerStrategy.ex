defmodule NecromancerStrategy do
  use Agent

  ##################################
  ### Necromancer PID ###
  ##################################
  def init_necromancer_pid(necromancer_pid) do
    Agent.start_link(fn -> necromancer_pid end, name: NS_NECROMANCER_PID)
  end

  def get_necromancer_pid() do
    Agent.get(NS_NECROMANCER_PID, fn (x) -> x end)
  end

  def receive_necromancer_pid() do
    receive do
      {:necromancer_pid, d_pid} -> NecromancerStrategy.init_necromancer_pid(d_pid)
    end

    n_pid = NecromancerStrategy.get_necromancer_pid()
    if n_pid == nil do
      NecromancerStrategy.receive_necromancer_pid()
    end
  end

  ##################################
  ### Necromancer Attacks ###
  ##################################
  def anti_zombie_bolt() do
    dmg = :rand.uniform(0) + 1000 # Random in 0 - 1000 range
    # IO.inspect dmg

    n_pid = NecromancerStrategy.get_necromancer_pid()
    # IO.inspect n_pid

    :timer.sleep(12)
    send n_pid, {:from_ns_anti_zombie_bolt, dmg}

    anti_zombie_bolt()
  end

  ##################################
  ### Main ###
  ##################################
  def run() do
    NecromancerStrategy.receive_necromancer_pid()
    NecromancerStrategy.anti_zombie_bolt()
  end
end
