```@meta
CurrentModule = EPGsim
```

# EPGsim

*Extended Phase Graph simulation*

## Introduction

EPGsim is a Julia packet for magnetic resonance imaging signal simulation based on the Extended Phase Graph (EPG) concept.
The principal aspect of this package was to make it compatible with Automatic Differentiation using `ForwardDiff.jl` in order to compute [Cramér-Rao Lower Bound](https://en.wikipedia.org/wiki/Cram%C3%A9r%E2%80%93Rao_bound) metrics which is used to optimized sequence protocol.

!!! note
    EPGsim.jl is work in progress and in some parts not entirely optimized. The interface is susceptible to change between version

## EPG concept 
Introduction to the physics concepts behing EPG as well as their usage can be found on the rad229 youtube channels by Brian Hargreaves and Daniel Ennis :
- [Lecture-04A: Definition of the Extended Phase Graph Basis](https://www.youtube.com/watch?v=bskhnaoJVNY)
- [Lecture-04B: Sequence Operations in the Extended Phase Graph Domain](https://www.youtube.com/watch?v=kToL-9ZTzCs)
- [Lecture-04C: Examples using Extended Phase Graphs](https://www.youtube.com/watch?v=O9JH2f6c3cs)




## Installation
This package is currently not registered.

Start julia and open the package mode by entering `]`. Then enter
```julia
add https://github.com/aTrotier/EPGsim.jl
```
This will install `EPGsim` and all its dependencies. If you want to develop
`EPGsim` itself you can checkout `EPGsim` by calling
```julia
dev https://github.com/aTrotier/EPGsim.jl
```
More information on how to develop a package can be found in the Julia documentation.

## Tutorial

You can find an example about simulation of a Multi-Echo Spin-Echo sequence and its derivation [here](https://atrotier.github.io/EPGsim.jl/dev/AD/)