use strict;
use warnings;
use 5.010;
package Data::Rx::Type::PCRE;
# ABSTRACT: PCRE string checking for Rx (experimental)

use Carp ();
use Moose::Util::TypeConstraints ();

=head1 SYNOPSIS

  use Data::Rx;
  use Data::Rx::Type::PCRE;

  my $rx = Data::Rx->new({
    type_plugins => [ 'Data::Rx::Type::PCRE' ]
  });

  my $ph_number = $rx->make_schema({
    type  => 'tag:rjbs.manxome.org,2008-10-04:rx/pcre/str',
    regex => q/\A867-[5309]{4}\z/,
  });

=head1 WARNING

This plugin is still pretty experimental.  When it's less so, it may get a new
type URI.  Its interface may change between now and then.

=head1 DESCRIPTION

This provides a new type, currently known as
C<tag:rjbs.manxome.org,2008-10-04:rx/pcre/str>, which checks strings against
the Perl-compatible regular expression library.  B<Note!>  This uses PCRE, not
Perl's regular expressions.  There are differences, but very few.

Schema definitions must have a C<regex> parameter, which provides the regular
expression as a string.  They may also have a C<flags> parameter, which
provides regular expression flags to be passed to the C< (?i-i) > style flag
modifier.

=cut

sub type_uri { 'tag:rjbs.manxome.org,2008-10-04:rx/pcre/str' }

sub new_checker {
  my ($class, $arg, $rx) = @_;

  my $regex = $arg->{regex};
  my $flags = $arg->{flags} // '';

  Carp::croak("no regex supplied for $class type") unless defined $regex;

  my $regex_str = (length $flags) ? "(?$flags)$regex" : $regex;

  my $re = do {
    use re::engine::PCRE;
    qr{$regex_str};
  };

  my $self = { re => $re };
  bless $self => $class;

  return $self;
}

sub check {
  my ($self, $value) = @_;

  return unless $value =~ $self->{re};
  return 1;
}

1;
