FROM quay.io/jupyter/julia-notebook:latest

#USER root

## Install Dependencies
#RUN apt update && apt install -y flex gfortran build-essential libopenblas-dev liblapack-dev

#USER jovyan
## Env Variables
ENV JULIA_NUM_THREADS=3
ENV OMP_NUM_THREADS=1

RUN conda install -y conda-forge::make flex gfortran libopenblas

RUN git clone https://github.com/gmcgarragh/bindx2 bindx2 && cd bindx2 \
    && cp make.inc.example make.inc && make
 
RUN git clone https://github.com/gmcgarragh/xrtm.git xrtm && cd xrtm \
    && cp make.inc.example make.inc && make

#RUN git clone https://github.com/PeterSomkuti/xrtm.git xrtm && cd xrtm \
#    && cp make.inc.example make.inc && make

    

#### Install Julia Packages
RUN julia -e 'using Pkg; Pkg.add(["Plots", "LaTeXStrings", "ArgParse", "Dates", "DocStringExtensions", "HDF5", "Interpolations", "LinearAlgebra", "Logging", "LoopVectorization", "Printf", "ProgressMeter", "Statistics", "StatsBase", "Unitful"])'
# todo: switch to use toml file with julia 
#RUN git clone https://github.com/US-GHG-Center/RetrievalToolbox.jl && \
#    julia --project=RetrievalToolbox.jl -e 'using Pkg; Pkg.instantiate()'