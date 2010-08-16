package Jogo::Event::Observable;
use strict;
use warnings;

sub add_listener {
    my ($self, $e_type, $object) = @_;
    $self->{listener}{$e_type} ||= [];
    push @{$self->{listener}{$e_type}}, $object;
}

sub remove_listener {
    my ($self, $e_type, $object) = @_;
    @{$self->{listener}{$e_type}} =
      grep { $_ != $object }
        @{$self->{listener}{$e_type}};
}

sub listener {
    my ($self, $e_type) = @_;
    return $self->{listener}{$e_type};
}

sub fire_event {
    my ($self, $e_type, $e) = @_;
    for $list (@{$self->{listener}{$e_type}}) {
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

Jogo::Event::Observable - Role with the code for observables

=head1 DESCRIPTION

This is a role for objects that implements the Observable role in the
Jogo framework.

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
