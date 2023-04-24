struct QuestradeToken
    access_token::String
    refresh_token::String 
    api_server::String
    expires_in::Int 
    token_type:: String 
end


"""
New QuestradeToken
"""
QuestradeToken(refresh_token::AbstractString) = QuestradeToken("", refresh_token, "", 0, "New")


isnew(token::QuestradeToken) = token.token_type == "New"


"""
Save QuestradeToken to JLD file
"""
function save(token::QuestradeToken)
    _to_jld(token, "QuestradeToken")
end


"""
Load QuestradeToken from JLD file
"""
function load_current_token()::Union{QuestradeToken, Nothing}
    try 
        return _load_jld("QuestradeToken")
    catch err
        @info "No QuestradeToken to load"
        return nothing
    end
end


"""
Delete QuestradeToken
"""
function delete_current_token()
    try
        _delete_jld("QuestradeToken")
    catch err
        @info "No QuestradeToken to delete"
    end
    return nothing
end


"""
Convert Questrade HTTP response to QuestradeToken
"""
function QuestradeToken(response::HTTP.Messages.Response)
    d = _parse_response(Dict, response)
    return QuestradeToken(d["access_token"], d["refresh_token"], d["api_server"], d["expires_in"], d["token_type"])
end


"""
Get Questrade token refresh URL
"""
refresh_url() = retrieve(_parse_config(), "Auth", "RefreshUrl")
function refresh_url(refresh_token::AbstractString)
    return "$(refresh_url())$(refresh_token)"
end

function refresh_token(refresh_token::AbstractString)
    delete_current_token()
    url = refresh_url(refresh_token)
    response = HTTP.get(url)
    token = QuestradeToken(response)
    save(token)
    return token
end

function validate(token::QuestradeToken)::Bool
    try
        r = QuestradeAPI._get_req(token, "/time")
        return true
    catch err
        return false
    end
end