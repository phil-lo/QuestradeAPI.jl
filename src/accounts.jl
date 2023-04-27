import Base: parse
using Parameters

struct Account
    account_type::String
    client_type::String
    number::Int
    status::String
    is_billing::Bool
    is_primary::Bool
end


function Account(d::Dict)
    Account(
        d["type"],
        d["clientAccountType"],
        parse(Int, d["number"]),
        d["status"],
        d["isBilling"],
        d["isPrimary"]
    )
end


function get_accounts()::Vector{Account}
    r = QuestradeAPI._get_req(TOKEN, "/accounts")
    accounts = QuestradeAPI._parse_json_response(r)["accounts"]
    return [Account(account) for account in accounts]
end
