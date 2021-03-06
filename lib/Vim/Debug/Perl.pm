# ABSTRACT: Perl debugger interface.

=head1 DESCRIPTION

If you are new to Vim::Debug please read the user manual,
L<Vim::Debug::Manual>, first.

This module is a role that is dynamically applied to an Vim::Debug instance.
L<Vim::Debug> represents a debugger.  This module only handles the Perl
specific bits.  Theoretically there might be a Ruby or Python role someday.

=cut

package Vim::Debug::Perl;

# VERSION

use Moose::Role;

$ENV{"PERL5DB"}     = 'BEGIN {require "perl5db.pl";}';
$ENV{"PERLDB_OPTS"} = "ornaments=''";


=head1 DEBUGGER OUTPUT REGEX CLASS ATTRIBUTES

These attributes are used to parse debugger output and are used by Vim::Debug.
They return a regex and ignore all values passed to them.

=func dbgrPromptRegex()

=func compilerErrorRegex()

=func runtimeErrorRegex()

=func appExitedRegex()

=cut

    # Debugger prompt regex.
#my $dpr = qr/.*  DB<+\d+>+ /sx;
our $dpr = '.*  DB<+\d+>+ ';

sub dbgrPromptRegex    { qr/$dpr/ }
sub compilerErrorRegex { qr/aborted due to compilation error${dpr}/s }
sub runtimeErrorRegex  { qr/ at .* line \d+${dpr}/ }
sub appExitedRegex     { qr/((\/perl5db.pl:)|(Use .* to quit or .* to restart)|(\' to quit or \`R\' to restart))${dpr}/ }

=head1 TRANSLATION CLASS ATTRIBUTES

These attributes are used to convert commands from the
communication protocol to commands the Perl debugger can recognize.  For
example, the communication protocol uses the keyword 'next' while the Perl
debugger uses 'n'.

=func next()

=func step()

=func cont()

=func break()

=func clear()

=func clearAll()

=func print()

=func command()

=func restart()

=func quit()

=cut

sub next     { 'n' }
sub step     { 's' }
sub cont     { 'c' }
sub break    { "f $_[2]", "b $_[1]" }
sub clear    { "f $_[2]", "B $_[1]" }
sub clearAll { 'B *' }
sub print    { "x $_[1]" }
sub command  { $_[1] }
sub restart  { 'R' }
sub quit     { 'q' }

=method parseOutput($output)

$output is output from the Perl debugger.  This method parses $output and
saves relevant valus to the line, file, and output attributes (these
attributes are defined in Vim::Debug)

Returns undef.

=cut
sub parseOutput {
    my $self   = shift or die;
    my $output = shift or die;

    # See .../t/VD_DI_Perl.t for test cases.
    my $file;
    my $line;
    $output =~ /
        ^ \w+ ::
        (?: \w+ :: )*
        (?: CODE \( 0x \w+ \) | \w+ )?
        \(
            (?: .* \x20 )?
            ( .+ ) : ( \d+ )
        \):
    /xm;
    $self->file($1) if defined $1;
    $self->line($2) if defined $2;

    if ($output =~ /^x .*\n/m) {
        $output =~ s/^x .*\n//m; # remove first line
        $output =~ s/\n.*$//m; # remove last line
        $self->value($output);
    }

   return undef;
}

1;
