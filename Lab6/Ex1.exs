defmodule Ex1 do
  def replace(string) do
    map = %{
      "A" => "U",
      "C" => "G",
      "G" => "C",
      "T" => "A",
    }
    changed_string = Regex.replace ~r/(A|C|G|T)/, "#{string}", fn _, match ->
      map[match]
    end
    IO.puts changed_string
  end
end
