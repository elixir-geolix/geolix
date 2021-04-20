# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v2.0.0 (2020-09-20)

- Enhancements
    - Adapters can now utilize a `:delayed` response from the `Geolix.Adapter.load_database/1` callback combined with `Geolix.Database.Loader.set_loaded/1` for a lazy initialization. The database will not be used for lookups until set to the `:loaded` state
    - Database worker supervision is now done using a `DynamicSupervisor`
    - Unloading a database can now be done by passing the complete database configuration instead of only the `:id`

- Bug fixes
    - Databases loaded without an adapter configuration can now be properly unloaded to prevent repeated error messages from `Geolix.reload_databases/0`
    - The optional `metadata/1` callback for adapters is now properly treated as optional

- Backwards incompatible changes
    - Internal adapter process pooling has been removed
    - Minimum required Elixir version is now `~> 1.7`

## v1.1.0 (2020-05-04)

- Enhancements
    - Configuring `startup_sync: true` allows you to ensure a synchronous database load is done during startup. This may have unwanted consequences when your loading process takes longer than around 5 seconds (default startup timeout), e.g. when loading a database from a remote location
    - Usage of deprecated `Supervisor` functions has been removed ([#30](https://github.com/elixir-geolix/geolix/pull/30))

## v1.0.0 (2019-09-08)

The adapter `Geolix.Adapter.MMDB2` has been extracted a [separate repository](https://github.com/elixir-geolix/adapter_mmdb2). You should be able to upgrade to the external adapter by changing your project's dependencies from `:geolix` to `:geolix_adapter_mmdb2` with an appropriate version requirement.

- Enhancements
    - Database metadata is now available via `Geolix.metadata/0,1` ([#26](https://github.com/elixir-geolix/geolix/pull/26))

- Backwards incompatible changes
    - The database workers function of an adapter will now receive the full database configuration to be configured as the sole parameter
    - The lookup function of an adapter will now receive the full database configuration to be used for the lookup as a third parameter

## v0.18.0 (2019-03-17)

- Enhancements
    - Initializer modules can be defined with additional arguments by using `{mod, fun, args}`

- Backwards incompatible changes
    - Minimum required Elixir version is now `~> 1.5`

## v0.17.0 (2018-09-02)

- Enhancements
    - Storage of the internal database loader state has been migrated to a named ets table in order to allow reading from databases while the loading cycle has not yet been completed ([#20](https://github.com/elixir-geolix/geolix/issues/20)).
    - The `:is_in_european_union` information has been added to the `Country` and `RepresentedCountry` result structs

- Backwards incompatible changes
    - Adapters are now responsible to return the complete (and final) result of the lookup. No additional modifications will be made. Several module namespaces have been renamed for this:
        - `Geolix.Model -> Geolix.Adapter.MMDB2.Model`
        - `Geolix.Record -> Geolix.Adapter.MMDB2.Record`
        - `Geolix.Result -> Geolix.Adapter.MMDB2.Result`

## v0.16.0 (2018-02-21)

- Enhancements
    - Configuration can be done on supervisor (re-) start by setting a `{mod, fun}` tuple for the config key `:init`. This method will be called without arguments
    - Every configured database can define a `{mod, fun}` tuple for the config key `:init`. This method, called upon database supervisor (re-) start, receives the current database configuration and is expected to return the full configuration used for starting the individual database
    - Unloading a database now calls `unload_database/1` of the unloaded database adapter passing the current configuration and expecting `:ok` as a result

## v0.15.1 (2017-12-04)

- Bug fixes
    - The MMDB2 decoding library is now properly included in releases

## v0.15.0 (2017-11-25)

- Enhancements
    - The MMDB2 file format decoding logic has been extracted to the new [`:mmdb2_decoder`](https://github.com/elixir-geolix/mmdb2_decoder) library

- Backwards incompatible changes
    - Minimum required Elixir version is now `~> 1.3`

## v0.14.0 (2017-06-20)

- Enhancements
    - Configuration errors are logged and/or returned
    - Databases can be unloaded. This is done lazy so while still being in memory it won't be reloaded or used for lookups
    - Databases in tarball format (`.tar` or `.tar.gz`) are now supported ([#16](https://github.com/elixir-geolix/geolix/issues/16))
    - Errors are now always returned in a tuple format (`{:error, type}`)
    - Errors occurring while initially loading databases (or when calling `Geolix.reload_databases/0`) are now sent to `Logger.error` ([#16](https://github.com/elixir-geolix/geolix/issues/16))
    - "GeoLite2-ASN" databases return structs instead of plain maps
    - System environment configuration can set an optional default value to be used if the environment variable is unset
    - When an error occurs during database load the database will be excluded from the lookup process

- Backwards incompatible changes
    - Previous `{:error, String.t}` return values have been removed in favor  of tuples and `Logger.error/1`

## v0.13.0 (2017-04-12)

- Backwards incompatible changes
    - Minimum required Elixir version is now `~> 1.2`
    - Minimum required Erlang version is now `~> 18.0`

## v0.12.0 (2017-03-26)

- Ownership has been transferred to the [`elixir-geolix`](https://github.com/elixir-geolix) organisation

- Backwards incompatible changes
    - Support for non-map database configuration has been removed
    - Support for `GeoIP2-Precision-City` and `GeoIP2-Precision-Country` database files has been removed ([matching upstream](https://github.com/maxmind/MaxMind-DB/commit/8c69730696fbc3c839d04ff9a668a3c209390d7d))

## v0.11.0 (2016-12-28)

- Enhancements
    - All configured databases can be reloaded in the background using `Geolix.reload_databases/0`
    - Database configuration has been extended to support adapters
    - `Geolix.Adapter.Fake` is provided for a custom managed database with fixed/pre-defined responses
    - `GeoIP-Enterprise` databases return structs instead of plain maps
    - Lookups are done with a configurable timeout

- Deprecations
    - Configuring the application's databases using `{:id, filename}` tuples (or `Keyword.t`) has been deprecated in favor of a list of database definition maps
    - `Geolix.set_database/2` has been deprecated in favor of the new `Geolix.load_database/1`

## v0.10.1 (2016-06-04)

- Enhancements
    - Lookup results are generated with `:en` as the default if no locale is passed

## v0.10.0 (2016-04-04)

- Enhancements
    - Databases are reloaded if a storage process gets restarted
    - Databases can be directly loaded from remote (http) locations if configured ([#10](https://github.com/elixir-geolix/geolix/pull/10))
    - Paths can be configured by accessing the system environment
    - Storage processes are now supervised

- Bug fixes
    - Traits from the database are properly passed on in the result

## v0.9.0 (2015-11-16)

- Enhancements
    - Allows usage of `GeoIP2-Precision-ISP` databases
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
