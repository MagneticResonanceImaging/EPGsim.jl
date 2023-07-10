using EPGsim
using Test
using ForwardDiff

@testset "EPGsim.jl" begin
    include("epg/test_regular.jl")
    include("test_AD.jl")
end
