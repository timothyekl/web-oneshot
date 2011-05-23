web-oneshot is a one-use Web server; it serves one file one time. To use:

`./wos.rb myfile`

Inspired by osws and woof, `wos` is meant to solve the problem of
(network-savvy) users needing to quickly share single files without
much infrastructure. `wos` adheres to the following principles:

* Actually serve the file. `wos` will stay active as long as it can
  until it transmits the file in question or is killed. This means `wos`
  stays active through failed authentications, bad requests, etc.
* Be dumb. `wos` doesn't care about buffering, or Digest authentication,
  or anything fancy - it serves a file as quickly and straightforwardly
  as possible.

### Options

`wos` has support for a few basic features, including:

* Set an auth username with `-U` and a password with `-P`. Each can be
  required individually from the other (e.g. require a particular user,
  no matter the password, or require a password for any user).
* Listen on a different port with `-p`.
* Log verbosely with `-v`.
* Replicate itself (i.e. serve `wos.rb`) with `-s`.
