package Perl6::Pod::Lib::Image;

#$Id$

=pod

=head1 NAME

Perl6::Pod::Lib::Image - add image

=head1 SYNOPSIS

    =Image t/image.jpg
    =Image file:t/data/P_test1.png
    =for Image :title('Test image title')
    img/image.png

=head1 DESCRIPTION

The B<=Image> block is used for include image link.
For definition of the target file are used a URI:

    =Image t/image.jpg

For inclusion of certain parts of the documents add the blockname and (or) attributes after the main link. For example:

    =Image file:../test.jpg
    =Image http://example.com/img.jpg

For set title of image add attribute B<:title> or define in Pod Link format:

    =for Image :title('test caption')
    t/data/P_test1.png
    =for Image
    test caption|t/data/P_test1.png
    

=back

=cut

use warnings;
use strict;
use Data::Dumper;
use Test::More;
use Perl6::Pod::Block;
use base 'Perl6::Pod::Block';
use Perl6::Pod::Parser::Utils qw(parse_URI );
use XML::ExtOn('create_pipe');

sub on_para {
    my ( $self, $parser, $txt ) = @_;

    #get only for one image
    my @lines = split( /[\n]/m, $txt );
    $txt = shift(@lines) || return;
    my $attr = $self->attrs_by_name;
    %{$attr} = %{ parse_URI($txt) };
    $txt;
}

#<img src="boat.gif" alt="Big Boat" />
sub to_xhtml {
    my ( $self, $parser, $txt ) = @_;
    my $lattr = $self->attrs_by_name;
    my $title = $lattr->{name} || $self->get_attr->{title};
    my $src =
        $lattr->{is_external}
      ? $lattr->{scheme} . "://" . $lattr->{address}
      : $lattr->{address};
    my $img = $parser->mk_element('img');
    %{ $img->attrs_by_name } = (
        src   => $src,
        alt   => $title,
        title => $title
    );
    return $img;
}

sub to_docbook {
    my ( $self, $parser, $txt ) = @_;
    my $lattr      = $self->attrs_by_name;
    my $title      = $lattr->{name} || $self->get_attr->{title};
    my $image_data = $self->mk_element('imagedata');
    warn "Only images from local filesystem supported" if $lattr->{is_external};
    my $src = $lattr->{address};
    my $ext = "JPG";
    if ( $src =~ /\.(\w+)$/ ) {
        $ext = uc($1);
    }
    %{ $image_data->attrs_by_name } = (
        align    => 'center',
        valign   => "bottom",
        scalefit => 1,
        fileref  => $src,
        format   => $ext,
        caption  => $title

    );
    my $container = $self->mk_element('mediaobject');
    my $caption =
      $self->mk_element('caption')
      ->add_content( $parser->mk_characters($title) );
    return $container->add_content(
        $self->mk_element('imageobject')->add_content($image_data), $caption );
}
1;
