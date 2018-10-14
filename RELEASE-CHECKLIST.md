The checklist for releasing a new version of db_text_search.

Pre-requisites for the releaser:

* Push access to RubyGems.

Release checklist:

- [ ] Update gem version in `version.rb` and `README.md`.
- [ ] Update `CHANGELOG.md`.
- [ ] Wait for the Travis build to come back green.
- [ ] Tag the release and push it to rubygems:

  ```bash
  rake release
  ```
- [ ] Copy the release notes from the changelog to [GitHub Releases](https://github.com/thredded/thredded/releases).
