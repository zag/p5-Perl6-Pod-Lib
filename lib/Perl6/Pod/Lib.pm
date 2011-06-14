package Perl6::Pod::Lib;

#$Id$

=pod

=head1 NAME

Perl6::Pod::Lib - set of extensions for Perl6::Pod

=head1 SYNOPSIS


    =begin pod
    =use Perl6::Pod::Lib
    =Image src/test.jpg
    =end pod


    =begin pod
    =use Perl6::Pod::Lib::Include
    =Include http://example.com/api.pod(head1 :public)
    =end pod

=head1 DESCRIPTION

The given library contains modules which expand possibilities of documents writen in Perldoc Pod (perl6's pod).

=over

=item * Perl6::Pod::Lib::Include

Insert filtered content of other Pod

=item * Perl6::Pod::Lib::Image

Insert image

=back

=cut

$Perl6::Pod::Lib::VERSION = '0.05';
our $PERL6POD = <<POD;
=begin pod
=use Perl6::Pod::Lib::Image
=use Perl6::Pod::Lib::Include
=end pod
POD

1;
__END__


=head1 SEE ALSO

Perl6::Pod, Perl6::Pod::Lib::Include, Perl6::Pod::Lib::Image

L<http://perlcabal.org/syn/S26.html>

=head1 AUTHOR

Zahatski Aliaksandr, <zag@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010-2011 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

