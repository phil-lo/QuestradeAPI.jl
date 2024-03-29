using Test
using QuestradeAPI
using Dates

@testset "Integration Tests" begin
    @test begin 
        token = QuestradeToken("TEST", pwd())
        QuestradeAPI.test(token)
    end

    @test begin
        token = QuestradeAPI.QuestradeToken("TEST", pwd())
        QuestradeAPI.isexpired(token) == false
    end

    @test begin
        token = QuestradeAPI.QuestradeToken("TEST", pwd())
        accounts = QuestradeAPI.get_accounts(token)
        true
    end

    @test begin
        token = QuestradeAPI.QuestradeToken("TEST", pwd())
        accounts = QuestradeAPI.get_accounts(token)
        account = [acc for acc in accounts if acc["type"] == "TFSA"][1]
        transactions = QuestradeAPI.get_activities(token, account["number"], Date(2023, 3, 20), Date(2023, 4, 27))
        length(transactions) > 1
    end

    @test begin
        token = QuestradeAPI.QuestradeToken("TEST", pwd())
        accounts = QuestradeAPI.get_accounts(token)
        account = [acc for acc in accounts if acc["type"] == "TFSA"][1]
        balances = QuestradeAPI.get_balances(token, account["number"])
        true
    end

    @test begin
        names = "AAPL"
        token = QuestradeAPI.QuestradeToken("TEST", pwd())
        symbols = QuestradeAPI.get_symbols(token, names)
        symbols["symbolId"] == 8049
    end

    @test begin
        names = ["AAPL", "VOO"]
        token = QuestradeAPI.QuestradeToken("TEST", pwd())
        symbols = QuestradeAPI.get_symbols(token, names)
        length(symbols) == 2
    end
    @test begin
        id = 8049
        token = QuestradeAPI.QuestradeToken("TEST", pwd())
        symbols = QuestradeAPI.get_symbols(token, id)
        symbols["symbolId"] == 8049
    end
    @test begin
        ids = [8049]
        token = QuestradeAPI.QuestradeToken("TEST", pwd())
        symbols = QuestradeAPI.get_symbols(token, ids)
        length(symbols) == 1
    end

    @test begin
        id = 8049
        token = QuestradeAPI.QuestradeToken("TEST", pwd())
        symbols = QuestradeAPI.get_option_chain(token, id)
        length(symbols) > 1
    end
end
