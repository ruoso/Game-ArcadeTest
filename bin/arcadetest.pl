#!/usr/bin/perl

use 5.10.0;
use strict;
use warnings;

use SDL ':all';
use SDL::Video;# ':all';
use SDL::Event;
use SDL::Events;

use lib 'lib';

use aliased 'Game::ArcadeTest::Controller::InGame';
use SDLx::Surface;

SDL::init( SDL_INIT_EVERYTHING );

my $display = SDL::Video::set_video_mode
  (800, 600, 16,
   SDL_HWSURFACE | SDL_DOUBLEBUF | SDL_HWACCEL );
my $fps = 30;

my $surf = SDLx::Surface->new(surface => $display);
my $sevent = SDL::Event->new();
my $time = SDL::get_ticks;
my $first_time = $time;

my @maps = sort <share/maps/*.xml>;

my $controller = InGame->new( main_surface => $surf,
                              mapname => shift @maps );

while (1) {
    my $oldtime = $time;
    my $now = SDL::get_ticks;

    while (SDL::Events::poll_event($sevent)) {
        my $type = $sevent->type;
        if ($type == SDL_QUIT) {
            exit;
        } elsif ($type == SDL_USEREVENT) {
            my $nextmap = shift @maps;
            if ($nextmap) {
                $controller = InGame->new( main_surface => $surf,
                                           mapname => $nextmap );
            } else {
                print 'Finished course in '.(($now - $first_time)/1000)."\n";
                exit;
            }
        } elsif ($controller->handle_sdl_event($sevent)) {
            # handled.
        } else {
            # unknown event.
        }
    }

    $controller->handle_frame($time, $now);

    my $delay = (1000/$fps) - ($time - $oldtime);
    $time = SDL::get_ticks;
    SDL::delay($delay) if $delay > 0;
}
