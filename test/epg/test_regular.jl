function MESE_EPG_thresh(T2,T1,TE,ETL,delta,thresh)
  T = eltype(complex(T2))
  E = EPGStates([T(0.0)],[T(0.0)],[T(1.0)])
  echo_vec = Vector{Complex{eltype(T2)}}()

  E = epgRotation(E,pi/2*delta, pi/2)
  # loop over refocusing-pulses
  R = rfRotation(pi*delta,0.0)
  for i = 1:ETL
    E = epgDephasing(E,1,thresh)
    E = epgRelaxation(E,TE,T1,T2)
    E  = epgRotation(E,R)
    E  = epgDephasing(E,1,thresh)
    push!(echo_vec,E.Fp[1])
  end

  return abs.(echo_vec)
end

@testset "EPG" begin
  # test empty
  E=EPGStates()
  @test E.Fp == [0] && E.Fn == [0] && E.Z == [1]

  # test initialization

  @test_throws "Fp[1] should be complex conjugate to Fn[1]" E=EPGStates(1+2im,1+0im,1+0im)
  @test_throws "imaginary part of Z[1] should be equal to 0" E=EPGStates(1+2im,1-2im,1+2im)
 
  # test pulse
  E=EPGStates()
  E = epgRotation(E,deg2rad(47),deg2rad(23))
  @test getStates(E) ≈ [
      0.2857626571584661 - im*0.6732146319308543, 
      0.2857626571584661 + im*0.6732146319308543, 
      0.6819983600624985]

  #test positive gradient
  E = epgDephasing(E,1)
  @test getStates(E) ≈ [[0, 0, 0.6819983600624985];;
  [0.2857626571584661 - im * 0.6732146319308543, 0, 0]]

  # test negative gradient
  E = EPGStates()
  E = epgRotation(E,deg2rad(47),deg2rad(23))
  E = epgDephasing(E,-1)
  @test getStates(E) ≈ [[0, 0, 0.6819983600624985];;
  [0, 0.2857626571584661 + im * 0.6732146319308543, 0]]

  # test multiple gradient
  E = EPGStates()
  E = epgRotation(E,deg2rad(47),deg2rad(23))
  E = epgDephasing(E,-2)
  E = epgRotation(E,deg2rad(47),deg2rad(23))
  E = epgDephasing(E,1)
  @test getStates(E) ≈ [[0, 0, 0.4651217631279373];; 
  [0.19488966354917586-im*0.45913127494692113, 0.240326160353821+im*0.5661729534388877,0];;
  [0, 0, -0.26743911843603135];;
  [-0.045436496804645087+im*0.10704167849196657, 0, 0]]
  
  # test relaxation
  E = EPGStates()
  E = epgRotation(E,deg2rad(47),deg2rad(23))
  E = epgDephasing(E,1)
  E = epgRelaxation(E,10,1000,100)
  @test getStates(E) ≈ [[0, 0, 0.6851625292479138];;
  [0.2585687448743616 - im*0.6091497893403431, 0, 0]]

  # test threshold
  E = EPGStates([0+0*im,0+0.5im,0+0.01im],[0+0*im,0+0.5im,0+0.01im],[1+0*im,0+0im,0+0.0im])
  E = epgDephasing(E,1,10e-2)

  @test getStates(E) ≈ [[0-0.5im, 0+0.5im, 1];; 
  [0, 0+0.01im, 0];;
  [0.5im, 0,0]]

  # benchmark

  b = @benchmark MESE_EPG_thresh(60.0,1000.0,7.0,50,0.9,10e-20)
  @info "With threshold 10e-20 :\n 
  time = $(median(b).time/1000) us\n
  memory = $(median(b).memory)\n
  allocs = $(median(b).allocs)\n
  gctimes = $(median(b).gctime) ns\n"

  b = @benchmark MESE_EPG_thresh(60.0,1000.0,7.0,50,0.9,10e-6)
  @info "With threshold 10e-6 :\n 
  time = $(median(b).time/1000) us\n
  memory = $(median(b).memory)\n
  allocs = $(median(b).allocs)\n
  gctimes = $(median(b).gctime) ns\n"
  
  
end