# Networking
Lattice works by sending and receiving data over a network.


## Packet Format
All packets are encoded in JSON format. They follow this format:
```jsonc
// Packet Format
{
  "id": "nanoid",
  "sender": "machine_id",
  // Recipients are the machines that will receive the packet.
  "recipients": ["machine_id2", "machine_id3"],
  // Type is the type of packet.
  // Supported types are "rpc", "arp", and "cc".
  // rpc - Remote Procedure Call - Used for controlling other machines.
  // cc - Control Channel - Used for controlling the network.
  "type": "rpc",
  // Payload is the data that will be sent.
  "payload": {
    "method": "method_name",
    "params": ["param1", "param2"]
  },
  // Respond is whether the packet should be responded to.
  "respond": false
}
```


## Flow

When a device powers on, it will send an `cc` packet to the recipient `*`, with the payload being similar to the following:
```jsonc
{
  "id": "sender_id",
  "op": "net.join",
}
```

When a device receives a `cc` packet with the operation `net.join`, it should respond with a `cc` packet with the operation `net.join.ssid` and the payload being similar to the following:
```jsonc
{
  "id": "sender_id",
  "op": "net.join.ssid",
  "ssid": "ssid_name"
}
```

When a device is powering off, it should send a `cc` packet to the recipient `*`, with the payload being similar to the following:
```jsonc
{
  "id": "sender_id",
  "op": "net.leave",
}
```

> #### **Security**
> Lattice will boot up for the first time with a random sender_id. This id is unique to the device, and is used to identify the device on the network.
> It is however worth noting that when initially joining the network, the device will be sending data out to any machine in range of its modem, completely
> insecurely.
>
> An optional service for configuring the network can be toggled in the kernel settings. (found at `/os/lattice.toml, under the `[services.network]`)
> Otherwise, the device will not join the network unless an SSID is provided in the kernel settings.
>
> When installing the system you should be prompted to enter the expected SSID of the network you wish to join.
