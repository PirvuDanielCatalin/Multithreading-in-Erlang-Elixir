defmodule ZombieArcher do
  use Agent

  ##################################
  ### Zombie Archer HP ###
  ##################################
  def init_hp(initial_hp) do
    Agent.start_link(fn -> initial_hp end, name: ZA_HP_PID)
  end

  def get_hp do
    Agent.get(ZA_HP_PID, fn zombie_archer_hp -> zombie_archer_hp end)
  end

  def update_hp(dmg) do
    Agent.get_and_update(ZA_HP_PID, fn zombie_archer_hp ->
      {zombie_archer_hp - dmg, zombie_archer_hp - dmg}
    end)
  end

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
  def receive_loop() do
    receive do
      {:from_zas_shot, dmg} ->
        ZombieArcher.zombie_archer_attack(dmg)

      {:from_d_dragon_attack, dmg} ->
        ZombieArcher.update_hp(dmg)
    end

    za_hp = ZombieArcher.get_hp()

    if za_hp >= 0 do
      ZombieArcher.receive_loop()
    else
      current_pid = self()
      dragon_pid = ZombieArcher.get_dragon_pid()
      send(dragon_pid, {:from_za_zombie_archer_lost, current_pid})
    end
  end

  ##################################
  ### Main ###
  ##################################
  def run() do
    ZombieArcher.init_hp(100)

    ZombieArcher.receive_dragon_pid()

    ZombieArcher.receive_loop()
  end
end
