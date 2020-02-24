FROM savonet/liquidsoap-full

LABEL version="1.0.0" maintainer="jns@gellyfish.co.uk"

RUN groupadd -r raku && useradd -m -k -r -g  raku raku

ARG rakudo_version=2020.01
ENV rakudo_version=${rakudo_version}
ENV PATH=$PATH:/usr/share/perl6/site/bin

RUN buildDeps=' \
        gcc \
        libc6-dev \
        libencode-perl \
        libssl-dev \
        make \
    ' \
    url="https://github.com/rakudo/rakudo/releases/download/2020.01/rakudo-${rakudo_version}.tar.gz" \
    tmpdir="$(mktemp -d)" \
    && set -x \
    && apt-get update \
    && apt-get --yes install --no-install-recommends $buildDeps \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir ${tmpdir}/rakudo \
    \
    && curl -fsSL $url -o ${tmpdir}/rakudo.tar.gz \
    \
    && tar xzf ${tmpdir}/rakudo.tar.gz --strip-components=1 -C ${tmpdir}/rakudo \
    && ( \
        cd ${tmpdir}/rakudo \
        ls rakudo/3rd-party \
        && perl Configure.pl --prefix=/usr --gen-moar --gen-nqp --backends=moar\
        && make install \
    ) \
    \
    && cd $tmpdir \
    && git clone https://github.com/ugexe/zef.git \
    && prove -v -e 'raku -I zef/lib' zef/t \
    && perl6 -Izef/lib zef/bin/zef --verbose install ./zef \
    && zef install Test::Meta CheckSocket Test::Util::ServerPort File::Which \
    && rm -rf $tmpdir 

WORKDIR /home/raku

CMD ["raku"]
