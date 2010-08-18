#!/usr/bin/perl
use 5.10.0;
use strict;
use warnings;
use threads;

use SDL;
use SDL::Video;
use SDLx::App;
use SDL::Event;
use SDL::Events;

use lib 'lib';
use aliased 'Jogo::Behavior::Still';
use aliased 'Jogo::View::Camera';
use aliased 'Jogo::View::Plane';
use aliased 'Jogo::View::FilledRect';

my $app = SDLx::App->new
  ( title => "Bouncing Ball",
    width => 800,
    height => 600,
    flags => SDL_HWSURFACE | SDL_DOUBLEBUF | SDL_HWACCEL,
  );

my $model  = Still->new(x => 2, y => 2);
my $camera = Camera->new(x => 5, y => 5,
                         w_pixels => 800,
                         h_pixels => 600);
my $plane  = Plane->new(main => $app,
                        camera => $camera,
                        color => 0xFFFFFFFF);
my $view   = FilledRect->new(main => $app,
                             camera => $camera,
                             x => $model->x,
                             y => $model->y,
                             w => 1,
                             h => 1,
                             color => 0xFF0000FF);
$model->add_listener('moved', $view);

$app->add_event_handler( \&handle_event );

async {
    do {
        $plane->render();
        $view->render();
        $app->flip;
        Jogo::Event::Observable::consume_events;
    } while 1;
};

$app->run;


END {
    foreach(threads->list) { #(threads::joinable)
        if($_ != threads->self) {
            $_->detach;
        }
    }
}

sub handle_event {
    my $sevent = shift;
    my $type = $sevent->type;
    if ($type == SDL_QUIT) {
        return 0;
    } elsif ($type == SDL_KEYDOWN) {
        $model->x($model->x + 0.1);
    }
    return 1;
}

