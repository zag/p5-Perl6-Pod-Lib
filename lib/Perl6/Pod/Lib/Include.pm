package Perl6::Pod::Lib::Include;

#$Id$

=pod

=head1 NAME

Perl6::Pod::Block::Include - to include pod in the specified place

=head1 SYNOPSIS

    =Inlcude t/data/P_test1.pod(para :private :public)
    =Include file:t/data/P_test1.pod
    =Include http://example.com/api.pod(head1 :public)
    
    =begin Include
    file:../intro.pod( :!develop )
    file:../api.pod(:public,para :notes)
    http://example.com/todo.pod
    =end Include

=head1 DESCRIPTION

The B<=Include> block is used for include other Pod documents or their parts.
For definition of the target file are used a URI:

    =Include
    file:../intro.pod
    http://example.com/todo.pod

For inclusion of certain parts of the documents add the blockname and (or) attributes after the main link. For example:

    =Include file:../intro.pod(para :public,item1)
    =Include http://example.com/document.pod ( :todo )

The content of included documents will be filtered through that rules. 

Eamples of the rules:

=over

=item (para :pubic)

all paragraphs with attribute B<:public> is set on

=item (:todo :private)

all blocks with attributes B<:todo> and B<:private>

=item (head1, head2)

all B<head1> and B<head2> blocks

=back

=cut

use warnings;
use strict;
use Data::Dumper;
use Test::More;
use Perl6::Pod::Block;
use Perl6::Pod::Parser::FilterPattern;
use base 'Perl6::Pod::Block';
use Perl6::Pod::Parser::Utils qw(parse_URI );
use XML::ExtOn('create_pipe');

sub on_para {
    my ( $self, $parser, $txt ) = @_;
    my @lines = split( /[\n]/m, $txt );
    foreach my $line (@lines) {
        my $attr = parse_URI($line);
        my @expressions = ();
        if ( my $exp = $attr->{rules} ) {

            my @patterns = ();
            foreach my $ex ( split( /\s*,\s*/, $exp ) ) {

                #head2 : !value
                #make filter element
                my ( $name, $opt ) = $ex =~ /\s*(\S+)\s*(.*)/;
                my $no_name = 0;

                # if  expression for attribut inly i.e.: (:private)
                if ( $name =~ m/^\s*:/ ) {
                    $opt .= " $name";
                    $name = "no_name";

                    #set flag for only attr filters
                    $no_name = 1;
                }

                #make element filter for
                my $blk = $self->mk_block( $name, $opt );
                if ($no_name) {
                    $blk->attrs_by_name->{no_name} = 1;
                }
                push @patterns, $blk;
            }
            if (@patterns) {
                push @expressions,
                  new Perl6::Pod::Parser::FilterPattern:: patterns =>
                  \@patterns;
            }
        }
        my $p = create_pipe( @expressions, $parser );
        my $path = $attr->{address};

        #now translate relative addr
        if (   $path !~ /^\//
            and my $current = $parser->current_context->custom->{src} )
        {
            my ($file, @cpath ) = reverse split( /\//, $current );
            my $cpath = join "/", reverse @cpath;
            $path = $cpath."/".$path;
        }

        $p->parse($path);

    }
    return undef;
}

sub to_xhtml {
    my ( $self, $parser, @in ) = @_;
    my $attr = $self->attrs_by_name();
    return \@in;
}

sub to_docbook {
    my ( $self, $parser, @in ) = @_;
    my $attr = $self->attrs_by_name();
    return \@in;
}
1;

__END__


=head1 SEE ALSO

L<http://perlcabal.org/syn/S26.html>

=head1 AUTHOR

Zahatski Aliaksandr, <zag@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut

