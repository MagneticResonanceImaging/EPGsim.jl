using EPGsim
using Documenter

DocMeta.setdocmeta!(EPGsim, :DocTestSetup, :(using EPGsim); recursive=true)

makedocs(;
    modules=[EPGsim],
    authors="aTrotier <a.trotier@gmail.com> and contributors",
    repo="https://github.com/aTrotier/EPGsim.jl/blob/{commit}{path}#{line}",
    sitename="EPGsim.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://aTrotier.github.io/EPGsim.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/aTrotier/EPGsim.jl",
    devbranch="main",
)
