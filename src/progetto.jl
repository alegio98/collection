using DataStructures
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using ViewerGL
GL = ViewerGL
using BenchmarkTools
#" commenti preliminari '...' dopo alcune funzioni ad esempio hcat stanno a significare un numero variabile di argomenti"

"""
	approxVal(PRECISION)(value)

Transform the float `value` to get a `PRECISION` number of significant digits.
(Trasforma il float "value" per ottenere un numero "PRECISION" di cifre significative.)
"round" = arrotondamento del numero all'intero piu grande o a quello piu piccolo
"digits" = specifica il numero di cirfre a cui è arrotondato il numero

"""
function approxVal(PRECISION)
	function approxVal0(value)
		out = round(value, digits=PRECISION)
		if out == -0.0
			out = 0.0
		end
		return out
	end
	return approxVal0
end




"""
	W,CW = simplifyCells(V,CV)

Trova e rimuovi i vertici duplicati e le celle errate.
Alcuni vertici possono apparire due o più volte, a causa di errori numerici
su coordinate mappate. I vertici vicini vengono identificati, secondo il numero dato da PRECISION
(numero di cifre significative).

"""
function simplifyCells(V,CV)
	PRECISION = 5
	vertDict = DefaultDict{Array{Float64,1}, Int64}(0)
	index = 0
	W = Array{Float64,1}[]
	FW = Array{Int64,1}[]

	for incell in CV
		outcell = Int64[]
		for v in incell
			vert = V[:,v]    #"mette in colonna gli elementi in posizione v nella matrice vert : guarda esempio in https://docs.julialang.org/en/v1/manual/arrays/#man-supported-index-types "
			key = map(approxVal(PRECISION), vert)
			if vertDict[key]==0
				index += 1
				vertDict[key] = index
				push!(outcell, index)
				push!(W,key)
			else
				push!(outcell, vertDict[key])
			end
		end
		append!(FW, [[Set(outcell)...]])
	end
	return hcat(W...),FW
end



"""
	circle(radius=1.; angle=2*pi)(shape=36)

Calcola un'approssimazione della curva di circonferenza in 2D, centrata sull'origine.
Con i valori predefiniti, ad esempio "circle()()", restituisce l'intera circonferenza del raggio unitario,
approssimata con un numero "shape = 36" di 1 celle. Una sua prova è nei TEST

# Example
```julia
julia> W,CW = Lar.circle()();

julia> GL.VIEW([
	GL.GLLines(W, CW, GL.COLORS[12]),
	GL.GLFrame
]);
```
"""
function circle(radius=1., angle=2*pi)
    function circle0(shape=[36])
		V = [zero(eltype{Int64,1})]
	 	EV = [zero(eltype{Int64,1})] 
        V, EV = cuboidGrid(shape)
        V = (angle/shape[1])*V
        V = hcat(map(u->[radius*cos(u); radius*sin(u)], V)...)
        W, EW = simplifyCells(V, EV)
        return W, EW
    end
    return circle0
end

#ESEMPIO FUNZIONE MULTITASK
#function forCircle(radius)
#V = hcat(map(u->[radius*cos(u); radius*sin(u)], V)...)

#function circle(radius=1., angle=2*pi)
 #   function circle0(shape=[36])
 #       V, EV = cuboidGrid(shape)
 #       V = (angle/shape[1])*V
 #       V = forCircle(radius) <--------
 #       W, EW = simplifyCells(V, EV)
 #       return W, EW
#    end
#    return circle0
#end


"""
	helix(radius=1., pitch=1., nturns=2)(shape=36*nturns)

Calcola la curva elix approssimativa nello spazio tridimensionale, con base sul piano `` z = 0 '' e centrata attorno all'asse `` z ''.
Il "passo" (pitch) di un'elica è l'altezza di un "giro" (turn) completo dell'elica, misurato parallelamente all'asse dell'elica.

# Example
```julia
julia> V, CV = Lar.helix(.1, .1, 10)()
([0.1 0.0984808 … 0.0984808 0.1; 0.0 0.0173648 … -0.0173648 0.0; 0.0 0.0027778 … 0.997222 1.0], Array{Int64,1}[[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [8, 9], [9, 10], [10, 11]  …  [351, 352], [352, 353], [353, 354], [354, 355], [355, 356], [356, 357], [357, 358], [358, 359], [359, 360], [360, 361]])

julia> GL.VIEW([
	GL.GLLines(V, CV, GL.COLORS[12]),
	GL.GLFrame
]);
```
"""
function helix(radius=1., pitch=1., nturns=2)
    function helix0(shape=36*nturns)
        angle = nturns*2*pi
        V, EV = cuboidGrid([shape])
        V = (angle/shape)*V
        V = hcat(map(u->[radius*cos(u);radius*sin(u);(pitch/(2*pi))*u], V)...)
        W, EW = simplifyCells(V, EV)
        return W, EW
    end
    return helix0
