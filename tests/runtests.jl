using Test
using QuestradeAPI
using Dates

@testset "Token" begin
    @test begin # New QuestradeToken
        token = QuestradeAPI.QuestradeToken("refresh", "refresh_token", "refresh", 0, "New", Dates.format(now(), "yyyy-mm-dd HH:MM:SS"))
        @assert token.expires_in == 0 "Empty token expires_in = 0"
        @assert token.refresh_token == "refresh_token" "New token refresh_token $(token.refresh_token) is not what was given"
        true
    end

    @test begin # Save and load QuestradeToken
        token = QuestradeAPI.QuestradeToken("refresh", "refresh_token", "refresh", 0, "New1", Dates.format(now(), "yyyy-mm-dd HH:MM:SS"))
        @time QuestradeAPI.save(token, name="TestToken")
        @time token == QuestradeAPI.load_token(name="TestToken")
    end

    @test begin # Token should be expired
        token = QuestradeAPI.load_token(name="TestToken")
        QuestradeAPI.isexpired(token)
    end

    @test begin # Try loading QuestradeToken should throw error
        QuestradeAPI._delete_token(name="TestToken")
        try
            token = QuestradeAPI.load_token(name="TestToken")
        catch err
            if err isa QuestradeAPI.MissingQuestradeToken
                true
            end
        end
    end

    @test begin # Try deleting QuestradeToken should send message and no error
        QuestradeAPI._delete_token(name="TestToken")
        true
    end
end