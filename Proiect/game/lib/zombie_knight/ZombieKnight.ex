defmodule ZombieKnight do
  use Agent

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
  def receive_loop(zk_hp, dragon_pid) do
    receive do
      {:from_zks_sword_slash, dmg} ->
        ZombieKnight.zombie_knight_attack(dmg)

      {:from_d_dragon_attack, dmg} ->
        if zk_hp - dmg > 0 do
          ZombieKnight.receive_loop(zk_hp - dmg, dragon_pid)
        else
          current_pid = self()
          send(dragon_pid, {:from_zk_zombie_knight_lost, current_pid})
        end
    end
  end

  ##################################
  ### Main ###
  ##################################
  def run() do
    ZombieKnight.receive_dragon_pid()
    d_pid = ZombieKnight.get_dragon_pid()

    ZombieKnight.receive_loop(600, d_pid)
  end
end
