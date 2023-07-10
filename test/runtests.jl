using EPGsim
using Test
using ForwardDiff

@testset "EPGsim.jl" begin
    include("EPG/test_regular.jl")
    include("test_AD.jl")
end
