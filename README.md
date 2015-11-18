reservable
===

server
---

```javascript
var ioserver = require('socket.io')
var reservable = require('reservable')

var io = ioserver()

var reserve = reservable.server.create(io, {
    actions: ['item-feed']
})

var feedAction = reserve.action('item-feed')

feedAction.beforeStart = function(resolve, reject){    
    if (busyProcessingFeed){
        return reject("BUSY")
    }
    return resolve()
}

feedAction.onData = function(data, respond){
    var sku = processItem(data)
    respond(sku)
}

feedAction.onRelease = function(cleanRelease){
    startProcessingFeed()
}

io.listen(12345)
```

attaches the following socket listeners:

- `reserve(name)`
    + reserves an action to the client
    + client can reserve only one action at a time
- `process(data)`
    + sends data for the reserved action
- `release`
    + releases a reserved action from the client

---

`server.create(socketio, opts) -> ReservableServer`

creates an instance of `ReservableServer` to attach to the client

- `socketio` - the socket.io server
- `opts`
    + `actions` - an array of allowed actions


`ReservableServer.action(name) -> ReservableAction`

gets a `ReservableAction` instance for an action

- `name` - the action name


`ReservableAction | onBeforeStart(resolve, reject)`

**optional** middleware that can prevent the client from attaching to an action before it happens. if the function is defined, then the function **must** call one of the callback functions

- `resolve` - allow the attachment of the action
- `reject(status)` - prevent the client from attaching to an action
    + `status` - **optional** message to send to the client for why the server rejected the attachment

`ReservableAction | onData(data, respond)`

**optional** event handler that handles data from the client for the action. if the function is defined, then the function **must** call the respond function

- `data` - data that the client sent
- `respond(data)` - respond to the client
    + `data` - **optional** data to send to the client with the response


`ReservableAction | onRelease(cleanRelease)`

**optional** event handler for when the action has been released

- `cleanRelease`
    + `true` if client emitted a `release` for the action
    + `false` if the client abruptly disconnected before `release`ing

client
---

**TODO** documentation