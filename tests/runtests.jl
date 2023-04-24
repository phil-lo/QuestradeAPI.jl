using Test
using QuestradeAPI

@testset "Token" begin
    @test begin # New QuestradeToken
        token = QuestradeToken("refresh")
        @assert token.expires_in == 0 "Empty token expires_in = 0"
        @assert token.refresh_token == "refresh" "New token refresh_token is not what was given"
        @assert QuestradeAPI.isnew(token) "Token is not new"
        true
    end

    @test begin # Save and load QuestradeToken
        token = QuestradeToken("TestToken1")
        QuestradeAPI.save(token)
        token == QuestradeAPI.load_current_token()
    end

    @test begin # Try loading QuestradeToken
        QuestradeAPI.delete_current_token()
        token = QuestradeAPI.load_current_token()
        token === nothing
    end

    @test begin # Try deleting QuestradeToken
        QuestradeAPI.delete_current_token()
        true
    end
end