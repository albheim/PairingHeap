module PairingHeaps

    import Base: ==, length, isempty, show, 
                 push!, pop!, eltype, merge!,
                 promote_rule

export PairingHeap,
	   PairingMinHeap,
	   PairingMaxHeap,
	   push!,
	   merge!,
	   pop!,
	   extract_all!,
	   top,
	   isempty

# Pairing heap (non-mutable)

mutable struct PairingHeapNil{T}
end

mutable struct PairingHeapNode{T}
    value::T
    next::Union{PairingHeapNil{T}, PairingHeapNode{T}}
	subheap::Union{PairingHeapNil{T}, PairingHeapNode{T}}
end

const PairingHeapLink{T} = Union{PairingHeapNil{T}, PairingHeapNode{T}}

promote_rule(::Type{PairingHeapNode{T1}}, ::Type{PairingHeapNode{T2}}) where {T1, T2} = promote_type(T1, T2)

#################################################
#
#   core implementation
#
#################################################

pairing_nil(T) = PairingHeapNil{T}()

pairing_isnil(x::PairingHeapNode) = false 
pairing_isnil(x::PairingHeapNil) = true


function _pairing_heap_merge!(comp::Comp, root1::PairingHeapLink{T}, 
							  root2::PairingHeapLink{T}) where {Comp, T}
	if pairing_isnil(root1)
		return root2 elseif pairing_isnil(root2)
		return root1
	elseif compare(comp, root1.value, root2.value)
		root2.next = root1.subheap 
		root1.subheap = root2
		return root1
	else
		root1.next = root2.subheap
		root2.subheap = root1
		return root2
	end
end


function _pairing_heap_merge_pairs!(comp::Comp, subheap::PairingHeapLink{T}) where {Comp, T}
	tmp = subheap
	n = 0
	while !pairing_isnil(tmp)
		tmp = tmp.next
		n += 1
	end
	if n == 0
		return pairing_nil(T)
	elseif n == 1
		return subheap
	else
		n1 = subheap
		n2 = subheap.next
		n3 = subheap.next.next
		n1.next = pairing_nil(T)
		n2.next = pairing_nil(T)
		return _pairing_heap_merge!(comp, _pairing_heap_merge!(comp, n1, n2), 
					 			   	_pairing_heap_merge_pairs!(comp, n3))
	end
end


function _make_pairing_heap(comp::Comp, ty::Type{T}, xs) where {Comp,T}
    n = length(xs)
    root = pairing_nil(T)
    #TODO Is this really how it should be initialized? Seems not optimal...
    for i = 1:n
    	new = PairingHeapNode{T}(xs[i], pairing_nil(T), pairing_nil(T))
    	root = _pairing_heap_merge!(comp, root, new)
    end
    root
end


struct LessThan
end

struct GreaterThan
end

compare(c::LessThan, x, y) = x < y
compare(c::GreaterThan, x, y) = x > y

#################################################
#
#   heap type and constructors
#
#################################################

mutable struct PairingHeap{T,Comp} #<: AbstractHeap{T}
    comparer::Comp
    root::PairingHeapLink{T}
    length::Int

    PairingHeap{T, Comp}() where {T,Comp} = new{T,Comp}(Comp(), pairing_nil(T), 0)

    function PairingHeap{T, Comp}(xs::AbstractVector{T}) where {Comp, T} 
        root = _make_pairing_heap(Comp(), T, xs)
        new{T, Comp}(Comp(), root, length(xs))
    end
end
                            
const PairingMinHeap{T} = PairingHeap{T, LessThan}
const PairingMaxHeap{T} = PairingHeap{T, GreaterThan}
                            
PairingMinHeap(xs::AbstractVector{T}) where T = PairingMinHeap{T}(xs)
PairingMaxHeap(xs::AbstractVector{T}) where T = PairingMaxHeap{T}(xs)

#################################################
#
#   interfaces
#
#################################################

@inline length(h::PairingHeap) = h.length

@inline isempty(h::PairingHeap) = length(h) == 0

"""
    push!(h::PairingHeap, v)

Push the element v on the heap.

Returns the heap.
"""
function push!(h::PairingHeap{T}, v) where {T}
    new = PairingHeapNode{T}(v, pairing_nil(T), pairing_nil(T))
    h.root = _pairing_heap_merge!(h.comparer, h.root, new)
    h.length += 1
    h
end

"""
    merge!(a::PairingHeap, b::PairingHeap)

Returns a heap that is a and b combined. 
"""
function merge!(a::PairingHeap{T, Comp}, b::PairingHeap{T, Comp}) where {Comp, T}
	tmp = PairingHeap{promote_type(T1, T2), Comp}()
	tmp.root = _pairing_heap_merge!(Comp(), a.root, b.root)
	tmp.length = length(a) + length(b)
	tmp
end

"""
    top(h::PairingHeap)

Returns the element at the top of the heap `h`.
"""
@inline top(h::PairingHeap) = h.root.value

"""
    pop!(h::PairingHeap)

Returns the element at the top of the heap `h` and removes it.
"""
function pop!(h::PairingHeap{T}) where T
    # extract root
    root = h.root
	if typeof(root) == PairingHeapNil{T}
		error("Error, trying to pop an empty heap.")
		return 
	end
    v = root.value
	# merge children list pairwise
	h.root = _pairing_heap_merge_pairs!(h.comparer, root.subheap)
	h.length -= 1
    v
end

"""
	extract_all!(h::PairingHeap)

Returns a Vector with all elements popped from the heap.
"""
function extract_all!(h::PairingHeap{T}) where T
    n = length(h)
    r = Vector{T}(undef, n)
    for i = 1 : n
        r[i] = pop!(h)
    end
    r
end

end # module
