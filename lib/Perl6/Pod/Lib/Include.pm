package Perl6::Pod::Lib::Include;

#$Id$

=pod

=head1 NAME

Perl6::Pod::Block::Include - to include pod in the specified place

=head1 SYNOPSIS

    =Include t/data/P_test1.pod(para :private :public)
    =Include file:t/data/P_test1.pod
    =Include http://example.com/api.pod(head1 :public)
    =Include http://example.com/api.pod ( !DESCRIPTION )
    
    =begin Include
    file:../intro.pod( :!develop )
    file:../api.pod(:public,para :notes)
    http://example.com/todo.pod
    =end Include

=head1 DESCRIPTION

The B<=Include> block is used to include other Pod documents or their parts.
The target file is defined by a URI:

    =Include
    file:../intro.pod
    http://example.com/todo.pod

To include certain parts of a document, add the blockname and/or attributes after the main link.
For example:

    =Include file:../intro.pod(para :public,item1)
    =Include http://example.com/document.pod ( :todo )

The content of included documents will be filtered through those rules. 

Examples of the rules:

=over

=item (para :pubic)

Only paragraphs with the attribute B<:public> are included

=item (:todo :private)

Only blocks with the attributes B<:todo> and B<:private> are included

=item (head1, head2)

Only include B<head1> and B<head2> blocks

=back

=cut

use warnings;
use strict;
use Data::Dumper;
use Test::More;
use Perl6::Pod::Block;
use Perl6::Pod::Parser::FilterPattern;
use Perl6::Pod::Lib::FilterExcludePattern;
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
            my @exclude_patterns =  ();
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
                my $is_exclude = $name =~ s/^!//;
                my $blk = $self->mk_block( $name, $opt );
                if ($no_name) {
                    $blk->attrs_by_name->{no_name} = 1;
                }
                $is_exclude ? push (@exclude_patterns, $blk) : push (@patterns, $blk)  ;
            }
            if (@exclude_patterns) {
                push @expressions,
                  new Perl6::Pod::Lib::FilterExcludePattern:: 
                  patterns =>
                  \@exclude_patterns;
            }
            if (@patterns) {
                push @expressions,
                  new Perl6::Pod::Parser::FilterPattern:: 
                  patterns =>
                  \@patterns;
            }

        }
        my $p1 = new Perl6::Pod::Parser:: {MAIN_PARSER=>$parser,__DEFAULT_CONTEXT=>$parser->current_context};
        my $p = create_pipe($p1, @expressions, $parser );
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

L<http://perlcabal.org/syn/S26.html>,

Samples of B<=Include>: L<https://github.com/zag/webdao/blob/master/contrib/webdao-book.pod6>, L<https://raw.github.com/zag/ru-perl6-book/master/perl6-book.pod>


=head1 AUTHOR

Zahatski Aliaksandr <zag@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut

