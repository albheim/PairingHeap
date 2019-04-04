# PairingHeap.jl

[![Build Status](https://travis-ci.org/JuliaControl/ControlSystems.jl.svg?branch=master)](https://travis-ci.org/albheim/PairingHeaps.jl)
[![codecov.io Code Coverage](https://img.shields.io/codecov/c/github/dwyl/hapi-auth-jwt2.svg?maxAge=2592000)](https://codecov.io/gh/albheim/PairingHeaps.jl?branch=master)

Implementing a Pairing Heap, see https://en.wikipedia.org/wiki/Pairing_heap, according to the interface defined in http://juliacollections.github.io/DataStructures.jl/latest/heaps.html

# Installation
```julia
Pkg.add("https://github.com/albheim/PairingHeaps.jl")
```

# Usage
```julia
using PairingHeaps
a = PairingMinHeap([5, 2, 6, 7])
push!(a, 1)
b = pop!(a)           # b = 1
top(a)                # => 2
```

It seems to be slower than BinaryHeap from DataStructures in most applications. 
It should have the same amortized complexity for pop! and should be constant for push! and merge!. 
