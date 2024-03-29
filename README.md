# QuestradeAPI.jl

Julia wrapper library for the [Questrade API](https://www.questrade.com/api/documentation/getting-started). This library is desired to be as simple as possible.

I have implemented the bare minimum for my usage of the API, but contributions are welcomed. Adding routes is fairly simple.

## Installation
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
A refresh token needs to be generated (see Questrade API documentation). The token is then used to make requests to the api with the available methods, see below.
```julia
using QuestradeAPI

# To initialize a new token
token = QuestradeToken("Refresh Token", "Token Name", "Token Directory")


# To load an existing token
token = QuestradeToken("TokenName", "TokenDirectory")
```

### Examples
#### Account Activities
```julia
using Dates
account = QuestradeAPI.get_accounts(token)[1]
activities = QuestradeAPI.get_activities(token, account["number"], Date(2023, 3, 20), Date(2023, 4, 27))
```
#### Account Balances
```julia
balances = QuestradeAPI.get_balances(token, account["number"])
```
