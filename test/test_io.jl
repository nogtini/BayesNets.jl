let
	# read a sample .XDSL BN file
	# NOTE: these are generated by Genie / Smile
	#       See Smile.jl
	# Success -> Forecast

    bn = readxdsl(joinpath(dirname(pathof(BayesNets)), "..", "test","sample_bn.xdsl"))

	@test sort!(names(bn)) == [:Forecast, :Success]
	@test isempty(parents(bn, :Success))
	@test sort!(parents(bn, :Forecast)) == [:Success]

	@test isapprox(pdf(bn, :Success=>1, :Forecast=>1), 0.2*0.4)
	@test isapprox(pdf(bn, :Success=>1, :Forecast=>2), 0.2*0.4)
	@test isapprox(pdf(bn, :Success=>1, :Forecast=>3), 0.2*0.2)
	@test isapprox(pdf(bn, :Success=>2, :Forecast=>1), 0.8*0.1)
	@test isapprox(pdf(bn, :Success=>2, :Forecast=>2), 0.8*0.3)
	@test isapprox(pdf(bn, :Success=>2, :Forecast=>3), 0.8*0.6)

    # test output to text
    push!(bn, DiscreteCPD(:Test, [:Forecast], [3], [Categorical([1.0, 0.0]),
                                                    Categorical([0.0, 1.0]),
                                                    Categorical([0.1234569, 1-0.1234569])]))

    filename = tempname()
    open(filename, "w") do io
        write(io, MIME"text/plain"(), bn)
    end

    lines = readlines(filename)
    @test strip(lines[1]) == "Success Forecast Test"
    @test strip(lines[2]) == "010"
    @test strip(lines[3]) == "001"
    @test strip(lines[4]) == "000"
    @test strip(lines[5]) == "2 3 2"
    @test strip(lines[6]) == "0.2 0.4 0.4 0.1 0.3 1 0 0.1234569"
    @test length(lines) == 6

    bn2 = open(filename, "r") do io
        read(io, MIME"text/plain"(), DiscreteBayesNet)
    end
    rm(filename)

    @test isapprox(pdf(bn2, :Success=>1, :Forecast=>1, :Test=>1), 0.2*0.4*1.0)
    @test isapprox(pdf(bn2, :Success=>1, :Forecast=>1, :Test=>2), 0.2*0.4*0.0)
    @test isapprox(pdf(bn2, :Success=>1, :Forecast=>2, :Test=>1), 0.2*0.4*0.0)
    @test isapprox(pdf(bn2, :Success=>1, :Forecast=>2, :Test=>2), 0.2*0.4*1.0)
    @test isapprox(pdf(bn2, :Success=>1, :Forecast=>3, :Test=>1), 0.2*0.2*0.1234569)
    @test isapprox(pdf(bn2, :Success=>1, :Forecast=>3, :Test=>2), 0.2*0.2*(1-0.1234569))
    @test isapprox(pdf(bn2, :Success=>2, :Forecast=>1, :Test=>1), 0.8*0.1*1.0)
    @test isapprox(pdf(bn2, :Success=>2, :Forecast=>1, :Test=>2), 0.8*0.1*0.0)
    @test isapprox(pdf(bn2, :Success=>2, :Forecast=>2, :Test=>1), 0.8*0.3*0.0)
    @test isapprox(pdf(bn2, :Success=>2, :Forecast=>2, :Test=>2), 0.8*0.3*1.0)
    @test isapprox(pdf(bn2, :Success=>2, :Forecast=>3, :Test=>1), 0.8*0.6*0.1234569)
    @test isapprox(pdf(bn2, :Success=>2, :Forecast=>3, :Test=>2), 0.8*0.6*(1-0.1234569))
end
