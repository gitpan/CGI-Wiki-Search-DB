package CGI::Wiki::Search::DB;

use strict;
use warnings;
use Carp "croak";
use base 'CGI::Wiki::Search::Base';

use vars qw( @ISA $VERSION );

$VERSION = 0.17;

=head1 NAME

CGI::Wiki::Search::DB - use the DB to search for wiki pages

=head1 SYNOPSIS

  my $store = $wiki->store;
  my $search = CGI::Wiki::Search::DB->new( store => $store );
  my %wombat_nodes = $search->search_nodes("wombat");

Provides search-related methods for L<CGI::Wiki>.

See also L<CGI::Wiki::Search::Base>, for methods not documented here.

Searches very simply, using the database's own text-searching ability.
Doesn't do fuzzy matching, doesn't do phrases, doesn't depend on a whole
host of other modules.

=cut

=head1 METHODS

=over 4

=item B<new>

  my $search = CGI::Wiki::Search::DB->new( store => $store );

Takes only one parameter, which is mandatory. C<store> is the CGI::Wiki
store object that you want to search.

=cut

sub _init {
    my ($self, %args) = @_;

    $self->{_store} = $args{store}
      or croak "I need a 'store' param";

    # At the mo, all stores are DBs. But don't take chances.
    unless ($self->{_store}->isa("CGI::Wiki::Store::Database") ) {
      croak("Woah! I only know how to deal with databases!");
    }
    
    return $self;
}

# I LAUGH AT YOUR PATHETIC ATTEMPTS TO OPTIMIZE THINGS
sub _index_node  { }
sub _index_fuzzy { }
sub _delete_node { }

# what are we, clever?
sub supports_phrase_searches { return 0; }
sub supports_fuzzy_searches  { return 0; }

# Our analyse can be a lot more liberal, because we don't index.
sub analyze {
    my ($self, $string) = @_;
    return grep { length > 1 }          # ignore single characters
           split( /\b/,                 # split at word boundaries
             lc($string)                # be case-insensitive
           );
}

sub _do_search {
  my ($self, $and_or, $terms) = @_;

  return () unless @$terms;

  # the fields we want to search for the terms in
  my @fields = qw( text name );

  # scary code to build SQL.
  my $atom = "( " . join( " OR ", map( { "$_ LIKE ?" } @fields ) ). " )";
  my $sql =
    "SELECT name FROM node WHERE ("
    . join( " AND ", ($atom) x scalar(@$terms) )
    . ");";

  my $sth = $self->{_store}->dbh->prepare($sql);
  $sth->execute(
    map { ("%$_%") x scalar(@fields) }
    @$terms
  );

  my %results;
  
  while (my ($name) = $sth->fetchrow_array) {
    $results{$name} = 1;
  }

  return %results;
}

=back

=head1 SEE ALSO

L<CGI::Wiki>, L<CGI::Wiki::Search::Base>.

=cut

1;
