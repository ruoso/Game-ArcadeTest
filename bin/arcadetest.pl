#!/usr/bin/perl
use 5.10.0;
use strict;
use warnings;

use SDL;
use SDL::Video;
use SDLx::App;
use SDL::Event;
use SDL::Events;

use lib 'lib';

use aliased 'Game::ArcadeTest::Controller::InGame';

my $app = SDLx::App->new
  ( title => "Bouncing Ball",
    width => 800,
    height => 600,
    flags => SDL_HWSURFACE | SDL_DOUBLEBUF | SDL_HWACCEL,
  );

my $start_time;
my $time;
my @maps = sort <share/maps/*.xml>;
my $controller = InGame->new( main_surface => $app,
                              mapname => shift @maps );

$app->add_event_handler(\&handle_event);
$app->add_show_handler(\&handle_frame);

sub handle_event {
    my $sevent = shift;
    my $type = $sevent->type;
    if ($type == SDL_QUIT) {
        return 0;
    } elsif ($type == SDL_USEREVENT) {
        my $nextmap = shift @maps;
        if ($nextmap) {
            $controller = InGame->new( main_surface => $app,
                                       mapname => $nextmap );
        } else {
            print 'Finished course in '.(($time - $start_time)/1000)."\n";
            return 0;
        }
    } elsif ($controller->handle_sdl_event($sevent)) {
        # handled.
    } else {
        # unknown event.
    }
    return 1;
}

sub handle_frame {
    my $oldtime = $time;
    $time = SDL::get_ticks;
    my $dt = ($time - $oldtime) / 1000;
    $controller->handle_frame($dt);
}

$start_time = $time = SDL::get_ticks;
$app->run;
