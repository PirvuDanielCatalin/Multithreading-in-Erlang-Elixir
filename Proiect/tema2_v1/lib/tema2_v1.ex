defmodule Tema2V1 do
  import Dragon
  import DragonStrategy

  def main do
    main_pid = self()

    d_pid = spawn(Dragon, :run, [])
    send d_pid, {:main_pid, main_pid}

    ds_pid = spawn(DragonStrategy, :run, [])
    send ds_pid, {:dragon_pid, d_pid}
    
  end
end

