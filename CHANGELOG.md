# Changelog

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
