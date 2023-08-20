using Test
using QuestradeAPI
using Dates

@testset "Unit Tests" begin
    @test begin # New QuestradeToken
        token = QuestradeAPI.QuestradeToken("refresh", "refresh_token", "refresh", 0, "New", Dates.format(now(), "yyyy-mm-dd HH:MM:SS"), "TestToken", pwd())
        @assert token.expires_in == 0 "Empty token expires_in = 0"
        @assert token.refresh_token == "refresh_token" "New token refresh_token $(token.refresh_token) is not what was given"
        true
    end

    @test begin # Save and load QuestradeToken
        token = QuestradeAPI.QuestradeToken("refresh", "refresh_token", "refresh", 0, "New1", Dates.format(now(), "yyyy-mm-dd HH:MM:SS"), "TestToken", pwd())
        QuestradeAPI.save(token)
        token.refresh_token == QuestradeAPI.QuestradeToken("TestToken", pwd()).refresh_token
    end

    @test begin # Token should be expired
        token = QuestradeAPI.QuestradeToken("TestToken", pwd())
        QuestradeAPI.isexpired(token)
    end

    @test begin # Try loading QuestradeToken should throw error
        token = QuestradeAPI.QuestradeToken("TestToken", pwd())
        QuestradeAPI.delete!(token)
        try
            token = QuestradeAPI.QuestradeToken("TestToken", pwd())
        catch err
            if err isa QuestradeAPI.MissingQuestradeToken
                true
            end
        end
    end

    @test begin
        token = QuestradeAPI.QuestradeToken("refresh", "refresh_token", "refresh", 0, "New1", Dates.format(now(), "yyyy-mm-dd HH:MM:SS"), "TestToken", pwd())
        QuestradeAPI.save(token)

        x = QuestradeToken(token.name, token.directory)
        x.name == token.name

        QuestradeAPI.delete!(token)
        true
    end
end