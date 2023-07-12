using EPGsim
using Documenter, Literate

# Generates examples with literate (removed)
#include("generate_lit.jl")

DocMeta.setdocmeta!(EPGsim, :DocTestSetup, :(using EPGsim); recursive=true)

makedocs(;
    modules=[EPGsim],
    authors="aTrotier <a.trotier@gmail.com> and contributors",
    repo="https://github.com/aTrotier/EPGsim.jl/blob/{commit}{path}#{line}",
    sitename="EPGsim.jl",
    doctest = true,
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://aTrotier.github.io/EPGsim.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Regular EPG " => "regular.md",
        #"Test literate" => "generated/01-autoDiff.md", # generated from literate
        "Automatic Differentiation" => "AD.md",
        "API" => "API.md",
        
    ],
)

deploydocs(;
    repo="github.com/aTrotier/EPGsim.jl",
    devbranch="main",
)
