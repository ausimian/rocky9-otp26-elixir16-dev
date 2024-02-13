FROM rockylinux:9 AS builder

RUN  yum -y update
RUN  yum -y group install "Development Tools"
RUN  yum -y install wget zlib-devel pcre-devel perl-core ncurses-devel
RUN  yum -y install openssl-devel

WORKDIR /src

RUN  wget --quiet https://github.com/erlang/otp/releases/download/OTP-26.2.2/otp_src_26.2.2.tar.gz && \
     tar xzf otp_src_26.2.2.tar.gz
RUN  cd otp_src_26.2.2 && \
     ./configure --prefix=/usr/local \
                 --enable-jit \
                 --with-ssl   \
                 --without-javac \
                 --without-megaco \
                 --without-odbc && \
     make -j && \
     make DESTDIR=/tmp/otp install

FROM rockylinux:9
RUN  yum -y update
RUN  yum -y install wget unzip glibc-locale-source glibc-langpack-en
COPY --from=builder /tmp/otp/usr/local /usr/local
RUN  cd /usr/local && \
     wget --quiet https://github.com/elixir-lang/elixir/releases/download/v1.16.1/elixir-otp-26.zip && \
     unzip elixir-otp-26.zip && \
     rm -f elixir-otp-26.zip
RUN  localedef -c -f UTF-8 -i en_US en_US.UTF-8
ENV  LC_ALL=en_US.UTF-8

RUN  mix local.hex --force
RUN  mix local.rebar --force
