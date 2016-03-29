# DbTextSearch [![Build Status](https://travis-ci.org/thredded/db_text_search.svg?branch=master)](https://travis-ci.org/thredded/db_text_search) [![Code Climate](https://codeclimate.com/github/thredded/db_text_search/badges/gpa.svg)](https://codeclimate.com/github/thredded/db_text_search) [![Test Coverage](https://codeclimate.com/github/thredded/db_text_search/badges/coverage.svg)](https://codeclimate.com/github/thredded/db_text_search/coverage)

Different relational databases treat text search very differently.
DbTextSearch provides a unified interface on top of ActiveRecord for SQLite, MySQL, and PostgreSQL to do:

* Case-insensitive string-in-set querying, and CI index creation.
* Basic full-text search for a list of terms, and FTS index creation.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'db_text_search'
```

## Usage

TODO: Write usage instructions here

## Under the hood

<table>
<caption>Case-insensitive string matching methods</caption>
<thead>
  <tr><th rowspan="2">Column type</th><th colspan="2">SQLite</th><th colspan="2">MySQL</th><th colspan="2">PostgreSQL</th>
  <tr><th>Detected types</th><th>Search / index</th><th>Detected types</th><th>Search / index</th><th>Detected types</th><th>Search / index</th></tr>
</thead>
<tbody style="text-align: center">
  <tr><th>CI</th>
      <td rowspan="2">always treated as CS</td> <td rowspan="2"><code>COLLATE&nbsp;NOCASE</code></td>
      <td><i>default</i></td> <td><i>default</i></td>
      <td><code>CITEXT</code></td> <td><i>default</i></td>
  <tr><th>CS</th>
    <td>non-<code>ci</code> collations</td> <td><code>LOWER</code><br><b>no index</b></td>
    <td><i>default</i></td> <td><code>LOWER</code></td>
  </tr>
  </tr>
</tbody>
</table>

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

