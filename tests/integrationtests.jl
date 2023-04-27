using Test
using QuestradeAPI

token = QuestradeAPI.load_token()
QuestradeAPI.isexpired(token)

@testset "Integration" begin
    @test begin
        @time QuestradeAPI.test(token)
    end
    @test begin
        QuestradeAPI.isexpired(token) == false
    end
    @test begin
        @time accounts = get_accounts()
        true
    end
end

