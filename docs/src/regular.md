EPG implementation that mimics the regular implementation from Julien Lamy in
[Sycomore](https://github.com/lamyj/sycomore/blob/master/src/sycomore/epg/Regular.cpp#L342)

# Short description
Regular implementation use a constant positive or negative gradient dephasing.
We use a vector Fp, Fn and Z to store the states.


# Initialization
EPG states are stored as a structure :
```
mutable struct EPGStates{T <: Real} 
  Fp::Vector{Complex{T}}
  Fn::Vector{Complex{T}}
  Z::Vector{Complex{T}}
end
```

which can be initialized with default parameters Fp = 0, Fn = 0 and Z = 1 states using :
```@example Regular
using EPGsim
E = EPGStates()
```

or by :

```@example Regular
E = EPGStates(0,0,1)
```

which convert any numbers of the same types in `Vector{ComplexF64}`

or directly by passing `Vector{Complex{T}} where {T <: Real}` which means it can accept a complex{dual} type :
```@example Regular
T = ComplexF32
E = EPGStates(T.([0.5+0.5im,1]),T.([0.5-0.5im,0]),T.([1,0]))
```

!!! warning
    the F+[1] and F-[1] states should be complex conjugate and imag(Z[1])=0 

# EPG simulation
3 functions are used to simulate a sequence :
- epgDephasing
- epgRelaxation
- epgRotation

They take an `EPGStates` struct as first parameter.

```@example Regular
E = EPGStates()
E = epgRotation(E,deg2rad(60),0)
E = epgDephasing(E,1)
E = epgRotation(E,deg2rad(60),deg2rad(117))
```

# Accessing states
States can seen directly as a vector :
```@example Regular
E.Fp
```

or by elements :
```@example Regular
E.Fp[2]
```

`getStates` is also available to create a 3xN matrix where 3 corresponds to Fp,Fn,Z and N is the number of states.

```@example Regular
getStates(E)
```