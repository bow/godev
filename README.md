GODEV
=====

Shell functions for easier Go development
-----------------------------------------

godev eases your Go development by providing functions to manage your `GOPATH`
and source directories.


### Usage

Some main examples:

1. Start a new workspace for development using `godev start`

    ~~~ sh
    $ godev start my_workspace
    ~~~

   This will create a directory called `my_workspace` in your `GODEV_ROOT` (see below), containing `src`, `bin`, and `pkg`. If `my_workspace` already exists, it only checks whether the latter three directories have been created.
   If you also pass the `-a` flag, `my_workspace`'s path will be prepended to the existing `GOPATH`. Otherwise, `GOPATH` will exclusively point to `my_workspace`.


2. Revert to system `GOPATH`

    ~~~ sh
    $ godev stop
    ~~~

3. Symlink directories into `src` in your active workspace

   It's easy to have your real source directories anywhere outside `GOPATH` and still be able to do proper imports and/or builds. You only need to symlink them into the active workspace's `src` directory using `godev add`:

    ~~~ sh
    $ godev add my_src my_other_src
    ~~~

Run `godev help` for the complete usage listing.


### Installation

1. Checkout from the repo, for example into `~`

    ~~~ sh
    $ git clone git://github.com/bow/godev.git ~
    ~~~

2. Create a `GODEV_ROOT` directory. This will be the directory containing all your workspaces. A good example would be `~/.godev`

   ~~~ sh
   $ mkdir -p ~/.godev
   ~~~

3. Add the following entry to your `.bashrc` (or something similar)

    ~~~ sh
    $ echo "export GODEV_ROOT=~/.godev" >> ~/.bashrc  # path to previously set GODEV_ROOT
    $ echo "source ~/godev/godev.sh" >> ~/.bashrc     # path to main godev file
    ~~~

4. Reload your `.bashrc`

   ~~~ sh
   $ source ~/.bashrc
   ~~~

5. And you're set!


### License

See the attached license in `godev.sh`
