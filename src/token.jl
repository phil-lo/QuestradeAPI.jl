import Base: showerror, Exception

struct QuestradeToken
    access_token::String
    refresh_token::String 
    api_server::String
    expires_in::Int 
    token_type:: String
    refreshed_on::String
end


struct InvalidQuestradeToken <: Exception end
showerror(io::IO, e::InvalidQuestradeToken) = print(io, "No QuestradeToken to load, use refresh_token() with valid refresh token")

"""
Save QuestradeToken to JLD file
"""
function save(token::QuestradeToken; name::String = "QuestradeToken")
    _to_jld(token, name)
    return nothing
end


"""
Load QuestradeToken from JLD file
"""
function load_token(;name::String="QuestradeToken")::Union{QuestradeToken, Nothing}
    try 
        return _load_jld(name)
    catch err
        throw(InvalidQuestradeToken())
    end
end


"""
Delete QuestradeToken
"""
function _delete_token(;name::String="QuestradeToken")
    try
        _delete_jld(name)
    catch err
        @debug "No QuestradeToken to delete"
    end
    return nothing
end


"""
Convert Questrade HTTP response to QuestradeToken
"""
function QuestradeToken(response::HTTP.Messages.Response)
    d = _parse_json_response(response)
    refreshed_on = Dates.format(now(), "yyyy-mm-dd HH:MM:SS")
    return QuestradeToken(d["access_token"], d["refresh_token"], d["api_server"], d["expires_in"], d["token_type"], refreshed_on)
end


"""
Get Questrade token refresh URL
"""
refresh_url() = retrieve(_parse_config(), "Auth", "RefreshUrl")
function refresh_url(refresh_token::AbstractString)
    return "$(refresh_url())$(refresh_token)"
end

"""
Used to initialize first token
"""
function refresh_token(refresh_token::AbstractString)
    url = refresh_url(refresh_token)
    response = HTTP.get(url)
    token = QuestradeToken(response)

    _delete_token()
    save(token)
    return token
end


"""
Refresh an existing token
"""
function refresh_token!(token::QuestradeToken)
    url = refresh_url(token.refresh_token)
    response = HTTP.get(url)
    token = QuestradeToken(response)
    
    _delete_token()
    save(token)
    return token
end


function test(token::QuestradeToken)::Bool
    try
        r = _get_req(token, "/time")
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
