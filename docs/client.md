client
===

---

- [new ReservableClient(io, action)](#ReservableClient)
- [ReservableClient.reserve()](#ReservableClient-reserve)
- [ReservableClient.send(data)](#ReservableClient-send)
- [ReservableClient.release()](#ReservableClient-release)

---

<a name="ReservableClient"></a>
`new reservable.Client(io, action) -> ReservableClient`

creates an instance of `ReservableClient`

- `io` - the Socketeer client
- `action` - the action to reserve

<a name="ReservableClient-reserve"></a>
`ReservableClient.reserve() -> Promise<null, err>`

continuously attempts to reserve the action every 1 second

- `resolve`s when the client was able to reserve the action
- `reject`s when the client encounters an error or a message other than "RESERVED" or "OK"

<a name="ReservableClient-send"></a>
`ReservableClient.send(data) -> Promise<response, err>`

sends data to the reserved action

- `resolve`s when the sending of data was successful
  + `response` is the response from the server
- `reject`s when the client encounters an error or if the sending of data was not successful for whatever reason

<a name="ReservableClient-release"></a>
`ReservableClient.release() -> Promise<null, err>`

`resolve`s when the client was able to release the action
  - this resolves even if the client did not reserve the action in the first place
`reject`s when the client encounters an error or if the action is reserved to another client