using EPGsim
using Documenter, Literate

# Generates examples with literate (removed)
#include("generate_lit.jl")

DocMeta.setdocmeta!(EPGsim, :DocTestSetup, :(using EPGsim); recursive=true)

makedocs(;
    modules=[EPGsim],
    authors="aTrotier <a.trotier@gmail.com> and contributors",
    repo="https://github.com/MagneticResonanceImaging/EPGsim.jl/blob/{commit}{path}#{line}",
    sitename="EPGsim.jl",
    doctest = true,
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://MagneticResonanceImaging.github.io/EPGsim.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Regular EPG " => "regular.md",
        #"Test literate" => "generated/01-autoDiff.md", # generated from literate
        "Automatic Differentiation" => "AD.md",
        "Examples" => ["MP2RAGE.md"],
        "API" => "API.md",
        
    ],
)

deploydocs(;
    repo="github.com/MagneticResonanceImaging/EPGsim.jl",
    devbranch="main",
)
