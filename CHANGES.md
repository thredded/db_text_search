## v0.2.2

* Raises a more helpful error if the column is not found when calling
  `DbTextSearch::CaseInsensitive`.

## v0.3.0

* * **Feature** Case insensitive sorting via the new `CaseInsensitive#column_for_order(asc_or_desc)` method. Use it like `SomeModel.some_scope.order(CaseInsensitive.new(SomeModel, :some_field).column_for_order(:asc))`

## v0.2.1

* Support for PostGIS adapters.
  [#2](https://github.com/thredded/db_text_search/issues/2)

## v0.2.0

* **Feature** Prefix matching via the new `CaseInsensitive#prefix` method.
* PostgreSQL CI index now uses the `text_pattern_ops` [opclass] by default (for prefix matching).
* Renamed `CaseInsensitiveEq` to `CaseInsensitive`, and `#find` to `#in`.
* Renamed `FullTextSearch` to `FullText`, and `#find` to `#search`.

[opclass]: http://www.postgresql.org/docs/9.5/static/indexes-opclass.html

## v0.1.2

Tightened the API. Improved documentation.

## v0.1.1

Initial release.
