mutable struct QuestradeToken
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
showerror(io::IO, e::MissingQuestradeToken) = print(io, "No QuestradeToken to load, use QuestradeToken(refresh_token::String, name::String, directory::String) with valid refresh token")

function convert(::Type{Dict}, token::QuestradeToken)
    return Dict(
        :access_token => token.access_token,
        :refresh_token => token.refresh_token,
        :api_server => token.api_server,
        :expires_in => token.expires_in,
        :token_type => token.token_type,
        :refreshed_on => token.refreshed_on,
        :name => token.name,
        :directory => token.directory
    )
end

"""
Load an existing QuestradeToken

QuestradeToken(name::AbstractString, directory::AbstractString)
"""
function QuestradeToken(name::AbstractString, directory::AbstractString)
    try
        d = TOML.parsefile("$(directory)/$(name).toml")
        return QuestradeToken(
            d["access_token"],
            d["refresh_token"],
            d["api_server"],
            d["expires_in"],
            d["token_type"],
            d["refreshed_on"],
            d["name"],
            d["directory"]
        )
    catch err
        throw(MissingQuestradeToken())
    end
end



"""
Save QuestradeToken to TOML file
"""
function save(token::QuestradeToken)
    d = convert(Dict, token)
    open("$(token.directory)/$(token.name).toml", "w") do io
        TOML.print(io, d)
    end
    return nothing
end


"""
Delete a QuestradeToken
"""
function delete!(token::QuestradeToken)
    try
        rm("$(token.directory)/$(token.name).toml")
    catch err
        @debug "No QuestradeToken to delete"
    end
    return nothing
end


"""
Initialize a QuestradeToken with a HTTP response

QuestradeToken(response::HTTP.Messages.Response, name::String, directory::String)
"""
function QuestradeToken(response::HTTP.Messages.Response, name::String, directory::String)
    d = _parse_json_response(response)
    refreshed_on = Dates.format(now(), "yyyy-mm-dd HH:MM:SS")
    return QuestradeToken(d["access_token"], d["refresh_token"], d["api_server"], d["expires_in"], d["token_type"], refreshed_on, name, directory)
end


"""
Get Questrade token refresh URL
"""
refresh_url() = _parse_config()["Auth"]["RefreshUrl"]
function refresh_url(refresh_token::String)
    return "$(refresh_url())$(refresh_token)"
end


"""
Used to initialize a new QuestradeToken

QuestradeToken(refresh_token::String, name::String, directory::String)
"""
function QuestradeToken(refresh_token::String, name::String, directory::String)
    @info "Refreshing QuestradeToken($name)"
    url = refresh_url(refresh_token)
    response = HTTP.get(url)
    token = QuestradeToken(response, name, directory)

    save(token)
    return token
end

"""
Refresh an existing token
"""
function refresh_token!(token::QuestradeToken)
    new_token = QuestradeToken(token.refresh_token, token.name, token.directory)
    
    # Refreshing original token, preventing re-using an expired token
    token.access_token = new_token.access_token
    token.refresh_token = new_token.refresh_token
    token.api_server = new_token.api_server
    token.expires_in = new_token.expires_in 
    token.token_type = new_token.token_type
    token.refreshed_on = new_token.refreshed_on
    token.name = new_token.name
    token.directory = new_token.directory

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
true if QuestradeToken needs is expired and needs to be refreshed
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
