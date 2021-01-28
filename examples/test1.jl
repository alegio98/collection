using Test
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation

#aggiunta da me

@testset "cuboid Tests" begin
	square=Lar.cuboid([1,1])    #quadrato quindi sono settate solamente 2 variabili per rendere il cubo in 2D
	cube=Lar.cuboid([1,1,1])    #cubo quindi sono settate 3 variabili cubo rappresentato quidi 3D
	@testset "cuboid Tests 2D" begin
		@test typeof(square)==Tuple{Array{Float64,2},Array{Array{Int64,1},1}}       #tipo del quadrato ci aspetteremo una tupla di 2 array di tipo float e int
		@test length(square)==2														#lunghezza del quadrato
		@test size(square[1])==(2, 4)
	end
	@testset "cuboid Tests 3D" begin
		@test typeof(cube)==Tuple{Array{Float64,2},Array{Array{Int64,1},1}}
		@test length(cube)==2
		@test size(cube[1])==(3, 8)
	end
end

@testset "2D" begin
	square = ([[0.; 0] [0; 1] [1; 0] [1; 1]], [[1, 2, 3,
			4]], [[1,2], [1,3], [2,4], [3,4]])
	@testset "apply Translation 2D" begin
		@test typeof(Lar.apply(Lar.t(-0.5,-0.5),square))==Tuple{Array{Float64,2},Array{Array{Int64,1},1},Array{Array{Int64,1},1}}
		@test Lar.apply(Lar.t(-0.5,-0.5),square)==([-0.5 -0.5 0.5 0.5; -0.5 0.5 -0.5 0.5], Array{Int64,1}[[1, 2, 3, 4]], Array{Int64,1}[[1, 2], [1, 3], [2, 4], [3, 4]])
	end
	@testset "apply Scaling 2D" begin
		@test typeof(Lar.apply(Lar.s(-0.5,-0.5),square))==Tuple{Array{Float64,2},Array{Array{Int64,1},1},Array{Array{Int64,1},1}}
		@test Lar.apply(Lar.s(-0.5,-0.5),square)==([0.0 0.0 -0.5 -0.5; 0.0 -0.5 0.0 -0.5], Array{Int64,1}[[1, 2, 3, 4]], Array{Int64,1}[[1, 2], [1, 3], [2, 4], [3, 4]])
	end
	@testset "apply Rotation 2D" begin
		@test typeof(Lar.apply(Lar.r(0),square))==Tuple{Array{Float64,2},Array{Array{Int64,1},1},Array{Array{Int64,1},1}}
		@test Lar.apply(Lar.r(0),square)==([0.0 0.0 1.0 1.0; 0.0 1.0 0.0 1.0], Array{Int64,1}[[1, 2, 3, 4]], Array{Int64,1}[[1, 2], [1, 3], [2, 4], [3, 4]])
	end
end


@testset "3D" begin
	cube=Lar.cuboid([1,1,1])
	@testset "apply Translation 3D" begin
		@test typeof(Lar.apply(Lar.t(-0.5,-0.5,-0.5),cube))==Tuple{Array{Float64,2},Array{Array{Int64,1},1}}
		@test Lar.apply(Lar.t(-0.5, -0.5, -0.5),cube) ==
		([-0.5 -0.5 -0.5 -0.5 0.5 0.5 0.5 0.5;
		-0.5 -0.5 0.5 0.5 -0.5 -0.5 0.5 0.5; -0.5 0.5 -0.5 0.5 -0.5 0.5 -0.5 0.5],
		Array{Int64,1}[[1, 2, 3, 4, 5, 6, 7, 8]])
	end
	@testset "apply Scaling 3D" begin
		@test typeof(Lar.apply(Lar.s(-0.5,-0.5,-0.5),cube))==
		Tuple{Array{Float64,2},Array{Array{Int64,1},1}}
		@test Lar.apply(Lar.s(-0.5, -0.5, -0.5),cube) ==
		([0.0 0.0 0.0 0.0 -0.5 -0.5 -0.5 -0.5;
		0.0 0.0 -0.5 -0.5 0.0 0.0 -0.5 -0.5; 0.0 -0.5 0.0 -0.5 0.0 -0.5 0.0 -0.5],
		Array{Int64,1}[[1, 2, 3, 4, 5, 6, 7, 8]])
	end
end
