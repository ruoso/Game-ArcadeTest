package Jogo::View::Camera;
use mro 'c3';
use base 'Jogo::Type::Point';
use strict;
use warnings;

sub _init {
    my $self = shift;
    $self->{dpi} ||= 0.096;
    $self->{w_pixels} = 800;
    $self->{h_pixels} = 600;
}

sub w_pixels {
    my $self = shift;
    $self->{w_pixels} = shift if @_;
    return $self->{w_pixels};
}

sub h_pixels {
    my $self = shift;
    $self->{h_pixels} = shift if @_;
    return $self->{h_pixels};
}

sub dpi {
    my $self = shift;
    $self->{h_pixels} = shift if @_;
    return $self->{dpi};
}

sub m2px {
    my ($self, $input) = @_;
    return int((($input) * ($self->dpi / 0.0254)) + 0.5);
}

sub px2m {
    my ($self, $input) = @_;
    return ($input) / ($self->dpi / .0254);
}

sub w {
    my ($self) = @_;
    return $self->px2m($self->w_pixels);
}

sub h {
    my ($self) = @_;
    return $self->px2m($self->h_pixels);
}

sub translate_x_y {
    my ($self, $x, $y) = @_;
    my $uplf_x = $self->x - ($self->w / 2);
    my $uplf_y = $self->y - ($self->h / 2);
    my $rel_x = $x - $uplf_x;
    my $rel_y = $y - $uplf_y;
    my $pix_x = $self->m2px($rel_x);
    my $pix_y = $self->m2px($rel_y);
    my $inv_y = $self->h_pixels - $pix_y;
    return ($pix_x, $inv_y);
}

sub translate_x_y_w_h {
    my ($self, $x, $y, $w, $h) = @_;
    my ($pix_x, $inv_y) = $self->translate_x_y($x, $y);
    my $pix_h = $self->m2px($h);
    my $pix_w = $self->m2px($w);
    return ($pix_x, $inv_y - $pix_h, $pix_w, $pix_h);
}

sub is_visible {
    my ($self, $x, $y) = @_;
    my ($tx, $ty) = $self->translate($x, $y);
    if ($tx > 0 && $ty > 0 &&
        $tx < $self->w_pixels &&
        $ty < $self->h_pixels) {
        return 1;
    } else {
        return 0;
    }
}

# connect this camera to some moving object for it to follow...
sub moved_event_fired {
    my ($self, $ev) = @_;
    # implement a loose following of the ball.  if the ball gets near
    # the border of the screen, we follow it so it stays inside the
    # desired area.

    my $lf_x = $self->x - ($self->w / 2);
    my $br_lf_x = $lf_x + $self->w * 0.2;

    my $rt_x = $self->x + ($self->w / 2);
    my $br_rt_x = $rt_x - $self->w * 0.2;

    my $up_y = $self->y + ($self->h / 2);
    my $br_up_y = $up_y - $self->h * 0.2;

    my $dw_y = $self->y - ($self->h / 2);
    my $br_dw_y = $dw_y + $self->h * 0.2;

    if ($ev->new_point->x < $br_lf_x) {
        $self->x( $self->x - ($br_lf_x - $ev->new_point->x))
    } elsif ($ev->new_point->x > $br_rt_x) {
        $self->x( $self->x + ($ev->new_point->x - $br_rt_x));
    }

    if ($ev->new_point->y < $br_dw_y) {
        $self->y( $self->y - ($br_dw_y - $ev->new_point->y))
    } elsif ($ev->new_point->y > $br_up_y) {
        $self->y( $self->y + ($ev->new_point->y - $br_up_y));
    }

    return 1;
}


1;
