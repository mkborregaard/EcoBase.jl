

# Functions
occurrences(com::AbstractThings) = error("function not defined for this type") #has to be implemented with the concrete type
thingnames(com::AbstractThings) = error("function not defined for this type")
view(com::AbstractThings) = error("function not defined for this type")
places(asm::AbstractAssemblage) = error("function not defined for this type")
things(asm::AbstractAssemblage) = error("function not defined for this type")
nplaces(asm::AbstractPlaces) = error("function not defined for this type")
placenames(com::AbstractPlaces) = error("function not defined for this type")

nzrows(a::AbstractMatrix) = find(sum(a .> 0, 2)> 0)
nzcols(a::AbstractMatrix) = find(sum(a .> 0, 1)> 0)

occurring(com::AbstractThings) = nzrows(occurrences(com))
occupied(com::AbstractThings) = nzcols(occurrences(com))
occupied(com::AbstractOnceThings, idx) = findn(occurrences(com)[idx,:])
occurring(com::AbstractOnceThings, idx) = findn(occurrences(com)[:,idx])

noccurring(x) = length(occurring(x))
noccupied(x) = length(occupied(x))
noccurring(x, idx) = length(occurring(x, idx))
noccupied(x, idx) = length(occupied(x, idx))

nthings(com::AbstractThings) = size(occurrences(com), 1)
nplaces(com::AbstractThings) = size(occurrences(com), 2)
ntimes(com::AbstractTimeThings) = size(occurrences(com), 3)

thingoccurrences(com::AbstractOnceThings, idx) = view(occurrences(com), idx, :)
placeoccurrences(com::AbstractOnceThings, idx) = view(occurrences(com), :, idx) # make certain that the view implementation also takes thing or place names


richness(com::AbstractThings{Bool}) = vec(sum(occurrences(com), 1))
richness(com::AbstractThings{<:Real}) = vec(mapslices(nnz, occurrences(com), 1))

occupancy(com::AbstractThings{Bool}) = vec(sum(occurrences(com), 2))
occupancy(com::AbstractThings{<:Real}) = vec(mapslices(nnz, occurrences(com), 2))

records(com::AbstractComMatrix) = nnz(occurrences(com))

cooccurring(com::AbstractThings, inds...) = cooccurring(com, [inds...])
function cooccurring(com::AbstractThings, inds::AbstractVector)
    sub = view(com, species = inds)
    richness(sub) .== nthings(sub)
end

function createsummaryline(vec::AbstractVector{T}) where T<:AbstractString
    linefunc(vec) = mapreduce(x->x*", ", *, vec[1:(end-1)])*vec[end]
    length(vec) == 1 && return vec[1]
    length(vec) < 6 && return linefunc(vec)
    linefunc(vec[1:3])*"..."*linefunc(vec[(end-1):end])
end

function show(io::IO, com::T) where T <: AbstractOnceThings
    sp = createsummaryline(thingnames(com))
    si = createsummaryline(placenames(com))
    println(io, "$T with $(nthings(com)) things in $(nplaces(com)) places\n\nThing names:\n$(sp)\n\nPlace names:\n$(si)")
end

function show(io::IO, com::T) where T <:AbstractAssemblage
    sp = createsummaryline(thingnames(com))
    si = createsummaryline(placenames(com))
    println(io, "$T with $(nthings(com)) things in $(nplaces(com)) places\n\nThing names:\n$(sp)\n\nPlace names:\n$(si)")
end


macro forward_func(ex, fs)
    T, field = ex.args[1], ex.args[2].args[1]
    T = esc(T)
    fs = isexpr(fs, :tuple) ? map(esc, fs.args) : [esc(fs)]
    :($([:($f(x::$T, args...) = (Base.@_inline_meta; $f($(field)(x), args...)))
        for f in fs]...);
    nothing)
end

@forward_func AbstractAssemblage.places nplaces, placenames
@forward_func AbstractAssemblage.things nthings, occupancy, richness, records, occurring, occupied, thingnames

TODO:
# accessing cache


xmin(g::AbstractGrid) = error("function not defined for this type")
ymin(g::AbstractGrid) = error("function not defined for this type")
xcellsize(g::AbstractGrid) = error("function not defined for this type")
ycellsize(g::AbstractGrid) = error("function not defined for this type")
xcells(g::AbstractGrid) = error("function not defined for this type")
ycells(g::AbstractGrid) = error("function not defined for this type")
cellsize(g::AbstractGrid) = xcellsize(g), ycellsize(g)
cells(g::AbstractGrid) = xcells(g), ycells(g)
xrange(g::AbstractGrid) = xmin(g):xcellsize(g):xmax(g) #includes intermediary points
yrange(g::AbstractGrid) = ymin(g):ycellsize(g):ymax(g)
xmax(g::AbstractGrid) = xmin(g) + xcellsize(g) * (xcells(g)-1)
ymax(g::AbstractGrid) = ymin(g) + ycellsize(g) * (ycells(g)-1)


indices(grd::AbstractGrid, idx) = error("function not defined for this type") #Implement this in SpatialEcology!
coordinates(grd::AbstractGrid) = error("function not defined for this type")
