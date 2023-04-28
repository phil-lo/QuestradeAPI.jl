struct Account
    account_type::String
    client_type::String
    id::Int
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


function get_accounts()::Vector{Dict}
    r = QuestradeAPI._get_req(load_token(), "/accounts", Dict())
    accounts = QuestradeAPI._parse_json_response(r)["accounts"]
    return accounts
end


function get_accounts(::Type{Account})::Vector{Account}
    return Account.(get_accounts())
end
