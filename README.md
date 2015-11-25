reservable
===

server
---

```javascript
var socketeer = require('socketeer')
var reservable = require('reservable')

var io = new socketeer.Server()

var reserve = new reservable.Server(io, {
  actions: ['item-feed']
})

var feedAction = reserve.action('item-feed')

feedAction.onBeforeReserve = function (callback) {
  if (busyProcessingFeed) {
    return callback(null, 'BUSY')
  }
  return callback()
}

feedAction.onData = function (data, callback) {
  var sku = processItem(data)
  callback(null, sku)
}

feedAction.onRelease = function (cleanRelease) {
  startProcessingFeed()
}

io.listen(12345)
```

attaches the following Socketeer action listeners:

- `_reservable_reserve(name)`
    + reserves an action to the client
    + client can reserve only one action at a time
- `_reservable_data(data)`
    + sends data for the reserved action
- `_reservable_release`
    + releases a reserved action from the client

---

`new Server(io, opts) -> ReservableServer`

creates an instance of `ReservableServer` to attach to the client

- `io` - the Socketeer server
- `opts`
    + `actions` - an array of allowed actions


`ReservableServer.action(name) -> ReservableServerAction`

gets a `ReservableServerAction` instance for an action

- `name` - the action name


`ReservableServerAction | onBeforeReserve(client, callback)`

**optional** middleware that can prevent the client from attaching to an action before it happens. if the function is defined, then the function **must** call the callback function

- `client` - `ReservableServerClient` instance
- `callback(err, message)` - callback
    + `err` - error, if any
        * Use this for all unexpected errors, so Socketeer can handle them with the appropriate status.
    + `message` - **optional** message to send to the client for why the server rejected the attachment
        * This is for all expected errors. Don't put errors in here, but rejection reason messages, such as "BUSY", or "UNAUTHENTICATED", etc.
        * If no message is specified, Reservable uses the rejection message "REJECTED".

`ReservableServerAction | onReserve(client)`

**optional** event handler for when the action has been reserved to the client

- `client` - `ReservableServerClient` instance

`ReservableServerAction | onData(data, callback)`

**optional** event handler that handles data from the client for the action. if the function is defined, then the function **must** call the callback function

- `data` - data that the client sent
- `callback(err, data)` - respond to the client
    + `err` - error message, if any
    + `data` - **optional** data to send to the client with the response


`ReservableServerAction | onRelease(cleanRelease, oldClient)`

**optional** event handler for when the action has been released

- `cleanRelease`
    + `true` if client emitted a `release` for the action
    + `false` if the client abruptly disconnected before `release`ing
- `oldClient` - a `ReservableServerClient` instance of the client that previously reserved the action

client
---

**TODO** documentation