#===============================================================================
#
#  DESCRIPTION: test Image block
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package T::Image;
use strict;
use warnings;
use Test::More;
use Data::Dumper;
use Perl6::Pod::Lib::Include;
use base 'TBase';

sub p01_test_Image : Test {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T, );
=begin pod
=for Image :title('Test title')
Title erer er e er |t/data/P_test1.jpg
=end pod
T
    $t->is_deeply_xml( $x,
q#<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><Image pod:section='' pod:type='block' pod:scheme='file' pod:is_external='' pod:name='Title erer er e er' title='Test title' pod:address='t/data/P_test1.jpg'>Title erer er e er |t/data/P_test1.jpg</Image></pod>#
    );
}

sub p02_test_xhtml : Test {
    my $t = shift;
    my $x = $t->parse_to_xhtml( <<T, );
=begin pod
=Image Test caption|http://t/data/P_test1.jpg
=end pod
T
    $t->is_deeply_xml( $x,
q#<xhtml xmlns='http://www.w3.org/1999/xhtml'><img alt='Test caption' src='http://t/data/P_test1.jpg' title='Test caption' /></xhtml>#
    );
}

sub p03_test_docbook : Test {
    my $t = shift;
    my $x = $t->parse_to_docbook( <<T, );
=begin pod
=for Image :title('test')
t/data/P_test1.png
=end pod
T

    #    diag $x; exit;
    $t->is_deeply_xml( $x,
q#<chapter><mediaobject><imageobject><imagedata align='center' caption='test' format='PNG' valign='bottom' scalefit='1' fileref='t/data/P_test1.png' /></imageobject><caption>test</caption></mediaobject></chapter>#
    );
}

sub p04_deep_include : Test(2) {
    my $t = shift;
    my $pod = <<T;
=begin pod
=Include t/data/inc_sub_imgage.pod
=end pod
T
    my $x = $t->parse_to_xhtml( $pod );
    $t->is_deeply_xml( $x,
q#<xhtml xmlns='http://www.w3.org/1999/xhtml'><img alt='' src='t/data/subdir/test1.png' title='' /></xhtml>#,'include xhtml'
    );
    my $xd = $t->parse_to_docbook( $pod );
    $t->is_deeply_xml( $xd,
q#<chapter><mediaobject><imageobject><imagedata align='center' caption='' format='PNG' valign='bottom' scalefit='1' fileref='t/data/subdir/test1.png' /></imageobject><caption /></mediaobject></chapter>#,'include docbook'
    );
}

1;

