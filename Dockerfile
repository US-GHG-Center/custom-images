# syntax=docker/dockerfile:1.4
# Date tag alias for digest 8e7654a6d2c7: 2025-05-12
FROM quay.io/jupyter/julia-notebook:8e7654a6d2c7

ENV JULIA_NUM_THREADS=3
ENV OMP_NUM_THREADS=1

WORKDIR /opt

# Update the conda enviroment first because the subsequent builds require the
# dependencies.
COPY enviroment.yml ./
RUN conda env update -f environment.yml; rm environment.yml

# Clone and make bindx2
RUN <<EOT
    #!/bin/bash

    git clone --depth 1 https://github.com/gmcgarragh/bindx2 bindx2
    cp bindx2/make.inc{.example,}
    make -C bindx2
EOT

# Clone, patch, and make xrtm
COPY make_xrtm.patch xrtm
RUN <<EOT
    #!/bin/bash

    git clone --depth 1 https://github.com/PeterSomkuti/xrtm.git xrtm
    git -C xrtm reset --hard b3aeace
    cp xrtm/make.inc{.example,}
    patch -d xrtm <make_xrtm.patch
    rm xrtm/make_xrtm.patch
    make -C xrtm || true  # making the doc from tex will fail, but that's fine
EOT

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
        )
    '
EOT
