FROM savonet/liquidsoap-full

LABEL version="1.0.1" maintainer="jns@gellyfish.co.uk"

ENV DEBIAN_FRONTEND noninteractive

RUN groupadd -r raku && useradd -m -k -r -g  raku raku

ARG rakudo_version=2020.02.1
ENV rakudo_version=${rakudo_version}
ENV PATH=$PATH:/usr/share/perl6/site/bin

RUN buildDeps=' \
        gcc \
        libc6-dev \
        libencode-perl \
        libssl-dev \
        make \
		icecast2 \
		libshout3 \
    ' \
    url="https://github.com/rakudo/rakudo/releases/download/${rakudo_version}/rakudo-${rakudo_version}.tar.gz" \
    tmpdir="$(mktemp -d)" \
    && set -x \
    && apt-get update \
    && apt-get --yes install --no-install-recommends $buildDeps \
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
    && zef install Test::Meta CheckSocket Test::Util::ServerPort File::Which AccessorFacade LibraryCheck \
    && rm -rf $tmpdir 

ADD ./etc /etc
RUN chown -R icecast2 /etc/icecast2


WORKDIR /home/raku

CMD ["raku"]
