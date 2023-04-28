function get_balances(id::Int)::Vector{Dict}
    r = _get_req(load_token(), "/accounts/$(id)/balances", Dict())
    return _parse_json_response(r)["perCurrencyBalances"]
end


function get_balances(account::Account)::Vector{Dict}
    return get_balances(account.id)
end