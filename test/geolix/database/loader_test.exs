defmodule Geolix.Database.LoaderTest do
  use ExUnit.Case, async: true

  alias Geolix.Result

  @fixture_path [ __DIR__, "../../fixtures" ] |> Path.join() |> Path.expand()

  test "error if database contains no metadata" do
    path = Path.join([ @fixture_path, ".gitignore" ])

    assert { :error, :no_metadata } == Geolix.set_database(:invalid, path)
  end

  test "reloading a database" do
    db_city    = Path.join([ @fixture_path, "GeoIP2-City-Test.mmdb" ])
    db_country = Path.join([ @fixture_path, "GeoIP2-Country-Test.mmdb" ])

    assert :ok = Geolix.set_database(:reload, db_city)
    assert %Result.City{} = Geolix.lookup("2.125.160.216", where: :reload)

    assert :ok = Geolix.set_database(:reload, db_country)
    assert %Result.Country{} = Geolix.lookup("2.125.160.216", where: :reload)
  end

  test "system environment configuration" do
    db_city = Path.join([ @fixture_path, "GeoIP2-City-Test.mmdb" ])
    var     = "GEOLIX_TEST_DATABASE_PATH"

    System.put_env(var, db_city)

    assert :ok = Geolix.set_database(:system_env, { :system, var })
    assert %Result.City{} = Geolix.lookup("2.125.160.216", where: :system_env)
  end

  test "remote database" do
    # setup internal testing webserver
    Application.ensure_all_started(:inets)

    httpd_opts         = [ port:          0,
                           server_name:   'geolix_test',
                           server_root:   @fixture_path |> to_char_list,
                           document_root: @fixture_path |> to_char_list ]
    { :ok, httpd_pid } = :inets.start(:httpd, httpd_opts)

    # teste remote file loading
    remote_port = :httpd.info(httpd_pid)[:port]
    remote_db   = "http://localhost:#{ remote_port }/GeoIP2-City-Test.mmdb"

    assert :ok = Geolix.set_database(:remote, remote_db)
    assert %Result.City{} = Geolix.lookup("2.125.160.216", where: :remote)
  end


  test "database with invalid filename (not found)" do
    assert { :error, _ } = Geolix.set_database(:unknown_database, "invalid")
  end
end
