# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Noteblock.Repo.insert!(%Noteblock.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

###
#
# Create the first block.
#
# note = Noteblock.Repo.get(Noteblock.Block, 1)
# data = Poison.encode(note.data)
# :crypto.hash(:sha256, elem(data, 1)) |> Base.encode16
# => "70D232BE2959744F734223E887BB35A16638A569F64E99D87F3BC674D660D743"
# new_data = {elem(Poison.encode(note.data), 1), note.hash}
# previous_hash = :crypto.hash(:sha256, elem(new_data, 1)) |> Base.encode16
# => "6DD7E8E932EA9D58555D7FEE44A9B01A9BD7448E986636B728EE3711B01F37CE"

Noteblock.Repo.insert!(%Noteblock.Block{
  data: %{
    "action" => "create",
    "note" => "hello world",
    "number" => "0"
  },
  hash: "70D232BE2959744F734223E887BB35A16638A569F64E99D87F3BC674D660D743",
  previous_hash: "6DD7E8E932EA9D58555D7FEE44A9B01A9BD7448E986636B728EE3711B01F37CE",
  originating_block: "70D232BE2959744F734223E887BB35A16638A569F64E99D87F3BC674D660D743"
})

# note = Noteblock.Repo.get(Noteblock.Block, 1)
# data = Poison.encode(note.data)
# :crypto.hash(:sha256, elem(data, 1)) |> Base.encode16
# => "70D232BE2959744F734223E887BB35A16638A569F64E99D87F3BC674D660D743"
# new_data = {elem(Poison.encode(note.data), 1), note.hash}
# previous_hash = :crypto.hash(:sha256, elem(new_data, 1)) |> Base.encode16
# => "6DD7E8E932EA9D58555D7FEE44A9B01A9BD7448E986636B728EE3711B01F37CE"
