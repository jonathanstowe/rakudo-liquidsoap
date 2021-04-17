# Rakudo Liquidsoap

This provides a docker image that has the Raku programming language built on top of the [Savonet Liquidsoap](https://hub.docker.com/r/savonet/liquidsoap) image.  It also has [icecast](http://icecast.org/) and [libshout](https://gitlab.xiph.org/xiph/icecast-libshout/) installed.

The purpose of this image is primarily for testing Raku audio streaming applications.

It should track the latest released version of `liquidsoap`.

## Building

To build it locally you can just do:

     docker build -t rakudo-liquidsoap .

This should work equally well with `podman` which may be preferred on some Linux distributions.

The liquidsoap image is quite large (the liquidsoap application has a lot of dependencies,) so this may take some time.

## Usage

This was originally intended to facilitate easier and quicker testing of
the Raku module [Audio::Liquidsoap](https://github.com/jonathanstowe/Audio-Liquidsoap/), so assuming you already have a checkout of the module then you might do something like:

    docker run --entrypoint sh  -it -v  .:/home/raku jonathanstowe/rakudo-liquidsoap -c "zef install --deps-only . && zef test --debug -v ."

This also works with `podman` however for some distributions of Linux which implement SELinux you may have to specify the `--privileged` option in order for the volume mount of the CWD to work properly:

    podman run --entrypoint sh -it --privileged -v  .:/home/raku jonathanstowe/rakudo-liquidsoap -c "zef install --deps-only . && zef test --debug -v ."

This image doesn't actually start a liquidsoap daemon ( the `Audio::Liquidsoap` tests start one listening on a new port as needed,) so if you want to create an application using this you will probably derive a new image from this one, install your own dependencies and start the `liquidsoap` yourself.

The icecast configuation is the minimum required for testing, but if you need it you will need to start it yourself  something like:

    docker run --entrypoint sh -t -v  `pwd`:/home/raku jonathanstowe/rakudo-liquidsoap  -c "service icecast2 start && zef install --deps-only . && zef test --debug -v ."

Of course the option is there for you to start it with your own configuation.

## Support

Really this needs some other things in it to be universally useful, and I may get round to adding them at some point but if there is something you need changing please make an issue on [github](https://github.com/jonathanstowe/rakudo-liquidsoap/issues)

## Licence

This is largely derived from the work in [rakudo-nostar](https://github.com/JJ/rakudo-nostar) and is released under a free software [licence](LICENCE).


