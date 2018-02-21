# Changelog

## v0.16.0 (2018-02-21)

- Enhancements
    - Configuration can be done on supervisor (re-) start by setting a
      `{ mod, fun }` tuple for the config key `:init`. This method will be
      called without arguments
    - Every configured database can define a `{ mod, fun }` tuple for the config
      key `:init`. This method, called upon database supervisor (re-) start,
      receives the current database configuration and is expected to return the
      full configuration used for starting the individual database
    - Unloading a database now calls `unload_database/1` of the unloaded
      database adapter passing the current configuration and expecting `:ok` as
      a result

## v0.15.1 (2017-12-04)

- Bug fixes
    - The MMDB2 decoding library is now properly included in releases

## v0.15.0 (2017-11-25)

- Enhancements
    - The MMDB2 file format decoding logic has been extracted to the new
      [`:mmdb2_decoder`](https://github.com/elixir-geolix/mmdb2_decoder)
      library

- Backwards incompatible changes
    - Minimum required elixir version is now "~> 1.3"

## v0.14.0 (2017-06-20)

- Enhancements
    - Configuration errors are logged and/or returned
    - Databases can be unloaded. This is done lazy so while still being
      in memory it won't be reloaded or used for lookups
    - Databases in tarball format (`.tar` or `.tar.gz`) are now supported
      ([#16](https://github.com/elixir-geolix/geolix/issues/16))
    - Errors are now always returned in a tuple format (`{ :error, type }`)
    - Errors occurring while initially loading databases
      (or when calling `Geolix.reload_databases/0`) are now sent to
      `Logger.error` ([#16](https://github.com/elixir-geolix/geolix/issues/16))
    - "GeoLite2-ASN" databases return structs instead of plain maps
    - System environment configuration can set an optional default value
      to be used if the environment variable is unset
    - When an error occurs during database load the database will be
      excluded from the lookup process

- Backwards incompatible changes
    - Previous `{ :error, String.t }` return values have been removed in favor
      of tuples and `Logger.error/1`

## v0.13.0 (2017-04-12)

- Backwards incompatible changes
    - Minimum required elixir version is now "~> 1.2"
    - Minimum required erlang version is now "~> 18.0"

## v0.12.0 (2017-03-26)

- Ownership has been transferred to the
  [`elixir-geolix`](https://github.com/elixir-geolix) organisation

- Backwards incompatible changes
    - Support for non-map database configuration has been removed
    - Support for `GeoIP2-Precision-City` and `GeoIP2-Precision-Country`
      database files has been removed
      ([matching upstream](https://github.com/maxmind/MaxMind-DB/commit/8c69730696fbc3c839d04ff9a668a3c209390d7d))

## v0.11.0 (2016-12-28)

- Enhancements
    - All configured databases can be reloaded in the background
      using `Geolix.reload_databases/0`
    - Database configuration has been extended to support adapters
    - `Geolix.Adapter.Fake` is provided for a custom managed database with
      fixed/pre-defined responses
    - "GeoIP-Enterprise" databases return structs instead of plain maps
    - Lookups are done with a configurable timeout

- Deprecations
    - Configuring the application's databases using `{ :id, filename }` tuples
      (or `Keyword.t`) has been deprecated in favor of a list of database
      definition maps
    - `Geolix.set_database/2` has been deprecated in favor of the new
      `Geolix.load_database/1`

## v0.10.1 (2016-06-04)

- Enhancements
    - Lookup results are generated with `:en` as the default
      if no locale is passed

## v0.10.0 (2016-04-04)

- Enhancements
    - Databases are reloaded if a storage process gets restarted
    - Databases can be directly loaded from remote (http) locations if
      configured ([#10](https://github.com/elixir-geolix/geolix/pull/10))
    - Paths can be configured by accessing the system environment
    - Storage processes are now supervised

- Bug fixes
    - Traits from the database are properly passed on in the result

## v0.9.0 (2015-11-16)

- Enhancements
    - Allows usage of "GeoIP2-Precision-ISP" databases
    - Lookups querying all registered databases are done concurrently

## v0.8.0 (2015-07-18)

- Enhancements
    - Allows direct usage of gzip'ed database files
    - `:locale` lookup option for easier access to translatable result values
    - Dependencies not used in production builds are marked as optional

- Bug fixes
    - `Float` values are rounded to 4 decimal digits
    - `Double` values are rounded to 8 decimal digits

## v0.7.0 (2015-02-16)

- Enhancements
    - Supports IPv4 lookups in IPv6 notation ("0:0:0:0:0:FFFF:xxxx:xxxx")
    - Supports IPv6 lookups

## v0.6.0 (2015-02-08)

- Initial Release
