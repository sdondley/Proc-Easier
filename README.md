[![Actions Status](https://github.com/sdondley/Proc-Easier/actions/workflows/test.yml/badge.svg)](https://github.com/sdondley/Proc-Easier/actions)

NAME
====

Proc::Easier - run processes with OO goodness

SYNOPSIS
========

```raku
use Proc::Easier;

# run a command
cmd('ls');

# run command and assign resultant Proc::Easier object to a scalar
my $cmd = cmd('ls');

# get info about the object
say $cmd.out;
say $cmd.err;
say $cmd.exit;    # exitcode

# dump info about the command for debugging
say $cmd;

# run a command, say its output
say cmd('ls').out;

# run a command, say its error
say cmd('ls').err;

# run a command from a different directory
cmd('ls', '/home/dir');

# run a command, die if error encountered, then print info
cmd('a-bad-command', :die);

# make :die the default for all commands until its turned off
autodie(:on);
cmd('kjkjsdkjf');   # this dies

# turn off :die until its turned back on
autodie(:off);
cmd('kjkjsdkjf');   # this doesn't die

# create a command with standar OO, don't run it immediately
my $cmd= Proc::Easier.new(cmd => 'ls', :lazy);

# run the command
$cmd.run;
```

DESCRIPTION
===========

Proc::Easier is a convenient wrapper for the `run` command using a OO interface to make issuing commands from Raku much easier.

PROC::EASIER Class
==================

Class methods
-------------

### sub cmd ( Str $cmd, Bool :$dir = '', Bool :$die = False, Bool :$lazy = False )

    cmd('ls', '/some/dir', :die);

Convenience method for constructing a `Proc::Easier` object. Accepts a command, an optional directory command to run the command from, an an option to die if an error is encountered, and an optoin to make the command "lazy." Lazy commands will not be executed unless the run method is called on the object. Otherwise, oonce the object is constructed, the command will be immediately executed.

### multi sub autodie(Bool :$off)

### multi sub autodie(Bool :$on)

    autodie(:on);
    autodie(:off);

Turns on/off the autodie switch. All subsequent `Proc::Easier` commands will behave as if the `:die` feature has been turned on or off. Default is off.

Object methods
--------------

### method new( Str:D :$cmd, Str :$dir = '', Bool :$die = False, Bool :$lazy )

Accepts the same four named variables as the `cmd` convenience method.

### run()

Runs the command.

### out()

Returns the string from stdout, if any.

### err()

Returns the string from stderr, if any.

### exitcode()

Returns the exit code from the shell, '0' indicates success, other numbers indicate an error.

### caller-file()

Returns the name of the file where the call was made.

### caller-line()

Returns the line number of the file where the call was made.

Attributes
----------

### has Str $.cmd is rw;

Contains the original command.

### has Str $.dir is rw;

The directory where the command will be execute.

### has Bool $.die is rw;

Whether the command will die if an error is encountered.

AUTHOR
======

Steve Dondley <s@dondley.com>

ACKNOWLEDGEMENTS
================

Thanks to tbrowder for the `Proc::Easy` distribution which shamelessly inspired the name of this module and furnished some code and ideas to recycle, too.

COPYRIGHT AND LICENSE
=====================

Copyright 2022 Steve Dondley

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

