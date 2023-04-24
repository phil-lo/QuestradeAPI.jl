function get_accounts()::Vector{Dict}
    token = QuestradeAPI.load_current_token()
    r = QuestradeAPI._get_req(token, "/accounts")
    accounts = QuestradeAPI._parse_json_response(r)["accounts"]
    return accounts
end