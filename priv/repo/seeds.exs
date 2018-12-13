# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Discuss.Repo.insert!(%Discuss.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Discuss.Users

  Discuss.Repo.insert! %Users{
  name: "admin",
  email: "admin@admin.com",
  password: Comeonin.Bcrypt.hashpwsalt("admin")
}
