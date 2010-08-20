package Jogo::View::FilledRect;
use mro 'c3';
use strict;
use warnings;
use SDLx::Surface;
use SDL::Rect;
use base 'Jogo::Type::Rect';

# initializes the object. We assume we need color, the main surface
# and the camera.  All units (x, y, w, h) are in the game unit, not
# pixels. The camera is the thing responsible for unit conversion.
sub _init {
    my $self = shift;
    die "Need camera and main surface on initialization"
      unless $self->{main} && $self->{camera} && $self->{color};
    $self->_init_surface;
    $self->_init_rect;
}

# In FilledRect we create the surface with the collor, so it's a
# filled rect.
sub _init_surface {
    my ($self) = @_;
    $self->{surface} =
      SDLx::Surface->new
          ( width  => $self->{camera}->m2px($self->w),
            height => $self->{camera}->m2px($self->h),
            color  => $self->{color},
            flags => SDL_HWSURFACE,
          );
    return 1;
}

# _init_rect sets $self->{rect_obj} in order to avoid creating a new
# rect for every render call.
sub _init_rect {
    my ($self) = @_;
    $self->{rect_obj} =
      SDL::Rect->new
          ( 0, 0,
            $self->{camera}->m2px($self->w),
            $self->{camera}->m2px($self->h) );
    return 1;
}


# w and h are overriden to rebuild the surface and the rect. This only
# happens when someone re-sets it manually.
sub w {
    my $self = shift;
    $self->SUPER::w(@_);
    if (@_) {
        $self->_init_surface;
        $self->_init_rect;
    }
    return $self->{w};
}
sub h {
    my $self = shift;
    $self->SUPER::h(@_);
    if (@_) {
        $self->_init_surface;
        $self->_init_rect;
    }
    return $self->{h};
}


# This is where the actual rendering happens, it builds the target
# rect by using the camera translate_x_y_w_h method.
sub render {
    my ($self) = @_;

    my $rect = SDL::Rect->new
      ( $self->{camera}->translate_x_y_w_h( $self->x, $self->y,
                                            $self->w, $self->h ) );
    $self->{surface}->blit
        ( $self->{main},
          $self->{rect_obj},
          $rect );

    return 1;
}

# This is what is called when the camera dpi is changed It rebuilds
# the surface and the source rect.
sub zoomed_event_fired {
    my $self = shift;
    $self->_init_surface;
    $self->_init_rect;
}

# This receives the moved information. Simply updates x and y to be
# used in the next render call.
sub moved_event_fired {
    my ($self, $ev) = @_;
    $self->$_($ev->new_point->$_) for
        qw(x y);
    return 1;
}


1;
