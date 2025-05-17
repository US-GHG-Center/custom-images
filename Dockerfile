# syntax=docker/dockerfile:1.4
FROM quay.io/jupyter/julia-notebook:2025-05-12

ENV JULIA_NUM_THREADS=3
ENV OMP_NUM_THREADS=1

USER ${NB_USER}
WORKDIR ${HOME}

# Update the conda enviroment first because the subsequent builds require the
# dependencies.
COPY environment.yml ./
RUN conda env update --name base --quiet --file environment.yml && rm environment.yml

USER root
WORKDIR /opt

# Clone and make bindx2
RUN <<EOT
    #!/bin/bash
    set -e

    git clone --depth 1 https://github.com/gmcgarragh/bindx2 bindx2
    cp bindx2/make.inc{.example,}
    make -C bindx2
    chown --recursive ${NB_UID}:${NB_GID} bindx2
EOT

# Clone xrtm
RUN <<EOT
    #!/bin/bash
    set -e

    git clone https://github.com/PeterSomkuti/xrtm.git xrtm
    git -C xrtm reset --hard b3aeace
    cp xrtm/make.inc{.example,}
EOT

# Patch and make xrtm
COPY make_xrtm.patch ./
RUN <<EOT
    #!/bin/bash
    set -e

    patch -d xrtm <make_xrtm.patch
    rm make_xrtm.patch

    # Various xrtm Makefiles use `${HOME}/bindx2` and `~/bindx2`, so we have to
    # "fudge" HOME to be `/opt`, since that's where we cloned the repo earlier.
    # Making the doc from tex will fail, because, again HOME is used, but we have
    # not cloned tth_C-4.03, so we --ignore-errors to avoid failing.
    HOME=/opt make -C xrtm --ignore-errors

    chown --recursive ${NB_UID}:${NB_GID} xrtm
EOT

USER ${NB_USER}
WORKDIR ${HOME}

# Install Julia Packages
RUN <<EOT
    julia -e '
        using Pkg;
        Pkg.add(
            [
                "ArgParse",
                "Dates",
                "DocStringExtensions",
                "HDF5",
                "Interpolations",
                "LaTeXStrings",
                "LinearAlgebra",
                "Logging",
                "LoopVectorization",
                "Plots",
                "Printf",
                "ProgressMeter",
                "Statistics",
                "StatsBase",
                "Unitful"
            ]
        );
        Pkg.precompile();
        Pkg.build();
    '
EOT
