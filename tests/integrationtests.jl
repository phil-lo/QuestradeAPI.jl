using Test
using QuestradeAPI
using Dates


@testset "Integration" begin
    @test begin
        token = QuestradeAPI.load_token()
        @time QuestradeAPI.test(token)
    end

    @test begin
        token = QuestradeAPI.load_token()
        QuestradeAPI.isexpired(token) == false
    end

    @test begin
        accounts = get_accounts()
        true
    end

    @test begin
        accounts = get_accounts()
        account = [acc for acc in accounts if acc["type"] == "TFSA"][1]
        transactions = get_activities(account["number"], Date(2023, 3, 20), Date(2023, 4, 27))
        length(transactions) > 1
    end

    @test begin
        accounts = get_accounts()
        account = [acc for acc in accounts if acc["type"] == "TFSA"][1]
        balances = get_balances(account["number"])
        true
    end

    @test begin
        names = "AAPL"
        symbols = get_symbols(names)
        symbols["symbolId"] == 8049
    end

    @test begin
        names = ["AAPL", "VOO"]
        symbols = get_symbols(names)
        length(symbols) == 2
    end
    @test begin
        id = 8049
        symbols = get_symbols(id)
        symbols["symbolId"] == 8049
    end
    @test begin
        ids = [8049]
        symbols = get_symbols(ids)
        length(symbols) == 1
    end

    @test begin
        id = 8049
        symbols = get_option_chain(id)
        length(symbols) > 1
    end
end