end


"""
	disk(radius=1., angle=2*pi)(shape=[36, 1])

Calcola il complesso cellulare approssimando un settore circolare del disco 2D centrato sull'origine.
In geometria, un disco è la regione in un piano delimitato da un cerchio. L'array `shape` fornisce il numero di 2 celle approssimative.

# Example
```julia
julia> GL.VIEW([
	GL.GLGrid( Lar.disk()()..., GL.COLORS[1],1 ),
	GL.GLFrame
]);
```
"""
function disk(radius=1., angle=2*pi)
    function disk0(shape=[36, 2])
        V, FV = simplexGrid(shape)
        V = [angle/shape[1] 0;0 radius/shape[2]]*V
        W = [V[:, k] for k=1:size(V, 2)]
        V = hcat(map(p->let(u, v)=p;[v*cos(u);v*sin(u)] end, W)...)
        W, FW = simplifyCells(V, FV)
        FW = [cell for cell in FW if length(cell)==3]
		#EW = Lar.simplexFacets(FW)
        return W, FW #, EW
    end
    return disk0
end


"""
	helicoid(R=1., r=0.5, pitch=1., nturns=2)(shape=[36*nturns, 2])

Calcola un'approssimazione della superficie elicoidale in 3D, con base sul piano `` z = 0 '' e centrata attorno all'asse `` z ''.

# Example
```julia
julia> GL.VIEW([
	GL.GLGrid( Lar.helicoid()()..., GL.COLORS[1],1 ),
	GL.GLFrame
]);
```
"""
function helicoid(R=1., r=0.5, pitch=1., nturns=2)
    function helicoid0(shape=[36*nturns, 2])
        angle = nturns*2*pi
        V, CV = simplexGrid(shape)
        V = [angle/shape[1] 0;0 (R-r)/shape[2]]*V
        V = broadcast(+, V, [0, r])
        W = [V[:, k] for k=1:size(V, 2)]
        V = hcat(map(p->let(u, v)=p;[v*cos(u);v*sin(u);
        	(pitch/(2*pi))*u] end, W)...)
        return V, CV
    end
    return helicoid0
end


"""
	ring(r=1., R=2., angle=2*pi)(shape=[36, 1])

	           cellular 2-complex
	Calcola il 2-complesso cellulare approssimando un settore (possibilmente pieno) di un disco non contrattabile. "R" e "r" sono rispettivamente il raggio esterno e quello interno.

# Example
```julia
julia> GL.VIEW([
	GL.GLGrid( Lar.ring()()..., GL.COLORS[1],1 ),
	GL.GLFrame
]);
```
"""
function ring(r=1., R=2., angle=2*pi)
    function ring0(shape=[36, 1])
		V, CV = cuboidGrid(shape)
		CV = [[[u,v,w],[w,v,t]] for (u,v,w,t) in CV]
		CV = reduce(append!,CV)
        V = [angle/shape[1] 0;0 (R-r)/shape[2]]*V
        V = broadcast(+, V, [0, r])
        W = [V[:, k] for k=1:size(V, 2)]
        V = hcat(map(p->let(u, v)=p;[v*cos(u);v*sin(u)] end, W)...)
        W, CW = simplifyCells(V, CV)
		CW = [cell for cell in CW if length(cell)==3]
		return W,CW
    end
    return ring0
end


"""
	cylinder(radius=.5, height=2., angle=2*pi)(shape=[36, 1])


	Calcola un 2-complesso cellulare, approssimazione di una superficie cilindrica circolare destra in 3D. La superficie aperta ha base sul piano `` z = 0 '' ed è centrata attorno all'asse `` z ''.

# Example
```julia
julia> GL.VIEW([
	GL.GLGrid( Lar.cylinder()()..., GL.COLORS[1],1 ),
	GL.GLFrame
]);
```
"""
function cylinder(radius=.5, height=2., angle=2*pi)
    function cylinder0(shape=[36, 1])
        V, CV = Lar.cuboidGrid(shape)
		CV = [[[u,v,w],[w,v,t]] for (u,v,w,t) in CV]
		CV = reduce(append!,CV)
        V = [angle/shape[1] 0.0 ; 0.0 1.0/shape[2]]*V
        W = [V[:, k] for k=1:size(V, 2)]
        V = hcat(map(p->let(u, v)=p;[radius*cos(u);radius*sin(u);
        	height*v] end, W)...)
        W, CW = simplifyCells(V, CV)
        return W, CW
    end
    return cylinder0
