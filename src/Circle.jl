# TODO figure out best representation

struct Circle <: Geometry
    data::SVector{2,Float64}
	r::Float64
end

Circle(x, y, r::T) where {T<:Real} = Circle(SVector{2,Float64}(x, y), Float64(r))
Circle(P::SVector{2,Float64}, r::T) where {T<:Real}= Circle(P, Float64(r))
Circle(data::Array) = Circle(data[1], data[2], data[3])
precompile(Circle, (Float64, Float64, Float64))

Base.show(io::IO, a::Circle) = print(io, "Circle: O = ", a.data, ", r = ", a.r)

# TODO add boundary condition checks
function draw!(image::Array{T,2}, circle::Circle; value=0, fill::Bool=true) where {T<:Union{Real,Color}}
	P = circle.data;
	r::Float64 = round.(circle.r);
	Xf = -r:r;
	Y1::Array{Int,1} = round.(Int, sqrt.(r^2 .- Xf.^2) .+ P[2]);
	Y2::Array{Int,1} = -Y1 .+ round.(Int, 2*P[2]);
	X::Array{Int,1} = round.(Int, Xf .+ P[1]);

	image_size = collect(size(image));

	if (fill)
		for i = 1:size(X,1)
			for j = Y2[i]:Y1[i]
				image[X[i], j] = value;
			end
		end
	else
		for i = 1:size(X,1)
			image[X[i], Y1[i]] = value; # Need a better non-fill implementation
			image[X[i], Y2[i]] = value;
		end
	end
end

#=

function draw!(image::Array{UInt8,2}, circle::Circle, value)
	P = circle.data;
	r::Float64 = circle.r;

	i = (0:1/(pi*r):2*pi)' # TODO figure out what this actually should be
	X = round.(Int, r.*[cos.(i); sin.(i)] .+ P); # TODO try rotating a vector instead of calculating sine and cosine constantly

	image_size = collect(size(image));
	for i = 1:size(X,2)
		if (!(minimum(X[:,i]) < 1) && !(minimum(image_size - X[:,i]) < 0))
			image[X[1,i], X[2,i]] = 255;
		end
	end
	return image;
end

function draw!(image::Array{UInt8,2}, circle::Circle, fill::Bool)
	if (fill)
		for i = 1:round(circle.r)
			image = draw!(image, Circle(circle.data, i))
		end
		image[round(Int, circle[1]), round(Int, circle[2])] = 255;
	else
		image = draw!(image, circle);
	end
	return image;
end
=#


# Original runtime: ~0.024748 seconds
# Runtime after moving image[P[1], P[2]] outside of loop: 0.023427
