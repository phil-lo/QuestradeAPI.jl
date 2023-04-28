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
        @time accounts = get_accounts()
        true
    end

    @test begin
        accounts = get_accounts(QuestradeAPI.Account)
        account = [acc for acc in accounts if acc.account_type == "TFSA"][1]
        transactions = get_activities(account, Date(2023, 3, 20), Date(2023, 4, 27))
        length(transactions) > 1
    end

    @test begin
        accounts = get_accounts(QuestradeAPI.Account)
        account = [acc for acc in accounts if acc.account_type == "TFSA"][1]
        balances = get_balances(account)
        true
    end
end
