FROM debian:11

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y wget tar git && rm -rf /var/lib/apt/lists/*

RUN wget https://s3-eu-west-1.amazonaws.com/deps.memgraph.io/toolchain-v4/toolchain-v4-binaries-debian-11-amd64.tar.gz

RUN git clone https://github.com/memgraph/memgraph.git

RUN tar xzvfm toolchain-v4-binaries-debian-11-amd64.tar.gz -C /opt

RUN ./memgraph/environment/os/debian-11.sh install TOOLCHAIN_RUN_DEPS
RUN ./memgraph/environment/os/debian-11.sh install MEMGRAPH_BUILD_DEPS
RUN ./memgraph/environment/os/debian-11.sh install TOOLCHAIN_BUILD_DEPS

RUN mkdir /src
COPY main.cpp /src
COPY lib.cpp /src
COPY CMakeLists.txt /src
WORKDIR /src

RUN bash -c "source /opt/toolchain-v4/activate; CC=clang CXX=clang++ cmake -B build_00 -S . -DCMAKE_BUILD_TYPE=RelWithDebInfo -D STATIC_LIB=0 -D STATIC_APP=0 && cmake --build build_00 -- -j"
RUN bash -c "source /opt/toolchain-v4/activate; CC=clang CXX=clang++ cmake -B build_01 -S . -DCMAKE_BUILD_TYPE=RelWithDebInfo -D STATIC_LIB=0 -D STATIC_APP=1 && cmake --build build_01 -- -j"
RUN bash -c "source /opt/toolchain-v4/activate; CC=clang CXX=clang++ cmake -B build_10 -S . -DCMAKE_BUILD_TYPE=RelWithDebInfo -D STATIC_LIB=1 -D STATIC_APP=0 && cmake --build build_10 -- -j"
RUN bash -c "source /opt/toolchain-v4/activate; CC=clang CXX=clang++ cmake -B build_11 -S . -DCMAKE_BUILD_TYPE=RelWithDebInfo -D STATIC_LIB=1 -D STATIC_APP=1 && cmake --build build_11 -- -j"

ENTRYPOINT bash -c "source /opt/toolchain-v4/activate; \
/src/build_00/loader 'RTLD_NOW|RTLD_GLOBAL'; \
/src/build_00/loader 'RTLD_NOW|RTLD_LOCAL'; \
/src/build_00/loader 'RTLD_NOW|RTLD_GLOBAL|RTLD_DEEPBIND'; \
/src/build_00/loader 'RTLD_NOW|RTLD_LOCAL|RTLD_DEEPBIND'; \
/src/build_00/loader 'RTLD_LAZY|RTLD_GLOBAL'; \
/src/build_00/loader 'RTLD_LAZY|RTLD_LOCAL'; \
/src/build_00/loader 'RTLD_LAZY|RTLD_GLOBAL|RTLD_DEEPBIND'; \
/src/build_00/loader 'RTLD_LAZY|RTLD_LOCAL|RTLD_DEEPBIND'; \
/src/build_01/loader 'RTLD_NOW|RTLD_GLOBAL'; \
/src/build_01/loader 'RTLD_NOW|RTLD_LOCAL'; \
/src/build_01/loader 'RTLD_NOW|RTLD_GLOBAL|RTLD_DEEPBIND'; \
/src/build_01/loader 'RTLD_NOW|RTLD_LOCAL|RTLD_DEEPBIND'; \
/src/build_01/loader 'RTLD_LAZY|RTLD_GLOBAL'; \
/src/build_01/loader 'RTLD_LAZY|RTLD_LOCAL'; \
/src/build_01/loader 'RTLD_LAZY|RTLD_GLOBAL|RTLD_DEEPBIND'; \
/src/build_01/loader 'RTLD_LAZY|RTLD_LOCAL|RTLD_DEEPBIND'; \
/src/build_10/loader 'RTLD_NOW|RTLD_GLOBAL'; \
/src/build_10/loader 'RTLD_NOW|RTLD_LOCAL'; \
/src/build_10/loader 'RTLD_NOW|RTLD_GLOBAL|RTLD_DEEPBIND'; \
/src/build_10/loader 'RTLD_NOW|RTLD_LOCAL|RTLD_DEEPBIND'; \
/src/build_10/loader 'RTLD_LAZY|RTLD_GLOBAL'; \
/src/build_10/loader 'RTLD_LAZY|RTLD_LOCAL'; \
/src/build_10/loader 'RTLD_LAZY|RTLD_GLOBAL|RTLD_DEEPBIND'; \
/src/build_10/loader 'RTLD_LAZY|RTLD_LOCAL|RTLD_DEEPBIND'; \
/src/build_11/loader 'RTLD_NOW|RTLD_GLOBAL'; \
/src/build_11/loader 'RTLD_NOW|RTLD_LOCAL'; \
/src/build_11/loader 'RTLD_NOW|RTLD_GLOBAL|RTLD_DEEPBIND'; \
/src/build_11/loader 'RTLD_NOW|RTLD_LOCAL|RTLD_DEEPBIND'; \
/src/build_11/loader 'RTLD_LAZY|RTLD_GLOBAL'; \
/src/build_11/loader 'RTLD_LAZY|RTLD_LOCAL'; \
/src/build_11/loader 'RTLD_LAZY|RTLD_GLOBAL|RTLD_DEEPBIND'; \
/src/build_11/loader 'RTLD_LAZY|RTLD_LOCAL|RTLD_DEEPBIND'; \
";