end



"""
	sphere(radius=1., angle1=pi, angle2=2*pi)(shape=[18, 36])

Calcola un'approssimazione cellulare bidimensionale della superficie chiusa bidimensionale, incorporata in uno spazio euclideo tridimensionale. Le coordinate geografiche sono utente per calcolare le 0 celle del complesso.

# Example
```julia
julia> GL.VIEW([
	GL.GLGrid( Lar.sphere()()..., GL.COLORS[1],0.75 ),
	GL.GLFrame
]);
```
"""
@enum surface triangled=1 single=2
function sphere(radius=1., angle1=pi, angle2=2*pi, surface=triangled)
    function sphere0(shape=[18, 36])
        V, CV = simplexGrid(shape)
        V = [angle1/shape[1] 0;0 angle2/shape[2]]*V
        V = broadcast(+, V, [-angle1/2, -angle2/2])
        W = [V[:, k] for k=1:size(V, 2)]
        V = hcat(map(p->let(u, v)=p;[radius*cos(u)*cos(v);
        	radius*cos(u)*sin(v);radius*sin(u)]end, W)...)
        W, CW = simplifyCells(V, CV)
        CW = [triangle for triangle in CW if length(triangle)==3]
        if Int(surface)==1
        	return W, CW
        elseif Int(surface)==2
        	return W,[collect(1:size(W, 2))]
        end
    end
    return sphere0
end



"""
	toroidal(r=1., R=2., angle1=2*pi, angle2=2*pi)(shape=[24, 36])

	Calcola un 2-complesso cellulare, approssimazione della superficie bidimensionale, incorporato in uno spazio euclideo tridimensionale.
	Toroidale è una superficie chiusa di genere uno, e quindi dotata di un unico "foro".
	Può essere costruito da un rettangolo incollando insieme entrambe le coppie di bordi opposti senza torsioni.

# Example
```julia
julia> GL.VIEW([
	GL.GLGrid( Lar.toroidal()()..., GL.COLORS[1],0.75 ),
	GL.GLFrame
]);
```
"""
function toroidal(r=1., R=2., angle1=2*pi, angle2=2*pi)
    function toroidal0(shape=[24, 36])
        V, CV = simplexGrid(shape)
        V = [angle1/(shape[1]) 0;0 angle2/(shape[2])]*V
        W = [V[:, k] for k=1:size(V, 2)]
        V = hcat(map(p->let(u, v)=p;[(R+r*cos(u))*cos(v);
        	(R+r*cos(u))*sin(v);-r*sin(u)]end, W)...)
        W, CW = simplifyCells(V, CV)
        return W, CW
    end
    return toroidal0
end



"""
	crown(r=1., R=2., angle=2*pi)(shape=[24, 36])


	Calcola un 2-complesso cellulare, approssimazione di una superficie aperta bidimensionale, incorporata in uno spazio euclideo tridimensionale.
	Questa superficie aperta viene generata come un "mezzo toro", fornendo solo il guscio esterno.

# Example
```julia
julia> GL.VIEW([
	GL.GLGrid( Lar.crown()()..., GL.COLORS[1],0.75 ),
	GL.GLFrame
]);
```
"""
function crown(r=1., R=2., angle=2*pi)
    function crown0(shape=[12, 36])
        V, CV = simplexGrid(shape)
        V = [pi/shape[1] 0;0 angle/shape[2]]*V
        V = broadcast(+, V, [-pi/2, 0])
        W = [V[:, k] for k=1:size(V, 2)]
        V = hcat(map(p->let(u, v)=p;[(R+r*cos(u))*cos(v);
       	(R+r*cos(u))*sin(v);-r*sin(u)]end, W)...)
        W, CW = simplifyCells(V, CV)
        return W, CW
    end
    return crown0
end



