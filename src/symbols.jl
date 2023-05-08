function get_symbols(ids::Vector{Int})::Vector{Dict}
    ids = join(ids, ",")
    r = _get_req(load_token(), "/symbols", Dict("ids"=>ids))
    return _parse_json_response(r)["symbols"]
end

function get_symbols(names::Vector{String})::Vector{Dict}
    names = join(names, ",")
    r = _get_req(load_token(), "/symbols", Dict("names"=>names))
    return _parse_json_response(r)["symbols"]
end

function get_symbols(name::Union{Int, String})::Dict
    info = get_symbols([name])
    if length(info) > 1
        error("More than 1 symbol information returned for $name")
    end
    return info[1]
end

function get_option_chain(id::Int)::Vector{Dict}
    r = _get_req(load_token(), "/symbols/$id/options", Dict())
    return _parse_json_response(r)["optionChain"]
end
