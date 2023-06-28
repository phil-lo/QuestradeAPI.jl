function _parse_json_response(response::HTTP.Messages.Response)
    if response.status != 200
        error("Request status was $(response.status), expected 200")
    end

    body = copy(response.body)
    return JSON.Parser.parse(String(body))
end


function _parse_config()
    conf = ConfParse("$(@__DIR__)/config.ini")
    parse_conf!(conf)
    return conf
end


function _to_jld(t, name::AbstractString, directory::AbstractString)
    jldopen("$(directory)/$(name).jld", "w") do file
        write(file, name, t)
    end
    return nothing
end


function _load_jld(name::AbstractString, directory::AbstractString)::Any
    return jldopen("$(directory)/$(name).jld", "r") do file read(file, name) end
end


function _delete_jld(name::AbstractString, directory::AbstractString)
    rm("$(directory)/$name.jld")
    return nothing
end

_version() = retrieve(_parse_config(), "Settings", "Version")
_base_url(token::QuestradeToken) = "$(token.api_server)$(_version())"
_headers(token::QuestradeToken) = Dict("Authorization" => "$(token.token_type) $(token.access_token)")


function _get_req(token::QuestradeToken, url::String, params::Dict; retries::Int = 1)::HTTP.Messages.Response
    if isexpired(token)
        @info "Refreshing QuestradeToken"
        token = refresh_token!(token)
    end
    
    q_params = collect(pairs(params))
    query = join(map(p -> "$(p.first)=$(p.second)", q_params), "&")

    try
        return HTTP.request("GET", "$(_base_url(token))$url?$(query)", headers=_headers(token))
    catch e
        if retries < 1
            error(e)
        else
            token = refresh_token!(token)
            return _get_req(token, url, params, retries=0)
        end
    end
end

_parse_date(date::AbstractString)::Date = Date(date[1:10])