"""
	cuboid(maxpoint::Array, full=false, minpoint::Array=zeros(length(maxpoint)))


	Restituisce un cubo dimensionale "d", dove "d" è la lunghezza comune degli array "minpoint" e
	"maxpoint".
	Se "flag = true" vengono generate le celle di tutte le dimensioni (comprese tra 1 e "d").

```julia
julia> cuboid([-0.5, -0.5])
([0.0 0.0 -0.5 -0.5; 0.0 -0.5 0.0 -0.5], Array{Int64,1}[[1, 2, 3, 4]])

julia> cuboid([-0.5, -0.5, 0], true)
([0.0 0.0 … -0.5 -0.5; 0.0 0.0 … -0.5 -0.5; 0.0 0.0 … 0.0 0.0],
Array{Array{Int64,1},1}[Array{Int64,1}[[1], [2], [3], [4], [5], [6], [7], [8]],
Array{Int64,1}[[1, 2], [3, 4], [5, 6], [7, 8], [1, 3], [2, 4], [5, 7], [6, 8], [1, 5], [2,
6], [3, 7], [4, 8]], Array{Int64,1}[[1, 2, 3, 4], [5, 6, 7, 8], [1, 2, 5, 6], [3, 4, 7,
8], [1, 3, 5, 7], [2, 4, 6, 8]], Array{Int64,1}[[1, 2, 3, 4, 5, 6, 7, 8]]])

julia> V, (VV, EV, FV, CV) = Lar.cuboid([1,1,1], true);

julia> assembly = Lar.Struct([ (V, CV), Lar.t(1.5,0,0), (V, CV) ])

julia> GL.VIEW([
	GL.GLPol( Lar.struct2lar(assembly)..., GL.COLORS[1],0.75 ),
	GL.GLFrame ]);
```
"""
function cuboid(maxpoint::Array, full=false,
				minpoint::Array=zeros(length(maxpoint)))
	@assert( length(minpoint) == length(maxpoint) )
	dim = length(minpoint)
	shape = ones(Int, dim)
	cell = cuboidGrid(shape, full)
	size = maxpoint - minpoint
	out = apply(t(minpoint...) * s(size...), cell)
end



"""
	ball(radius=1, angle1=pi, angle2=2*pi)(shape=[18, 36,4])

	Genera una scomposizione cellulare di una *solida 3-sfera * in `` R ^ 3 ''.
	La variabile "shape" fornisce la scomposizione del dominio. Le celle vuote vengono rimosse dopo la mappatura delle coordinate * Cartesiane -> Polare *.
# Example
```julia
julia> GL.VIEW([
	GL.GLPol( Lar.ball()()..., GL.COLORS[1],0.5 ),
	GL.GLFrame ]);
```
"""
function ball(radius=1, angle1=pi, angle2=2*pi)
    function ball0(shape=[18, 36, 4])
        V, CV = cuboidGrid(shape)
        V = [angle1/shape[1] 0 0; 0 angle2/shape[2] 0; 0 0 radius/shape[3]]*V
        V = broadcast(+, V, [-(angle1)/2, -(angle2)/2, 0])
        W = [V[:, k] for k=1:size(V, 2)]
        V = hcat(map(p->let
        (u, v, w)=p; [w*cos(u)*cos(v); w*cos(u)*sin(v); w*sin(u)] end, W)...)
        W, CW = simplifyCells(V, CV)
        return W, CW
    end
    return ball0
end



"""
	rod(radius=1, height=3, angle=2*pi)(shape=[36, 1])

Calcola un 3-complesso cellulare con una * singola * 3 cella partendo da una superficie ciclindrica generata con gli stessi parametri.

# Example
```julia
julia> rod()()[1]
# output
3×74 Array{Float64, 2}:
 -0.34202   0.984808   1.0          1.0  …   0.984808  -0.866025  -1.0           0.766044
  0.939693  0.173648  -2.44929e-16  0.0     -0.173648  -0.5        1.22465e-16  -0.642788
  3.0       3.0        0.0          0.0      0.0        3.0        3.0           0.0

julia> rod()()[2]
# output
1-element Array{Array{Int64, 1}, 1}:
 [0, 1, 2, 3, 4, 5, 6, 7, 8, 9  …  64, 65, 66, 67, 68, 69, 70, 71, 72, 73]

julia> GL.VIEW([
 	GL.GLPol( Lar.rod()()..., GL.COLORS[1],0.5 ),
 	GL.GLFrame ]);
```
"""
function rod(radius=1., height=3., angle=2*pi)
    function rod0(shape=[36, 1])
        V, CV = cylinder(radius, height, angle)(shape)
        return V, [collect(1:size(V, 2))]
    end
    return rod0
end



"""
	hollowCyl(r=1., R=2., height=6., angle=2*pi)(shape=[36, 1, 1])


	Calcola il 3-complesso cellulare approssimando un cilindro solido con un
	foro assiale interno. Il modello è mesh con 3 celle cubiche.

# Example
```julia
julia> GL.VIEW([
 	GL.GLPol( Lar.hollowCyl()()..., GL.COLORS[1],0.5 ),
 	GL.GLFrame ]);
```
"""
function hollowCyl(r=1., R=2., height=6., angle=2*pi)
    function hollowCyl0(shape=[36, 1, 1])
        V, CV = cuboidGrid(shape)
        V = [angle/shape[1] 0 0;0 (R-r)/shape[2] 0;0 0 height/shape[3]]*V
        V = broadcast(+, V, [0, r, 0])
        W = [V[:, k] for k=1:size(V, 2)]
        V = hcat(map(p->let(u, v, z)=p;[v*cos(u);v*sin(u);z] end, W)...)
        W, CW = simplifyCells(V, CV)
        return W, CW
    end
    return hollowCyl0
