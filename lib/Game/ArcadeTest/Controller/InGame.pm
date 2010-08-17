package Game::ArcadeTest::Controller::InGame;
use mro 'c3';
use strict;
use warnings;
use base 'Jogo::Object';
use SDL::Event;
use SDL::Events ':all';

use aliased 'Game::ArcadeTest::Model::Ball';
use aliased 'Game::ArcadeTest::Model::Wall';
use aliased 'Jogo::View::Plane';
use aliased 'Jogo::View::FilledRect';
use aliased 'Jogo::View::Camera';
use aliased 'Jogo::Type::Rect';
use aliased 'Jogo::Type::Point';

use XML::Compile::Schema;
use XML::Compile::Util qw(pack_type);
use constant MAP_NS => 'http://daniel.ruoso.com/categoria/perl/games-perl-7';
my $s = XML::Compile::Schema->new('share/map.xsd');
my $r = $s->compile('READER', pack_type(MAP_NS, 'map'),
                    sloppy_floats => 1);

sub _init {
    my $self = shift;

    die "Missing mapname" unless $self->{mapname};
    die "Missing main_surface" unless $self->{main_surface};
    $self->{walls} = [];
    $self->{views} = [];
    $self->{ball} = Ball->new;

    my $camera = Camera->new( x_pixels => $self->{main_surface}->w,
                              y_pixels => $self->{main_surface}->h,
                              x => $self->{ball}->x,
                              y => $self->{ball}->y );

    my $background = Plane->new( main => $self->{main_surface},
                                 color => 0xFFFFFF,
                                 camera => $camera );


    my $map = $r->($self->{mapname});

    # first, let's set the ball position and radius.
    $self->{ball}->x($map->{ball}{x});
    $self->{ball}->y($map->{ball}{y});
    $self->{ball}->radius($map->{ball}{radius});

    # attach the ball to the camera.
    $self->{ball}->add_listener('moved', $camera);

    # create the ball view
    my $ball_view = FilledRect->new( color => 0x0000FF,
                                     camera => $camera,
                                     main => $self->{main_surface},
                                     x => $self->{ball}->x - $self->{ball}->radius,
                                     y => $self->{ball}->y - $self->{ball}->radius,
                                     w => $self->{ball}->radius * 2,
                                     h => $self->{ball}->radius * 2 );
    $self->{ball}->add_listener('moved', $ball_view);

    # now create the goal
    $self->{goal} = Point->new(%{$map->{goal}});
    my $goal_view = FilledRect->new( color => 0xFFFF00,
                                     camera => $camera,
                                     main => $self->{main_surface},
                                     x => $self->{goal}->x - 0.1,
                                     y => $self->{goal}->y - 0.1,
                                     w => 0.2,
                                     h => 0.2 );

    push @{$self->{views}}, $background, $ball_view, $goal_view;

    # now we need to build four walls, to enclose our ball.
    foreach my $rect (@{$map->{wall}}) {

        my $wall_model = Wall->new( %$rect );
        push @{$self->{walls}}, $wall_model;

        my $wall_view = FilledRect->new( color => 0xFF0000,
                                         camera => $camera,
                                         main => $self->{main_surface},
                                         %$rect );

        push @{$self->{views}}, $wall_view;

    }

}

sub handle_sdl_event {
    my ($self, $sevent) = @_;

    my $ball = $self->{ball};
    my $type = $sevent->type;

    if ($type == SDL_KEYDOWN &&
        $sevent->key_sym() == SDLK_LEFT) {
        $ball->x_acc(-5);

    } elsif ($type == SDL_KEYUP &&
             $sevent->key_sym() == SDLK_LEFT) {
        $ball->x_acc(0);

    } elsif ($type == SDL_KEYDOWN &&
             $sevent->key_sym() == SDLK_RIGHT) {
        $ball->x_acc(5);

    } elsif ($type == SDL_KEYUP &&
             $sevent->key_sym() == SDLK_RIGHT) {
        $ball->x_acc(0);

    } elsif ($type == SDL_KEYDOWN &&
             $sevent->key_sym() == SDLK_UP) {
        $ball->y_acc(5);

    } elsif ($type == SDL_KEYUP &&
             $sevent->key_sym() == SDLK_UP) {
        $ball->y_acc(0);

    } elsif ($type == SDL_KEYDOWN &&
             $sevent->key_sym() == SDLK_DOWN) {
        $ball->y_acc(-5);

    } elsif ($type == SDL_KEYUP &&
             $sevent->key_sym() == SDLK_DOWN) {
        $ball->y_acc(0);

    } else {
        return 0;
    }
    return 1;
}

sub reset_ball {
    my ($self) = @_;
    my $default = Ball->new();
    $self->{ball}->x($default->x);
    $self->{ball}->y($default->y);
}

my $frame = 0;
my $save_video = 0;
sub handle_frame {
    my ($self, $oldtime, $now) = @_;

    my $frame_elapsed_time = ($now - $oldtime)/1000;
    my $ball = $self->{ball};

    foreach my $wall (@{$self->{walls}}) {
        if (my $coll = collide($ball, $wall, $frame_elapsed_time)) {
            # need to place the ball in the result after the bounce given
            # the time elapsed after the collision.
            $ball->time_lapse($oldtime/1000, ($oldtime/1000 + $coll->time - 0.0001));

            if (defined $coll->axis &&
                $coll->axis eq 'x') {
                $ball->x_vel($ball->x_vel * -1);

            } elsif (defined $coll->axis &&
                     $coll->axis eq 'y') {
                $ball->y_vel($ball->y_vel * -1);

            } elsif (defined $coll->axis &&
                     ref $coll->axis eq 'ARRAY') {
                my ($xv, $yv) = @{$coll->bounce_vector};
                $ball->x_vel($xv);
                $ball->y_vel($yv);

            } else {
                warn 'BAD BALL!';
                $ball->x_vel($ball->x_vel * -1);
                $ball->y_vel($ball->y_vel * -1);
            }
            return $self->handle_frame($oldtime + ($coll->time*1000), $now);
        }
    }

    if (collide_goal($ball, $self->{goal}, $frame_elapsed_time)) {
        my $event = SDL::Event->new();
        $event->type( SDL_USEREVENT );
        SDL::Events::push_event($event);
    }

    $ball->time_lapse($oldtime/1000, $now/1000);

    foreach my $view (@{$self->{views}}) {
        my $ret = $view->render();
    }

    if ($save_video) {
        my $filename =  sprintf('/tmp/video_out/output_%010d.bmp',$frame++);
        my $ret = SDL::Video::save_BMP( $self->main_surface->surface, $filename);
        if ((not defined $ret) || ($ret != 0)) {
            warn 'Error saving '.$filename.': '.SDL::get_error();
        }
    }

    SDL::Video::flip($self->{main_surface});

}

use Collision::2D ':all';
sub collide_goal {
    my ($ball, $goal, $time) = @_;
    my $rect = hash2point({ x => $goal->x, y => $goal->y });
    my $circ = hash2circle({ x => $ball->x, y => $ball->y,
                             radius => $ball->radius,
                             xv => $ball->x_vel,
                             yv => $ball->y_vel });
    return dynamic_collision($circ, $rect, interval => $time);
}

sub collide {
    my ($ball, $wall, $time) = @_;
    my $rect = hash2rect({ x => $wall->x, y => $wall->y,
                           h => $wall->h, w => $wall->w });
    my $circ = hash2circle({ x => $ball->x, y => $ball->y,
                             radius => $ball->radius,
                             xv => $ball->x_vel,
                             yv => $ball->y_vel });
    return dynamic_collision($circ, $rect, interval => $time);
}


1;