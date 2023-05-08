function get_accounts()::Vector{Dict}
    r = QuestradeAPI._get_req(load_token(), "/accounts", Dict())
    accounts = QuestradeAPI._parse_json_response(r)["accounts"]
    if length(accounts) < 1
        return Dict[]
    end
    
    for account in accounts
        account["number"] = parse(Int, account["number"])
    end
    return accounts
end


function get_activities(id::Int, start_dt::Date, end_dt::Date; dt_rng::Int = 7)::Vector{Dict}
    dr = start_dt:Day(dt_rng):end_dt

    # Looping because there is a limit to response length (˜25) from the API
    # If an error occurs, set the dt_rng to a lower number
    activities = Dict[]
    
    for date in dr
        params = Dict(
        "startTime" => "$(DateTime(date))-0",
        "endTime" => "$(DateTime(date + Day(dt_rng-1)))-0"
        )
        r = _get_req(load_token(), "/accounts/$(id)/activities", params)
        append!(activities, _parse_json_response(r)["activities"])
    end

    return activities
end

function get_balances(id::Int)::Vector{Dict}
    r = _get_req(load_token(), "/accounts/$(id)/balances", Dict())
    return _parse_json_response(r)["perCurrencyBalances"]
end