end



"""
	hollowBall(r=1., R=2., angle1=pi, angle2=2*pi)(shape=[36, 1, 1])


	Calcola il 3-complesso cellulare che si avvicina a una 3-sfera. Il modello è mesh con 3 celle cubiche, dove la mesh ha dimensione di decomposizione predefinita `[24, 36, 8]`.

# Example
```julia
julia> V, CV = Lar.hollowBall(1, 2, pi/2, pi/2)([6, 12, 4]);

julia> GL.VIEW([
 	GL.GLPol( V, CV, GL.COLORS[1],0.5 ),
 	GL.GLFrame ]);
...
```

"""
function hollowBall(r=1., R=1., angle1=pi, angle2=2*pi)
    function hollowBall0(shape=[24, 36, 3])
        V, CV = cuboidGrid(shape)
        V = [angle1/shape[1] 0 0; 0 angle2/shape[2] 0; 0 0 (R-r)/shape[3]]*V
        V = broadcast(+, V, [-(angle1)/2, -(angle2)/2, r])
        W = [V[:, k] for k=1:size(V, 2)]
        V = hcat(map(p->let
        (u, v, w)=p; [w*cos(u)*cos(v); w*cos(u)*sin(v); w*sin(u)] end, W)...)
        W, CW = simplifyCells(V, CV)
        return W, CW
    end
    return hollowBall0
end



"""
	torus(r=1., R=2., h=.5, angle1=2*pi, angle2=2*pi)(shape=[24, 36, 4])

Calcola il complesso 3 cellulare approssimando il toro solido in 3D. Il modello è mesh con 3 celle cubiche, dove la mesh ha dimensione di decomposizione predefinita `[24, 36, 4]`. Vedi anche: [`toroidal`] (@ toroidal). "h" è il raggio del foro circolare all'interno del solido.
# Example
```julia
julia> GL.VIEW([
 	GL.GLPol( Lar.torus(1., 2., .5, pi, pi)()..., GL.COLORS[1],0.5 ),
 	GL.GLFrame ]);
```
"""
function torus(r=1., R=2., h=.5, angle1=2*pi, angle2=2*pi)
    function torus0(shape=[24, 36, 4])
        V, CV = cuboidGrid(shape)
        V = [angle1/shape[1] 0 0;0 angle2/shape[2] 0;0 0 r/shape[3]]*V
        V = broadcast(+, V, [0, 0, h])
        W = [V[:, k] for k=1:size(V, 2)]
        V = hcat(map(p->let(u, v, z)=p;[(R+z*cos(u))*cos(v);(R+z*cos(u))*sin(v);
        	-z*sin(u)] end, W)...)
        W, CW = simplifyCells(V, CV)
        return W, CW
    end
    return torus0
end



#"""
#	pizza(r=.1, R=1., angle=pi)(shape=[24, 36])
#
#Compute a cellular 3-complex with a single convex 3-cell.
#
## Example
#```julia
#julia> model = pizza(r=.1, R=1., angle=pi)([12,18])
#
#julia> model[1]
#3×249 Array{Float64,2}:
# 0.799215  0.997552   0.871665   0.573303  …   0.8463      0.964127  0.985637    0.0   0.0
# 0.670621  0.175895   0.573303   0.871665      0.55662     0.415884  0.2336      0.0   0.0
# 0.025     0.0482963  0.025     -0.025        -0.0482963  -0.0       0.0482963  -0.05  0.05
#
#julia> model[2]
#1-element Array{Array{Int64,1},1}:
# [1, 2, 3, 4, 5, 6, 7, 8, 9, 10  …  240, 241, 242, 243, 244, 245, 246, 247, 248, 249]
#
#julia> using Plasm
#
#julia> Plasm.view(model)
#```
#"""
#function pizza(r=.1, R=1., angle=pi)
#    function pizza0(shape=[24, 36])
#        V, CV = crown(r, R, angle)(shape)
#        W = [Any[V[h, k] for h=1:size(V, 1)] for k=1:size(V, 2)]
#        X = hcat(collect(Set(W))...)
#        V = hcat(X, [0 0;0 0;-r r])
#        return V, [collect(1:size(V, 2))]
#    end
#    return pizza0
#end
