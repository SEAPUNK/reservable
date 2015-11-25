require! 'debug'
require! 'suspend'
require! './server-client':ReservableServerClient
require! './server-action':ReservableServerAction

class ReservableServer
    (@io, @opts={}) ->
        @actions = {}
        for action in @opts.[]actions
            @actions[action] = new ReservableServerAction action
        @io.use (client, next) ~>
            new ReservableServerClient client, @

    /**
     * Gets a ReservableServerAction instance
     * @param {String} name Action name
     */
    action: (name) ->
        return @actions[name]

    /**
     * Attempts to reserve an action for a client.
     * @param {String} name Action name
     * @param {ReservableServerClient} client Client
     */
    reserve: suspend.promise (name, client) ->*
        if not @actions[name]
            return "NONEXISTENT"
        return yield @actions[name].reserve client

    /**
     * Attempts to release an action.
     * @param {String} name Action name
     * @param {ReservableServerClient} client Client
     * @param {Boolean} clean Clean release
     */
    release: (name, client, clean) ->
        if not @actions[name]
            /** @TODO debug warn */
            return true
        if not @actions[name].is-owner client
            /** @TODO debug warn, as this shouldn't really ever happen */
            return false
        @actions[name].release clean
        return true

    /**
     * Attempts to send data to an action.
     * @param {String} name Action name
     * @param {ReservableServerClient} client Client
     * @param {Object} data Data
     */
    data: suspend.promise (name, client, data) ->*
        if not @actions[name]
            return do
                ok: false
                data: "action does not exist"
        if not @actions[name].is-owner client
            return do
                ok: false
                data: "action is not reserved for the client (should never happen)"
        return yield @actions[name].data data

module.exports = ReservableServer