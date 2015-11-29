reservable
===

[![npm version](https://img.shields.io/npm/v/reservable.svg?style=flat-square)](https://npmjs.com/package/reservable)[![travis build](https://img.shields.io/travis/SEAPUNK/reservabe.svg?style=flat-square)](https://travis-ci.org/SEAPUNK/reservable)[![javascript standard style](https://img.shields.io/badge/code%20style-standard-blue.svg?style=flat-square)](http://standardjs.com/)

---

socketeer server middleware and client to simplify client action reservations. think: mutex

[documentation](docs/README.md)

---

### server example

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

### client example

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
