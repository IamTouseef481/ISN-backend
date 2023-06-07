# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Data.Repo.insert!(%Data.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

{:ok, role} = Data.Repo.insert(%Data.Schema.Role{name: "super_admin", title: "super_admin"})

{:ok, user} =
  Data.Repo.insert(%Data.Schema.User{
    email: "superadmin@isn.com",
    password: Argon2.hash_pwd_salt("kdjNncjd@847987")
  })

{:ok, _person} =
  Data.Repo.insert(%Data.Schema.Person{
    first_name: "super",
    last_name: "admin",
    gender: "Male",
    user_id: user.id
  })

{:ok, _user_role} =
  Data.Repo.insert(%Data.Schema.UserRole{
    user_id: user.id,
    role_id: role.id
  })
