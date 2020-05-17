defmodule ZombieArcher do
  use Agent

  ##################################
  ### Dragon PID ###
  ##################################
  def init_dragon_pid(dragon_pid) do
    Agent.start_link(fn -> dragon_pid end, name: ZA_DRAGON_PID)
  end

  def get_dragon_pid() do
    Agent.get(ZA_DRAGON_PID, fn x -> x end)
  end

  def receive_dragon_pid() do
    receive do
      {:dragon_pid, dragon_pid} -> ZombieArcher.init_dragon_pid(dragon_pid)
    end
  end

  ##################################
  ### Zombie Archer Actions ###
  ##################################
  def zombie_archer_attack(dmg) do
    IO.inspect("Zombie Archerul ataca cu Shot de #{dmg} damage.")
    victim = ZombieArcher.get_dragon_pid()
    send(victim, {:from_za_zombie_archer_attack, dmg})
  end

  ##################################
  ### Receive Loop ###
  ##################################
  def receive_loop(za_hp, dragon_pid) do
    receive do
      {:from_zas_shot, dmg} ->
        ZombieArcher.zombie_archer_attack(dmg)

      {:from_d_dragon_attack, dmg} ->
        if za_hp - dmg > 0 do
          ZombieArcher.receive_loop(za_hp - dmg, dragon_pid)
        else
          current_pid = self()
          send(dragon_pid, {:from_za_zombie_archer_lost, current_pid})
        end
    end
  end

  ##################################
  ### Main ###
  ##################################
  def run() do
    ZombieArcher.receive_dragon_pid()
    d_pid = ZombieArcher.get_dragon_pid()

    ZombieArcher.receive_loop(100, d_pid)
  end
end
