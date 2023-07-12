using ForwardDiff

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
end

@testset "EPG-AD" begin
  #amp = MESE_EPG(60.0,1000.0,7,50,1) # Not used
  T2 = 60.0
  T1 = 1000.0
  TE = 7
  ETL = 50
  deltaB1 = 1

  # analytic gradient
  TE_vec = TE:TE:TE*50
  df = TE_vec .* exp.(-TE_vec./60.0)./(60^2) 

  # Automatic differentiation
  j = ForwardDiff.jacobian(x -> MESE_EPG(x,T1,TE,ETL,deltaB1),[60.0])
  @test vec(abs.(j)) ≈ df
end