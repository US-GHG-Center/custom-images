FROM quay.io/jupyter/julia-notebook:latest

#USER root

## Install Dependencies
#RUN apt update && apt install -y flex gfortran build-essential libopenblas-dev liblapack-dev

USER jovyan
## Env Variables
ENV JULIA_NUM_THREADS=3
ENV OMP_NUM_THREADS=1
ENV XRTM_PATH=/home/jovyan/xrtm

RUN conda install -y conda-forge::make flex gfortran gxx libopenblas binutils patch

RUN git clone https://github.com/gmcgarragh/bindx2 bindx2 && cd bindx2 \
    && cp make.inc.example make.inc && make

#RUN git clone https://github.com/gmcgarragh/xrtm.git xrtm && cd xrtm \
#    && cp make.inc.example make.inc && make

RUN git clone https://github.com/PeterSomkuti/xrtm.git xrtm && cd xrtm \
    && git checkout b3aeace && cp make.inc.example make.inc

# Patch XRTM makefile
COPY make_xrtm.patch xrtm/
RUN cd xrtm && patch < make_xrtm.patch
# build (making the doc from tex will fail, but that's fine..)
RUN cd xrtm && make; exit 0


#### Install Julia Packages
RUN julia -e 'using Pkg; Pkg.add(["Plots", "LaTeXStrings", "ArgParse", "Dates", "DocStringExtensions", "HDF5", "Interpolations", "LinearAlgebra", "Logging", "LoopVectorization", "Printf", "ProgressMeter", "Statistics", "StatsBase", "Unitful"]); Pkg.precompile()'

# todo: switch to use toml file with julia 
#RUN git clone https://github.com/US-GHG-Center/RetrievalToolbox.jl && \
#    julia --project=RetrievalToolbox.jl -e 'using Pkg; Pkg.instantiate()'
