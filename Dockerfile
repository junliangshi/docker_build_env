FROM quay.io/pypa/manylinux1_x86_64

SHELL ["/bin/bash", "-c"]

COPY build_gcc.sh /tmp/
COPY build_llvm.sh /tmp/

RUN /tmp/build_gcc.sh
RUN /tmp/build_llvm.sh
