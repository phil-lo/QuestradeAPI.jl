abstract type AccountActivity end
account(activity::AccountActivity)::Int = activity.account
date(activity::AccountActivity)::Date = activity.date
currency(activity::AccountActivity)::String = activity.currency


abstract type Trade <: AccountActivity end
ticker(trade::Trade) = trade.ticker
quantity(trade::Trade) = trade.quantity
price(trade::Trade) = trade.price
commission(trade::Trade) = trade.commission
total_amount(trade::Trade) = trade.price * trade.quantity

struct Buy <: Trade
    date::Date
    ticker::Symbol
    currency::Symbol
    quantity::Float64
    price::Float64
    commission::Float64
end

struct Sell <: Trade 
    date::Date
    ticker::Symbol
    currency::Symbol
    quantity::Float64
    price::Float64
    commission::Float64
end

struct Transfer <: Trade 
    date::Date
    ticker::Symbol
    currency::Symbol
    quantity::Float64
    price::Float64
    commission::Float64
end


struct Dividend <: AccountActivity 
    date::Date
    ticker::Symbol
    currency::Symbol
    amount::Float64
end


struct FXConversion <: AccountActivity 
    date::Date
    currency::Symbol
    amount::Float64
end

abstract type Contribution <: AccountActivity end

struct Deposit <: Contribution 
    date::Date
    currency::Symbol
    amount::Float64
end


struct Withdrawal <: Contribution 
    date::Date
    currency::Symbol
    amount::Float64
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


function get_activities(account::Account, start_dt::Date, end_dt::Date; dt_rng::Int = 7)::Vector{Dict}
    activities = get_activities(account.id, start_dt, end_dt, dt_rng=dt_rng)

    return activities
end
# check using NamedTupleTools
# and see if it can simplify things