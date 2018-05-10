# share

A CLI tool to simply upload a given file to some host, relying on scp. For ease of use, setting up an ssh config with a key auth for that host is strongly recommended.

Note `share` was made without too much care and in a short amount of time, so if you (or someone else) fiddles with the config in just the right (wrong?) way, things might break badly. Exercise caution.

## Installion

Assuming `/usr/local/sbin` is in your PATH, copy `share` to `/usr/local/sbin`.

## Usage

### Configure share for use

So that options don't have to be specified with every use of `share`, configuring first is recommended.

Simply run `share -c`, then follow the instructions provided. Configuring with safety enabled is recommended, but may be slow.

### Upload a file

To upload a file to the default host and path without changing the filename simply use `share <filename>`.

To upload a file to a different host specify the host with `share -h <host> <filename>`.

The path can be specified with `share -p <path> <filename>`.

Safety can be enabled with the `-s` flag, or disabled with `-u`.

A name can be specified for the remote file with `share -n <remote filename> <filename>`.

Options can be combined, as per `getopts`.
