require! 'debug'
require! 'suspend'

class ReservableServerClient
    (@client, @manager) ->
        @reserved = null
        client.action '_reservable_reserve', @~handle-reserve
        client.action '_reservable_data', @~handle-data
        client.action '_reservable_release', @~handle-release
        client.on 'close', @~handle-close

    /**
     * Handles a reserve attempt.
     */
    handle-reserve: suspend.callback (name) ->*
        status = yield @manager.reserve name, @
        if status is "OK"
            @reserved = name
        return status

    /**
     * Handles a data event.
     */
    handle-data: suspend.callback (data) ->*
        if not @reserved
            return do
                ok: false
                data: "client does not have any action reserved"
        return yield @manager.data @reserved, @client, data

    /**
     * Handles a release attempt.
     */
    handle-release: suspend.callback ->*
        if not @reserved
            return true
        ok = @manager.release @reserved, @client, true
        if ok then @reserved = null
        return ok

    /**
     * Handles the close event 
     */
    handle-close: ->
        return if not @reserved
        @manager.release @reserved, @client, false

module.exports = ReservableServerClient