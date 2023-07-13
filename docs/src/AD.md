# Automatic differentiation

This page shows how to use Automatic Differentiation in combination with an EPG
simulation. 

The AD package tested is
[ForwardDiff.jl](https://github.com/JuliaDiff/ForwardDiff.jl), maybe it works with others
with some minor modification to the following code.

## Load package
```@example AD
using EPGsim, ForwardDiff, CairoMakie
```

## Building signal function

```@example AD
function MESE_EPG(T2,T1,TE,ETL,delta)
  T = eltype(complex(T2))
  E = EPGStates([T(0.0)],[T(0.0)],[T(1.0)])
  echo_vec = Vector{Complex{eltype(T2)}}()

  E = epgRotation(E,pi/2*delta, pi/2)
  # loop over refocusing-pulses
  for i = 1:ETL
    E = epgDephasing(E,1)
    E = epgRelaxation(E,TE,T1,T2)
    E  = epgRotation(E,pi*delta,0.0)
    E  = epgDephasing(E,1)
    push!(echo_vec,E.Fp[1])
  end

  return abs.(echo_vec)
end;
```

!!! warning "Specific types with AD"
    ForwardDiff use a specific type : `Dual <: Real`. The target function must be written
    generically enough to accept numbers of type T<:Real as input (or arrays of these
    numbers).

    We also need to create an EPGStates that is of that type. We need to force it to be complex :
    ```julia
    T = eltype(complex(T2))
    E = EPGStates([T(0.0)],[T(0.0)],[T(1.0)])
    ```

## Define parameters for simulation and run it
```@example AD
T2 = 60.0
T1 = 1000.0
TE = 7
ETL = 50
deltaB1 = 1

TE_vec = range(TE,TE*ETL,ETL)

amp = MESE_EPG(T2,T1,TE,ETL,deltaB1)
lines(TE_vec,abs.(amp),axis =(;title = "MESE Signal", xlabel="TE [ms]"))
```

As expected, we get a standard T2 decaying exponential curve :

$$S(TE) = exp(-TE/T_2)$$

We can analytically derive the equation according to $T_2$ :

$$\frac{\partial S}{\partial T_2} = \frac{TE}{T_2^2} exp(-TE/T_2)$$

which give the following curves:

```@example AD
df = TE_vec .* exp.(-TE_vec./T2)./(T2^2) 

lines(TE_vec,abs.(df),axis =(;title = "dS/dT2", xlabel="TE [ms]"))
```

## Find the derivative with Automatic Differentiation

Because we want to obtain the derivate at multiple time points (TE), we will use `ForwardDiff.jacobian` :

```@example AD
j = ForwardDiff.jacobian(x -> MESE_EPG(x,T1,TE,ETL,deltaB1),[T2])
```

Let's compare it to the analytical equation :

```@example AD
f=Figure()
ax = Axis(f[1,1],title ="Analytic vs Automatic Differentiation")

lines!(ax,TE_vec,abs.(df),label = "Analytic Differentiation",linewidth=3)
lines!(ax,TE_vec,abs.(vec(j)),label = "Automatic Differentiation",linestyle=:dash,linewidth=3)
axislegend(ax)
f
```

Of course, in that case we don't really need the AD possibility. But if we reduce the B1+ value the equation becomes complicated enough and might lead to error during derivation if we don't use AD.

```@example AD
deltaB1 = 0.8

amp = MESE_EPG(T2,T1,TE,ETL,deltaB1)
j = ForwardDiff.jacobian(x -> MESE_EPG(x,T1,TE,ETL,deltaB1),[T2])

f = Figure()
ax = Axis(f[1,1], title = "MESE signal with B1 = $(deltaB1)",xlabel="TE [ms]")
lines!(ax,TE_vec,abs.(amp))
ax = Axis(f[1,2], title = "AD of MESE signal with B1 = $(deltaB1)",xlabel="TE [ms]")
lines!(ax,TE_vec,df)
f
```

## Differentiation along multiple variables
If we want to obtain the derivation along T1 and T2 we need to change the EPG_MESE function. The function should take as input a vector containing T2 and T1 (here noted T2/T1) :
```@example AD
function MESE_EPG2(T2T1,TE,ETL,delta)
  T2,T1 = T2T1
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

j2 = ForwardDiff.jacobian(x -> MESE_EPG2(x,TE,ETL,deltaB1),[T2,T1])
```
Here we can see that the second column corresponding to T1 is equal to 0 which is expected for a MESE sequence and the derivative along T2 gives the same results :

```@example AD
j2[:,1] ≈ vec(j)
```

## Reproducibility

This page was generated with the following version of Julia:
```@example AD
using InteractiveUtils
io = IOBuffer();
versioninfo(io);
split(String(take!(io)), '\n')
```

And with the following package versions

```@example AD
import Pkg; Pkg.status()
```
