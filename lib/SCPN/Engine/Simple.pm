package SCPN::Engine::Simple;

use Moo;
use Mojo::Exception;
use namespace::clean;
use feature 'state';

use SCPN::Schema;

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

sub _build_petri_net {
	my ($self) = @_;

	my $schema = SCPN::Schema->new( actions => $self->actions );
	$schema->build_schema_from_json($self->schema_fpath);

	return $schema;
}

sub _step {
	my ($self) = @_;

	state $keys = [ keys %{ $self->petri_net->events } ];
	state $events = scalar @$keys;

	Mojo::Exception->throw("SCPN::Engine::Simple: cannot fire any event in PN.")
		unless $events;

	my $event_name = $keys->[int(rand($events))];
	return unless $self->petri_net->events->{$event_name}->is_active;

	print "Starting $event_name\n" if $self->verbose;
	my $return = $self->petri_net->events->{$event_name}->fire;
	print "Finished $event_name with $return\n" if $self->verbose;

	return $return;
}

sub run {
	my ($self, $steps) = @_;

	if($steps) {
		$self->_step && $steps-- while($steps>0);
	} else {
		while (1) {
			$self->_step
		}
	}
}

1;
