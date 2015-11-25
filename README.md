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

feedAction.beforeStart = function(callback){
    if (busyProcessingFeed){
        return callback(null, "BUSY")
    }
    return callback(null)
}

feedAction.onData = function(data, callback){
    var sku = processItem(data)
    callback(null, sku)
}

feedAction.onRelease = function(cleanRelease){
    startProcessingFeed()
}

io.listen(12345)
```

attaches the following Socketeer action listeners:

- `reserve(name)`
    + reserves an action to the client
    + client can reserve only one action at a time
- `process(data)`
    + sends data for the reserved action
- `release`
    + releases a reserved action from the client

---

`new Server(io, opts) -> ReservableServer`

creates an instance of `ReservableServer` to attach to the client

- `io` - the Socketeer server
- `opts`
    + `actions` - an array of allowed actions


`ReservableServer.action(name) -> ReservableAction`

gets a `ReservableAction` instance for an action

- `name` - the action name


`ReservableAction | onBeforeStart(callback)`

**optional** middleware that can prevent the client from attaching to an action before it happens. if the function is defined, then the function **must** call the callback function

- `callback(err, message)` - callback
    + `err` - error, if any
        * Use this for all unexpected errors, so when Reservable calls back, it returns with the message "ERROR"
    + `message` - **optional** message to send to the client for why the server rejected the attachment
        * This is for all expected errors. Don't put errors in here, but rejection reason messages, such as "BUSY", or "UNAUTHENTICATED", etc.
        * If no message is specified, Reservable uses the rejection message "REJECTED".

`ReservableAction | onData(data, callback)`

**optional** event handler that handles data from the client for the action. if the function is defined, then the function **must** call the callback function

- `data` - data that the client sent
- `callback(err, data)` - respond to the client
    + `err` - error message, if any
    + `data` - **optional** data to send to the client with the response


`ReservableAction | onRelease(cleanRelease)`

**optional** event handler for when the action has been released

- `cleanRelease`
    + `true` if client emitted a `release` for the action
    + `false` if the client abruptly disconnected before `release`ing

client
---

**TODO** documentation