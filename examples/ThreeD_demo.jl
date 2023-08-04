using WaterLily
using StaticArrays
norm(x::StaticArray) = √(x'*x)

function make_sim(;n=2^6, U=1, Re=1000, mem=Array)
    # define the body
    R = n/2
    function sdf(xyz,t)  # signed-distance function
        # norm(xyz)-R # sphere
        x,y,z = xyz
        r = norm(SA[y,z]); r-R # cylinder
        norm(SA[x,r-min(r,R)])-1.5 # disk
    end
    map(xyz,t) = xyz-SA[2n/3,0,0] # place/move the center
    
    # Return simulation
    return Simulation((2n,n,n), (U,0,0), R;
    ν=U*R/Re, body=AutoBody(sdf,map), mem)
end


using GLMakie
using CUDA: CUDA
@assert CUDA.functional()
sim = make_sim(mem=CUDA.CuArray);

include("ThreeD_Plots.jl")
# GLMakie.mesh(body_mesh(sim),color=:lightblue);
display(GLMakie.mesh(body_mesh(sim),color=:lightblue));
sim_step!(sim,0.2)

dat = flow_λ₂(sim);
obs = dat |> Observable;
colormap = :viridis |> to_colormap |> reverse;
# contour!(obs;colormap,levels=1,isorange=0.49,alpha=0.1);
display(contour!(obs;colormap,levels=1,isorange=0.49,alpha=0.1));

for _ in 1:500
    sim_step!(sim, sim_time(sim) + 0.02, remeasure=false);
    flow_λ₂!(dat, sim);
    notify(obs)
    display(contour!(obs;colormap,levels=1,isorange=0.49,alpha=0.1));
    sleep(0.1);
end

