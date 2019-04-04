using PairingHeaps
using Test

@test [] == detect_ambiguities(Base, Core, PairingHeaps)

@testset "PairingHeap" begin

    @testset "make heap" begin
        vs = [4, 1, 3, 2, 16, 9, 10, 14, 8, 7]

        @testset "make min heap" begin
            h = PairingMinHeap(vs)

            @test length(h) == 10
            @test !isempty(h)
            @test top(h) == 1
        end

        @testset "make max heap" begin
            h = PairingMaxHeap(vs)

            @test length(h) == 10
            @test !isempty(h)
            @test top(h) == 16
        end

        @testset "push!" begin
            @testset "push! hmin" begin
                hmin = PairingMinHeap{Int}()
                @test length(hmin) == 0
                @test isempty(hmin)

                ss = Any[4, 1, 1, 1, 1, 1, 1, 1, 1, 1]

                for i = 1 : length(vs)
                    push!(hmin, vs[i])
                    @test length(hmin) == i
                    @test !isempty(hmin)
                    @test isequal(top(hmin), ss[i])
                end

                @testset "pop! hmin" begin
                    @test isequal(extract_all!(hmin), [1, 2, 3, 4, 7, 8, 9, 10, 14, 16])
                    @test isempty(hmin)
                end
                
            end

            @testset "push! hmax" begin
                hmax = PairingMaxHeap{Int}()
                @test length(hmax) == 0
                @test isempty(hmax)

                ss = Any[4, 4, 4, 4, 16, 16, 16, 16, 16, 16]

                for i = 1 : length(vs)
                    push!(hmax, vs[i])
                    @test length(hmax) == i
                    @test !isempty(hmax)
                    @test isequal(top(hmax), ss[i])
                end

                @testset "pop! hmax" begin
                    @test isequal(extract_all!(hmax), [16, 14, 10, 9, 8, 7, 4, 3, 2, 1])
                    @test isempty(hmax)
                end                
            end
        end        
        
    end

    @testset "hybrid push! and pop!" begin
        h = PairingMinHeap{Int}()

        @testset "push1" begin
            push!(h, 5)
            push!(h, 10)
            @test top(h) == 5
        end

        @testset "pop1" begin
            @test pop!(h) == 5
            @test top(h) == 10
        end

        @testset "push2" begin
            push!(h, 7)
            push!(h, 2)
            @test top(h) == 2
        end

        @testset "pop2" begin
            @test pop!(h) == 2
            @test top(h) == 7
        end
    end

    @testset "push! type conversion" begin # issue 399
        h = PairingMinHeap{Float64}()
        push!(h, 3.0)
        push!(h, 5)
        push!(h, Rational(4, 8))
        push!(h, Complex(10.1, 0.0))

        @test isequal(extract_all!(h), [0.5, 3.0, 5.0, 10.1])
    end

end # @testset PairingHeap

