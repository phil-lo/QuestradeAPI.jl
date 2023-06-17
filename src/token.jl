struct QuestradeToken
    access_token::String
    refresh_token::String 
    api_server::String
    expires_in::Int 
    token_type:: String
    refreshed_on::String
    name::String
    directory::String
end


struct MissingQuestradeToken <: Exception end
showerror(io::IO, e::MissingQuestradeToken) = print(io, "No QuestradeToken to load, use refresh_token() with valid refresh token")

"""
Save QuestradeToken to JLD file
"""
function save(token::QuestradeToken)
    _to_jld(token, token.name, token.directory)
    return nothing
end


"""
Load QuestradeToken from JLD file
"""
function load_token(name::String, directory::String)::QuestradeToken
    try 
        return _load_jld(name, directory)
    catch err
        throw(MissingQuestradeToken())
    end
end


"""
Delete QuestradeToken
"""
function _delete_token(name::String, directory::String)
    try
        _delete_jld(name, directory)
    catch err
        @debug "No QuestradeToken to delete"
    end
    return nothing
end


"""
Convert Questrade HTTP response to QuestradeToken
"""
function QuestradeToken(response::HTTP.Messages.Response, name::String, directory::String)
    d = _parse_json_response(response)
    refreshed_on = Dates.format(now(), "yyyy-mm-dd HH:MM:SS")
    return QuestradeToken(d["access_token"], d["refresh_token"], d["api_server"], d["expires_in"], d["token_type"], refreshed_on, name, directory)
end


"""
Get Questrade token refresh URL
"""
refresh_url() = retrieve(_parse_config(), "Auth", "RefreshUrl")
function refresh_url(refresh_token::String)
    return "$(refresh_url())$(refresh_token)"
end

"""
Used to initialize first token
"""
function refresh_token(refresh_token::String, name::String, directory::String)
    @info "Refreshing QuestradeToken($name)"
    url = refresh_url(refresh_token)
    response = HTTP.get(url)
    token = QuestradeToken(response, name, directory)

    _delete_token(name, directory)
    save(token)
    return token
end


"""
Refresh an existing token
"""
function refresh_token!(token::QuestradeToken)
    token = refresh_token(token.refresh_token, token.name, token.directory)
    return token
end


function test(token::QuestradeToken)::Bool
    try
        r = _get_req(token, "/time", Dict())
        return true
    catch err
        return false
    end
end


"""
true if token needs is expired and needs to be refreshed
"""
function isexpired(token::QuestradeToken)::Bool
    if refreshed_on(token) + Second(token.expires_in - 60) >= now()
        return false
    end
    return true
end


function refreshed_on(token::QuestradeToken)::DateTime
    return DateTime(token.refreshed_on, "yyyy-mm-dd HH:MM:SS")
end
