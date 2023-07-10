export epgDephasing,epgRelaxation,epgRotation,rfRotation
export EPGStates, getStates

mutable struct EPGStates{T <: Real} 
  Fp::Vector{Complex{T}}
  Fn::Vector{Complex{T}}
  Z::Vector{Complex{T}}
end


function EPGStates(Fp::T=0,Fn::T=0,Z::T=1) where T <: Number
  T2 = ComplexF64
  return EPGStates(T2.([Fp]),T2.([Fn]),T2.([Z]))
end

function getStates(E::EPGStates)
    return stack([E.Fp,E.Fn,E.Z],dims=1)
end

"""
    epgDephasing(E::EPGStates, n=1) where T
  
shifts the transverse dephasing states `F` corresponding to n dephasing-cycles.
"""
function epgDephasing(E::EPGStates, n=1)
  
  if(abs(n)>1)
    for i in 1:abs(n)
      E = epgDephasing(E, (n > 0 ? +1 : -1))
    end
  elseif(n == 1 || n == -1)
    push!(E.Fp,0)
    push!(E.Fn,0)
    push!(E.Z,0)

    if n == 1   
      E.Fp = circshift(E.Fp,+1)# Shift positive F states right
      E.Fn = circshift(E.Fn,-1) # Shift negative F* states left

      # Update extremal states: F_{+0} using F*_{-0}, F*_{-max+1}=0
      E.Fp[1] = conj(E.Fn[1]);
      E.Fn[end] = 0;
    else # 
      E.Fp = circshift(E.Fp,-1)# Shift positive F states right
      E.Fn = circshift(E.Fn,+1) # Shift negative F* states left

      # Update extremal states: F_{+0} using F*_{-0}, F*_{-max+1}=0
      E.Fn[1] = conj(E.Fp[1]);
      E.Fp[end] = 0;
    end

  end
  
  return E
end 

"""
    epgRelaxation(E::EPGStates,t,T1, T2)

applies relaxation matrices to a set of EPG states.

# Arguments
* `E::EPGStates`
* `t::AbstractFloat`    - length of time interval
* `T1::AbstractFloat`   - T1
* `T2::AbstractFloat`   - T2
"""
function epgRelaxation(E::EPGStates,t,T1, T2)
  @. E.Fp = exp(-t/T2) * E.Fp
  @. E.Fn = exp(-t/T2) * E.Fn
  relaxedZ = fill!(copy(E.Z), 0)
  @. relaxedZ[2:end] = exp(-t/T1) * E.Z[2:end]
  relaxedZ[1] = exp.(-t./T1) * (E.Z[1]-1.0) + 1.0
  E.Z = relaxedZ
  return E
end

"""
    rfRotation_AT(alpha, phi=0.)

returns the rotation matrix for a pulse with flip angle `alpha` and phase `phi`.
"""
function rfRotation(alpha, phi=0.)
  R = [ cos(alpha/2.)^2   exp(2*im*phi)*sin(alpha/2.)^2   -im*exp(im*phi)*sin(alpha);
        exp(-2*im*phi)*sin(alpha/2.)^2   cos(alpha/2.)^2   im*exp(-im*phi)*sin(alpha);
        -im/2 .*exp(-im*phi)*sin(alpha)   im/2 .*exp(im*phi)*sin(alpha)   cos(alpha) ]
end


"""
    epgRotation(E::EPGStates, alpha::Float64, phi::Float64=0.0)

applies Bloch-rotation (<=> RF pulse) to a set of EPG states.

# Arguments
* `E::EPGStates``
* `alpha::Float64`           - flip angle of the RF pulse
* `phi::Float64=0.0`         - phase of the RF pulse
"""
function epgRotation(E::EPGStates, alpha::Real, phi::Real=0.0)
  # apply rotation to all states per default
  n = length(E.Z) # numStates

  R = rfRotation(alpha, phi)
  for i = 1:n
    E.Fp[i],E.Fn[i],E.Z[i] = R*[E.Fp[i]; E.Fn[i]; E.Z[i]]
  end

  return E
end