[![Build Status](https://travis-ci.org/nanoc/nanoc-core.png)](https://travis-ci.org/nanoc/nanoc-core)
[![Code Climate](https://codeclimate.com/github/nanoc/nanoc-core.png)](https://codeclimate.com/github/nanoc/nanoc-core)
[![Coverage Status](https://coveralls.io/repos/nanoc/nanoc-core/badge.png?branch=master)](https://coveralls.io/r/nanoc/nanoc-core)

**Please take a moment and [donate](http://pledgie.com/campaigns/9282) to nanoc. A lot of time has gone into developing nanoc, and I would like to keep the current pace. Your support will ensure that nanoc will continue to improve.**

Please note that this **is unrelease software**: this repository contains what will become part of nanoc 4.0, which is a work in progress, and will remain that way for quite a while.

# nanoc-core

**nanoc** is a simple but very flexible static site generator written in Ruby.
It operates on local files, and therefore does not run on the server. nanoc
“compiles” the local source files into HTML (usually), by evaluating eRuby,
Markdown, etc.

**nanoc-core** is the core of nanoc and does not include any plugins, such as
filters, helpers, data sources, or the CLI frontend.

## Requirements

Ruby 1.9.x and up.

## Tests

Run `rake` to run the tests.

## Documentation

Check out the [nanoc web site](http://nanoc.ws)!

## License

nanoc-core is licensed under the MIT license. For details, check out the LICENSE file.
