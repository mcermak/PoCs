package SCPN::Engine::Simple;

use Moo;
use Mojo::Exception;
use namespace::clean;
use feature 'state';

use SCPN::Schema;
use Time::HiRes qw/time/;
use JSON::XS;
use Statistics::Basic;
use List::Util;

has schema_fpath => (
	is => 'ro',
	required => 1
);

has actions => (
	is => 'ro',
	default => sub {{}}
);

has petri_net => (
	is => 'ro',
	builder => '_build_petri_net',
	lazy => 1,
	isa => sub {
		Mojo::Exception->throw("SCPN::Engine::Simple: petri_net_constraints fail.")
			unless ref $_[0] eq 'SCPN::Schema';
	}
);

has verbose => (
	is => 'rw',
	default => 0
);

has stats => (
	is => 'rw',
	default => sub { +{ stats => {} } },
);

my $stats_method = {
	avg => \&mean,
	min => \&List::Util::min,
	max => \&List::Util::max,
	median => \&median,
	count => sub { return scalar @_ }
};

sub median {
	my (@values) = @_;
	return Statistics::Basic::median(@values)->query
}

sub mean {
	my (@values) = @_;
	return Statistics::Basic::mean(@values)->query
}

sub add_stats {
	my ($self, $name, $value ) = @_;
	push @{$self->stats->{stats}{$name}}, $value;
}

sub _build_petri_net {
	my ($self) = @_;

	my $schema = SCPN::Schema->new( actions => $self->actions );
	$schema->build_schema_from_json($self->schema_fpath);

	return $schema;
}

sub step {
	my ($self) = @_;

	state $keys = [ keys %{ $self->petri_net->events } ];
	state $events = scalar @$keys;

	Mojo::Exception->throw("SCPN::Engine::Simple: cannot fire any event in PN.")
		unless $events;

	my $event_name = $keys->[int(rand($events))];
	return unless $self->petri_net->events->{$event_name}->is_active;

	print "Starting $event_name\n" if $self->verbose;

	my $start = time();
	my $return = $self->petri_net->events->{$event_name}->fire;
	$self->add_stats( $event_name, sprintf('%0.3f', time() - $start ) )
		if $return;

	print "Finished $event_name with $return\n" if $self->verbose;

	return $return;
}

sub run {
	my ($self, $steps) = @_;

	if($steps) {
		$self->step && $steps-- while($steps>0);
	} else {
		while (1) {
			$self->step
		}
	}
}

sub print_statistics {
	my ($self, $fh, @measurements) = @_;

	my $restats;
	foreach my $event ( keys %{ $self->stats->{stats} } ) {
		my @items = @{$self->stats->{stats}{$event}};
		foreach my $method ( @measurements ) {
			$restats->{$event}{$method} = $stats_method->{$method}->(@items);
		}
	}
	print $fh JSON::XS->new->pretty->encode($restats);
}


1;
