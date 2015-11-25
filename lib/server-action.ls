class ReservableServerAction
    (@name) ->
        @client = null

    is-owner: (client) ->
        return client is @client

    reserve: suspend.promise (client) ->*
        if @client
            return "RESERVED"
        if typeof @on-before-reserve is 'function'
            message = yield @on-before-reserve client, suspend.resume!
            return message if message
        @client = client
        if typeof @on-reserve is 'function'
            set-immediate ~>
                @on-reserve @client
        return "OK"

    data: suspend.promise (data) ->*
        if @on-data
            return yield @on-data data, suspend.resume!
        else
            return null

    release: (clean) ->
        old-client = @client
        if typeof @on-release is 'function'
            set-immedate ~>
                @on-release clean, old-client
        @client = null

module.exports = ReservableServerAction