using WaterLily
function circle(n,m;Re=250,U=1)
    radius, center = m/8, m/2
    body = AutoBody((x,t)->√sum(abs2, x .- center) - radius)
    Simulation((n,m), (U,0), radius; ν=U*radius/Re, body)
end

# include("TwoD_plots.jl")
# sim_gif!(circle(3*2^6,2^7),duration=10,clims=(-5,5),plotbody=true)

n = 3*2^6
m = 2^7
Re = 250
U = 1
radius, center = m/8, m/2
body = AutoBody((x,t)->√sum(abs2, x .- center) - radius)
sim = Simulation((n,m), (U,0), radius; ν=U*radius/Re, body)
sim_step!(sim,2)

# _ = WaterLily.∮nds(sim.flow.p,sim.flow.V,body,5)
_ = WaterLily.∮nds2(sim.flow.p,sim.flow.V,body,5)