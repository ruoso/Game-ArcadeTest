package Jogo::Model;
use strict;
use warnings;
use Scalar::Util qw(refaddr);

my %listeners;

sub add_listener {
    my ($self, $e_type, $object) = @_;
    $listener{refaddr $self}{$e_type} ||= [];
    push @{$listener{refaddr $self}{$e_type}}, $object;
}

sub remove_listener {
    my ($self, $e_type, $object) = @_;
    @{$listener{refaddr $self}{$e_type}} =
      grep { $_ != $object }
        @{$listener{refaddr $self}{$e_type}};
}

sub listeners {
    my ($self, $e_type) = @_;
    return $listener{refaddr $self}{$e_type};
}

sub fire_event {
    my ($self, $e_type, $e) = @_;
    for $list (@{$listener{refaddr $self}{$e_type}}) {
        eval {
            $list->"${e_type}_event_fired"($e);
        };
        if ($@) {
            warn "Exception ignored in event handling: ".$@;
        }
    }
}

__END__

=head1 NAME

Jogo::Model - Base class for model objects

=head1 DESCRIPTION

This is the base class for model objects in the Jogo framework. All
units here are in the International System (meters, grams, newtons
etc).

The conversion from that measure units to the screen space should be
performed by a specialized View object.

The idea of model objects is to represent a simulated universe,
independently of how they are represented to the end user. This allows
greater code reuse and better maintainibility.

This module is built in a inside-out fashion and it doesn't provide a
constructor. This means you can use it by just adding it to the isa of
any object and it will just work.

=head1 OBSERVER PATTERN

The concept implemented by the base class is simply the observer
pattern. The idea is that controller and view objects should be
connected to model events. Eventually some model objects are connected
to other model object's events as well.

This should allow a uniform propagation of changes in the model
attributes.

The use of the observer pattern should also allow the usage of
inter-thread message queues, which are fundamental to bigger games.

=head1 METHODS

=over

=item add_listener($event_type, $listener_object)

This method will register the given object as the listener for the
given event type. Whenever an event of that type occour, a
$event_type."_event_fired" method will be called on the object.

It is important to notice that this happens in an object-to-object
fashion, so it doesn't interact with the SDL main loop. This is
important to make the code simpler when dealing with the events, since
only the relevant objects will receive the given notification. In the
future this should include support for inter-thread queues.

=item remove_listener($event_type, $listener_object)

This method will remove the object from the listener list.

=item listeners($event_type)

This returns an arrayref of all the listeners of the given type.

=item fire_event($event_type, $event_object)

This will fire the event by calling the expected method in all the
listener objects for that event type.

=cut
