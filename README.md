reservable
===

[![npm version](https://img.shields.io/npm/v/reservable.svg?style=flat-square)](https://npmjs.com/package/reservable)[![travis build](https://img.shields.io/travis/SEAPUNK/reservabe.svg?style=flat-square)](https://travis-ci.org/SEAPUNK/reservable)[![javascript standard style](https://img.shields.io/badge/code%20style-standard-brightgreen.svg?style=flat-square)](http://standardjs.com/)

---

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

```javascript
var socketeer = require('socketeer')
var reservable = require('reservable')

var io = new socketeer.Client('ws://example.com')

var feed = new reservable.Client(io, 'item-feed')

io.on('open', function () {
  feed.reserve().then(function () {
    return feed.send('some stuff')
  }).then(function () {
    return feed.release()
  }).catch(function (err) {
    console.log('got error: ' + err)
  })
})

```

---

`new Client(io, action) -> ReservableClient`

creates an instance of `ReservableClient`

- `io` - the Socketeer client
- `action` - the action to reserve


`ReservableClient.reserve(name) -> Promise<null, err>`

continuously attempts to reserve the action every 1 second

- `resolve`s when the client was able to reserve the action
- `reject`s when the client encounters an error or a message other than "RESERVED" or "OK"

`ReservableClient.send(data) -> Promise<response, err>`

sends data to the reserved action

- `resolve`s when the sending of data was successful
  + `response` is the response from the server
- `reject`s when the client encounters an error or if the sending of data was not successful for whatever reason

`ReservableClient.release() -> Promise<null, err>`

`resolve`s when the client was able to release the action
  - this resolves even if the client did not reserve the action in the first place
`reject`s when the client encounters an error or if the action is reserved to another client