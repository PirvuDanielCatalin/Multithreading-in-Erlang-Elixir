defmodule Dragon do
  use Agent

  def init_hp(initial_hp) do
    Agent.start_link(fn -> initial_hp end, name: D_HP_PID)
  end

  def get_hp do
    Agent.get(D_HP_PID, fn (x) -> x end)
  end

  def update_hp(dmg) do
    Agent.get_and_update(D_HP_PID, fn (x) -> {x - value, x - value} end)
  end

  def init_main_pid(main_pid) do
    Agent.start_link(fn -> main_pid end, name: D_MAIN_PID)
  end

  def get_main_pid() do
    Agent.get(D_MAIN_PID, fn (x) -> x end)
  end

  def receive_main_pid() do
    receive do
      {:main_pid, main_pid} -> Dragon.init_main_pid(main_pid)
    end

    main_pid = Dragon.get_main_pid()
    if main_pid == nil do
      Dragon.receive_main_pid()
    end
  end

  def receive_loop() do
    receive do
      {:from_ds_whiptail, dmg} -> IO.puts "Dragonul ataca cu Whiptail de #{dmg} damage."
    end

    d_hp = Dragon.get_hp()
    if d_hp >= 0 do
      Dragon.receive_loop()
    else

    end
  end

  def run() do
    Dragon.init_hp(1000)

    hp = Dragon.get_hp()
    IO.inspect hp

    Dragon.update_hp(20)

    hp = Dragon.get_hp()
    IO.inspect hp\

    Dragon.receive_main_pid()

    Dragon.receive_loop()
  end

  
end
