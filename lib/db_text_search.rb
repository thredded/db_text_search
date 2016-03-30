require 'active_record'
require 'active_support/core_ext/hash/keys'

require 'db_text_search/version'
require 'db_text_search/case_insensitive_eq'
require 'db_text_search/full_text_search'

# DbTextSearch provides a unified interface on top of ActiveRecord for SQLite, MySQL, and PostgreSQL to do:
# * Case-insensitive string-in-set querying, and CI index creation.
# * Basic full-text search for a list of terms, and FTS index creation.
# @see DbTextSearch::CaseInsensitiveEq
# @see DbTextSearch::FullTextSearch
module DbTextSearch
end
