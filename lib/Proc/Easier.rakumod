unit class Proc::Easier;

has Str  $.cmd   is rw;
has Str  $.dir   is rw;
has Bool $.die   is rw;
has Str  $!out;
has Str  $!err;
has Int  $!exit;
has Str  $!file;
has Str  $!line;

my Bool $autodie = False;
multi sub autodie(Bool :$off) is export { $autodie = !$off; }
multi sub autodie(Bool :$on)  is export { $autodie = $on; }

sub cmd($cmd, :$dir = '', :$die = False, :$lazy = False) is export {
    Proc::Easier.new(:$cmd, :$dir, :$die, :$lazy);
}

submethod BUILD(Str:D :$!cmd, Str :$!dir = '', Bool :$!die = False, Bool :$lazy) { self.run if !$lazy }

method !caller-info() {
    my $frame-counter = 2;
    while callframe($frame-counter++).file !~~ /^^SETTING.*/ { }
    $frame-counter++;
    return callframe($frame-counter).line,callframe($frame-counter).file;
}

method run() {
    my $cwd = $*CWD;
    chdir self.dir;
    my $proc  = run self.cmd.words, :err, :out;
    ($!line, $!file) = self!caller-info();
    chdir $cwd;
    $!exit = $proc.exitcode;
    $!err  = $proc.err.slurp(:close);
    $!out  = $proc.out.slurp(:close);
    if self.die || $autodie {
        self.gist() if $!exit;
        die;
    }
    return self;
}

method gist {
    my @out;;
    push @out, (sprintf "Command '%s': returned with exit code '%d'.", self.cmd.Str, $!exit).Str;
    push @out, (sprintf 'Called from: \'%s\', line %s', $!file, $!line).Str;
    push @out, sprintf "\nERROR: %s", $!err if $!err;
    push @out, sprintf "\nOUTPUT:\n%s", $!out if $!out;
    my $out = @out.join: "\n";
    return $out.Str
}

method err() { $!err || ''}
method out() { $!out || '' }
method exitcode() { $!exit }
method caller-file() { $!file }
method caller-line() { $!line }


# todo write pod
# todo write acknowledgements
=begin pod

=head1 NAME

Proc::Easier - run processes with OO goodness

=head1 SYNOPSIS

=begin code :lang<raku>

use Proc::Easier;

# run a command
cmd('ls');

# run command and assign resultant Proc::Easier object to a value
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

# create a command using traditional OO and run it
my $cmd= Proc::Easier.new(cmd => 'ls);
$cmd.run;

=end code

=head1 DESCRIPTION

Proc::Easier is a convenient wrapper for the C<run> command using a OO
interface to make issuing commands from Raku much easier.

=head1 PROC::EASIER Class

=head2 Class methods

=head3 cmd ($cmd, :$dir = '', :$die = False, :$lazy = False)

=begin code
cmd('ls', '/some/dir', :die);
=end code

Convenience method for constructing a C<Proc::Easier> object. Accepts
a command, an optional directory command to run the command from, an
an option to die if an error is encountered, and an optoin to make the
command "lazy." Lazy commands will not be executed unless the run method
is called on the object. Otherwise, oonce the object is constructed, the
command will be immediately executed.




=head3 multi sub autodie(Bool :$off) is export { $autodie = !$off; }

=head3 multi sub autodie(Bool :$on)  is export { $autodie = $on; }

=begin code
autodie(:on);
autodie(:off);
=end code

Turns on/off the autodie switch. All subsequent C<Proc::Easier> commands will
behave as if the C<:die> feature has been turned on or off. Default is off.



=head2 Object methods

=head3 new(Str:D :$!cmd, Str :$!dir = '', Bool :$!die = False, Bool :$lazy = False)

Accepts the same four named variables as the C<cmd> convenience method.

=head3 run()

Runs the command.

=head3 out()

Returns the string from stdout, if any.

=head3 err()

Returns the string from stderr, if any.

=head3 exitcode()

Returns the exit code from the shell, '0' indicates success, other
numbers indicate an error.

=head3 caller-file()

Returns the name of the file where the call was made.

=head3 caller-line()

Returns the line number of the file where the call was made.

=head2 Attributes

=head3 has Str  $.cmd   is rw;

Contains the original command.

=head3 has Str  $.dir   is rw;

The directory where the command will be execute.

has Bool $.die   is rw;

Whether the command will die if an error is encountered.


=head1 AUTHOR

Steve Dondley <s@dondley.com>

=head1 ACKNOWLEDGEMENTS

Thanks to tbrowder for the C<Proc::Easy> distribution which
shamelessly inspired the name of this module as well some inspiration and
recycled code to boot.

=head1 COPYRIGHT AND LICENSE

Copyright 2022 Steve Dondley

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
