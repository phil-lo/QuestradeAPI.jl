function _parse_response(::Type{Dict}, response::HTTP.Messages.Response)
    body = copy(response.body)
    return JSON.Parser.parse(String(body))
end


function _check_status_code(resp::HTTP.Messages.Response)
    if resp.status != 200
        error("Expected status code 200 but received $(resp.status)")
    end
end


function _parse_config()
    conf = ConfParse("$(@__DIR__)/config.ini")
    parse_conf!(conf)
    return conf
end


function _to_jld(t, name::AbstractString)
    jldopen("$(@__DIR__)/$name.jld", "w") do file
        write(file, name, t)
    end
    return nothing
end


function _load_jld(name::AbstractString)::Any
    return jldopen("$(@__DIR__)/$name.jld", "r") do file read(file, name) end
end


function _delete_jld(name::AbstractString)
    rm("$(@__DIR__)/$name.jld")
    return nothing
end

_base_url(token::QuestradeToken) = "$(token.api_server)v1"
_headers(token::QuestradeToken) = Dict("Authorization" => "$(token.token_type) $(token.access_token)")


function _get_req(token::QuestradeToken, url::String)::HTTP.Messages.Response
    r = HTTP.request("GET", "$(_base_url(token))$url?", headers=_headers(token))
    return r
end

