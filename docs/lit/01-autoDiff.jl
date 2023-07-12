#---------------------------------------------------------
# # [Automatic Differentiation](@id 01-autoDiff)
#---------------------------------------------------------

#=
## Description

This example described how to use Automatic Differentiation with the package
**ForwardDiff.jl** on a Multi-Echo Spin-Echo (MESE) sequence.
=#

# ## Setup
using CairoMakie
using EPGsim
using ForwardDiff

# ## MESE function
# First we need a function that returns the echo amplitudes at n*TE.
# We need to make sure that the EPGStates object will have a type Complex{T} where T can
# be a Float or a Dual number used by `ForwardDiff`

function MESE_EPG(T2,T1,TE,ETL,delta)
    T = complex(eltype(T2))
    E = EPGStates([T(0.0)],[T(0.0)],[T(1.0)])
    echo_vec = Vector{Complex{eltype(T2)}}()
  
    E = epgRotation(E,pi/2*delta, pi/2)
    ##loop over refocusing-pulses
    for i = 1:ETL
      E = epgDephasing(E,1)
      E = epgRelaxation(E,TE,T1,T2)
      E  = epgRotation(E,pi*delta,0.0)
      E  = epgDephasing(E,1)
      push!(echo_vec,E.Fp[1])
    end
  
    return abs.(echo_vec)
  end

# Let's see if we can see a T₂ decaying exponential curve with B₁=1.0
T2 = 60.0
T1 = 1000.0
TE = 7
ETL = 50
deltaB1 = 1
TE_vec = range(7,50*7,50)

amp = MESE_EPG(T2,T1,TE,ETL,deltaB1)
j = ForwardDiff.jacobian(x -> MESE_EPG(x,T1,TE,ETL,deltaB1),[60.0])
lines(TE_vec,amp)

#=
The derivative of the function f:
$$f(x) = \exp(-\frac{TE}{T_2})$$
according to the variable T₂ gives :
=#
df = TE_vec .* exp.(-TE_vec./T2)./(T2^2) 

lines(TE_vec,df,axis =(;title = "dS/dT2", xlabel="TE [ms]"))

# ## perform AD
j = ForwardDiff.jacobian(x -> MESE_EPG(x,T1,TE,ETL,deltaB1),[T2])
# ## Reproducibility

# This page was generated with the following version of Julia:
using InteractiveUtils
io = IOBuffer();
versioninfo(io);
split(String(take!(io)), '\n')

# And with the following package versions
import Pkg; Pkg.status()
