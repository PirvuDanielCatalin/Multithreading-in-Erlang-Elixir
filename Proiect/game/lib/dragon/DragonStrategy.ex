defmodule DragonStrategy do
  use Agent

  ##################################
  ### Dragon PID ###
  ##################################
  def init_dragon_pid(dragon_pid) do
    Agent.start_link(fn -> dragon_pid end, name: DS_DRAGON_PID)
  end

  def get_dragon_pid() do
    Agent.get(DS_DRAGON_PID, fn x -> x end)
  end

  def receive_dragon_pid() do
    receive do
      {:dragon_pid, d_pid} -> DragonStrategy.init_dragon_pid(d_pid)
    end
  end

  ##################################
  ### Dragon Attacks ###
  ##################################
  def whiptail() do
    dmg = Enum.random(50..100)

    d_pid = DragonStrategy.get_dragon_pid()

    :timer.sleep(5)
    send(d_pid, {:from_ds_whiptail, dmg})
  end

  def dragon_breath() do
    dmg = Enum.random(50..150)

    d_pid = DragonStrategy.get_dragon_pid()

    :timer.sleep(5)
    send(d_pid, {:from_ds_dragon_breath, dmg})
  end

  def attack() do
    type = Enum.random(1..5)

    case type do
      1 -> DragonStrategy.dragon_breath()
      _ -> DragonStrategy.whiptail()
    end

    DragonStrategy.attack()
  end

  ##################################
  ### Main ###
  ##################################
  def run() do
    DragonStrategy.receive_dragon_pid()
    DragonStrategy.attack()
  end
end
