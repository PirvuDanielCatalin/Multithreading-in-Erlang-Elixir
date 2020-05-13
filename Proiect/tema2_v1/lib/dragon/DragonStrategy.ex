defmodule DragonStrategy do
  use Agent

  def init_dragon_pid(dragon_pid) do
    Agent.start_link(fn -> dragon_pid end, name: DS_DRAGON_PID)
  end

  def get_dragon_pid() do
    Agent.get(DS_DRAGON_PID, fn (x) -> x end)
  end

  def receive_dragon_pid() do
    receive do
      {:dragon_pid, d_pid} -> DragonStrategy.init_dragon_pid(d_pid)
    end

    d_pid = DragonStrategy.get_dragon_pid()
    if d_pid == nil do
      DragonStrategy.receive_dragon_pid()
    end
  end

  def Whiptail() do
    dmg = :rand.uniform(50) + 50 # Random in 50 - 100 range
    IO.inspect dmg

    d_pid = DragonStrategy.get_dragon_pid()
    IO.inspect d_pid

    :timer.sleep(5)
    send d_pid, {:from_ds_whiptail, dmg}
  end

  def run() do
    DragonStrategy.receive_dragon_pid()
    DragonStrategy.Whiptail()
  end
end
