FROM docker.io/savonet/liquidsoap:main

USER root

LABEL version="1.0.5" maintainer="jns@gellyfish.co.uk"

RUN groupadd -r raku && useradd -m -k -r -g  raku raku

ARG rakudo_version=2021.05
ENV rakudo_version=${rakudo_version}
ENV PATH=$PATH:/usr/share/perl6/site/bin

RUN id

RUN buildDeps=' \
        curl \
        gcc \
        libc6-dev \
        libencode-perl \
        git \
        libssl-dev \
        make \
		icecast2 \
		libshout3 \
    ' \
    && set -x \
    && apt-get update \
    && apt-get --yes install --no-install-recommends $buildDeps 

RUN url="https://github.com/rakudo/rakudo/releases/download/${rakudo_version}/rakudo-${rakudo_version}.tar.gz" \
    tmpdir="$(mktemp -d)" \
    && mkdir ${tmpdir}/rakudo \
    && curl -fsSL $url -o ${tmpdir}/rakudo.tar.gz \
    && tar xzf ${tmpdir}/rakudo.tar.gz --strip-components=1 -C ${tmpdir}/rakudo \
    && ( \
        cd ${tmpdir}/rakudo \
        ls rakudo/3rd-party \
        && perl Configure.pl --prefix=/usr --gen-moar --gen-nqp --backends=moar\
        && make install \
    ) \
    && rm -rf $tmpdir

RUN tmpdir="$(mktemp -d)" \
    && cd $tmpdir \
    && git clone https://github.com/ugexe/zef.git \
    && prove -v -e 'raku -I zef/lib' zef/t \
    && raku -Izef/lib zef/bin/zef --verbose install ./zef \
    && rm -rf $tmpdir 

RUN zef install --/test --test-depends Test::META CheckSocket Test::Util::ServerPort File::Which AccessorFacade LibraryCheck

ADD ./etc /etc
RUN chown -R icecast2 /etc/icecast2


WORKDIR /home/raku

CMD ["raku"]
