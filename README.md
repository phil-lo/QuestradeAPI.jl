# QuestradeAPI.jl

Julia wrapper library for the [Questrade API](https://www.questrade.com/api/documentation/getting-started). This library is desired to be as simple as possible.

I have implemented the bare minimum for my usage of the API, but contributions are welcomed. Adding routes is fairly simple.

## Installaion
The package is registered in the general Julia package registry.
```julia
]add QuestradeAPI
```

## Current functionalities
 - accounts
 - activities
 - balances
 - symbols information
 - option chain


## Basic usage
### Refresh Token
A refresh_token needs to be defined (see Questrade API documentation). The token itself is not useful for the usage of the library.
```julia
using QuestradeAPI
refresh_token("REFRESH_TOKEN")

# To see the token information
QuestradeAPI.load_token()
```

### Examples
#### Account Activities
```julia
using Dates
account = get_accounts()[1]
activities = get_activities(account["number"], Date(2023, 3, 20), Date(2023, 4, 27))
```
#### Account Balances
```julia
balances = get_balances(account["number"])
```
