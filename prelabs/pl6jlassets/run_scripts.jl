
dir = @__DIR__
cd(dirname(@__FILE__))

"""
genplain(s)
Small helper function to run some code and redirect the output (stdout) to a file.
"""
function genplain(s::String)
    open(joinpath(dir, "output", "$(splitext(s)[1]).txt"), "w") do outf
        redirect_stdout(outf) do
            include(joinpath(dir, s))
        end
    end
end

using Plots; pyplot();
# using PyPlot;
# TODO: 
import PyPlot
rcParams = PyPlot.PyDict(PyPlot.matplotlib."rcParams")
config = Dict(
        "font.size" => 12,
        "axes.labelweight" => "bold",
        "axes.labelsize" => 12,
        "xtick.labelsize" => 11,
        "ytick.labelsize" => 11,
        "yaxis.labellocation" => "top",
        "xaxis.labellocation" => "right",
        "legend.fontsize" => 12,
        "legend.markerscale" => 0.8
)
merge!(rcParams, config)
colors = palette(:jet) #hide

##

# output
genplain("snippet1.jl")
genplain("snippet2.jl")
genplain("snippet3.jl")
genplain("snippet4.jl")
genplain("snippet5.jl")
genplain("snippet6.jl")
