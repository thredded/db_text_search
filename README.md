# DbTextSearch [![Build Status](https://travis-ci.org/thredded/db_text_search.svg?branch=master)](https://travis-ci.org/thredded/db_text_search) [![Code Climate](https://codeclimate.com/github/thredded/db_text_search/badges/gpa.svg)](https://codeclimate.com/github/thredded/db_text_search) [![Test Coverage](https://codeclimate.com/github/thredded/db_text_search/badges/coverage.svg)](https://codeclimate.com/github/thredded/db_text_search/coverage)

Different relational databases treat text search very differently.
DbTextSearch provides a unified interface on top of ActiveRecord for SQLite, MySQL, and PostgreSQL to do:

* Case-insensitive string-in-set querying, prefix querying, and case-insensitive index creation.
* Basic full-text search for a list of terms, and FTS index creation.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'db_text_search', '~> 0.3.1'
```

## Usage

### Case-insensitive string matching

Add an index in a migration to an existing CI (case-insensitive) or CS (case-sensitive) column:

```ruby
DbTextSearch::CaseInsensitive.add_index connection, :users, :username
# Options: name, unique
```

Or, create a new CI column:

```ruby
DbTextSearch::CaseInsensitive.add_ci_text_column connection, :users, :username
```

Perform a search for records with column that case-insensitively equals to one of the strings in a given set:

```ruby
# Find all confirmed users that have either the username Alice or Bob (case-insensitively):
DbTextSearch::CaseInsensitive.new(User.confirmed, :username).in(%w(Alice Bob))
 #=> ActiveRecord::Relation
```

Perform a case-insensitive prefix search:
 
```ruby
DbTextSearch::CaseInsensitive.new(User.confirmed, :username).prefix('Jo')
```

See also: [API documentation][api-docs].

### Full text search

Add an index:

```ruby
DbTextSearch::FullText.add_index connection, :posts, :content
# Options: name
```

Perform a full-text search:

```ruby
DbTextSearch::FullText.new(Post.published, :content).search('peace')
DbTextSearch::FullText.new(Post.published, :content).search(%w(love kaori))
```

## Under the hood

### Case-insensitive string matching

<table>
<caption>Case-insensitive equality methods</caption>
<thead>
  <tr><th rowspan="2">Column type</th><th colspan="2">SQLite</th><th colspan="2">MySQL</th><th colspan="2">PostgreSQL</th></tr>
  <tr><th>Detected types</th><th>Search / index</th><th>Detected types</th><th>Search / index</th><th>Detected types</th><th>Search / index</th></tr>
</thead>
<tbody style="text-align: center">
  <tr><th>CI</th>
      <td rowspan="2">always treated as CS</td> <td rowspan="2"><code>COLLATE&nbsp;NOCASE</code></td>
      <td><i>default</i></td> <td><i>default</i></td>
      <td><code>CITEXT</code></td> <td><i>default</i></td>
  </tr>
  <tr><th>CS</th>
    <td>non-<code>ci</code> collations</td> <td><code>LOWER</code><br><b>no index</b></td>
    <td><i>default</i></td> <td><code>LOWER</code></td>
  </tr>
</tbody>
</table>

<table>
<caption>Case-insensitive prefix matching (using <code>LIKE</code>)</caption>
<thead>
  <tr><th>Column type</th><th>SQLite</th><th>MySQL</th><th>PostgreSQL</th></tr>  
</thead>
<tbody style="text-align: center">
  <tr><th>CI</th>
      <td rowspan="2">
        <i>default</i>, <a href="https://www.sqlite.org/optoverview.html#prefix_opt"><b>cannot always use an index</b></a>,<br>
        even for prefix queries
      </td>
      <td><i>default</i></td>
      <td><b>cannot use an index</b></td>
  </tr>
  <tr><th>CS</th>
    <td><b>cannot use an index</b></td>    
    <td><code>LOWER(column text_pattern_ops)</code></td>
  </tr>
</tbody>
</table>


### Full-text search

#### MySQL

A `FULLTEXT` index, and a `MATCH AGAINST` query. MySQL v5.6.4+ is required.

#### PostgreSQL

A `gist(to_tsvector(...))` index, and a `@@ plainto_tsquery` query.
Methods also accept an optional `pg_ts_config` argument (default: `"'english'"`) that is ignored for other databases.

#### SQLite

**No index**, a `LIKE %term%` query for each term joined with `AND`.

## Development

Make sure you have a working installation of SQLite, MySQL, and PostgreSQL.
After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake test_all` to run the tests with all databases and gemfiles.

See the Rakefile for other available test tasks.

You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/thredded/db_text_search. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

[api-docs]: http://www.rubydoc.info/gems/db_text_search
