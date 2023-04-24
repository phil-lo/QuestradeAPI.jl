using Test
using QuestradeAPI

token = QuestradeAPI.load_current_token()


@testset "Integration" begin
    @test begin
        validate(token)
    end
    @test begin
        accounts = get_accounts()
        print(accounts)
        true
    end
end

