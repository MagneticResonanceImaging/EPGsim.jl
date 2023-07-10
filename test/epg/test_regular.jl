@testset "EPG" begin
  # test empty
  E=EPGStates()
  @test E.Fp == [0] && E.Fn == [0] && E.Z == [1]

  # test pulse
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
end