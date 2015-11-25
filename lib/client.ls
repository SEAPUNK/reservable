require! 'suspend'
require! 'debug'
require! 'util'
require! 'sleep-promise':sleep

class ReservableClient
    (@client, @action) ->

    /**
     * runs the reservation action
     */
    try-reserve: (allowed-responses) ->
        return new Promise (resolve, reject) ~>
            err, response <~ @client.emit '_reservable_reserve', @action
            if err and response is 1 # ActionResponse.NONEXISTENT
                return reject new Error "server is not a reservable server"
            else if err
                return reject err

            if response is "OK"
                return resolve true
            else if response is "RESERVED"
            or if response in allowed-responses
                return resolve false
            else
                return reject new Error "server responded with '#{response}' on reservation attempt"

    /**
     * continuously tries to reserve the action
     */
    reserve: suspend.promise (allowed-responses) ->*
        while true
            ok = yield @try-reserve allowed-responses
            break if ok
            yield sleep 1000
        @reserved = true

    /**
     * sends data to action
     */
    send: suspend.promise (data) ->*
        response = yield @client.emit '_reservable_data', data, suspend.resume!
        if not response.ok
            throw new Error "response not 'ok': #{response.data}"
        return response.data

    /**
     * releases action
     */
    release: suspend.promise (data) ->*
        ok = yield @client.emit '_reservable_release', null, suspend.resume!
        if not ok
            throw new Error 'could not release action'
module.exports = ReservableClient