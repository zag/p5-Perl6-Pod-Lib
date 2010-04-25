#===============================================================================
#  DESCRIPTION:  Base class for tests
#       AUTHOR:  Aliaksandr P. Zahatski (Mn), <zahatski@gmail.com>
#===============================================================================
package TBase;
#Setup uses
use constant NAME_BLOCKS => {
    Include => 'Perl6::Pod::Lib::Include',
    Image   => 'Perl6::Pod::Lib::Image'
};

use strict;
use warnings;
use Test::More;
use Test::Class;
use Perl6::Pod::Test;
use base qw( Test::Class Perl6::Pod::Test );
use Perl6::Pod::To::Mem;
use Perl6::Pod::To::XML;
use Perl6::Pod::To::DocBook;
use Perl6::Pod::To::XHTML;
use XML::Flow;
use XML::ExtOn ('create_pipe');

sub testing_class {
    my $test = shift;
    ( my $class = ref $test ) =~ s/^T[^:]*::/Perl6::Pod::Lib::/;
    return $class;
}

#overwrite Perl6::Pod::Test class
sub make_parser {
    my $self = shift;
    my ( $p, $out_formatter )  = $self->SUPER::make_parser(@_);
    #resgister
    my $use = $p->current_context->use;
    %$use = ( %$use, %{( NAME_BLOCKS )}); 
    return wantarray ? ( $p, $out_formatter ) : $p;

}

sub new_args { () }

sub _use : Test(startup=>1) {
    my $test = shift;
    use_ok $test->testing_class;
}


1;

