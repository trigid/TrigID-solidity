

## TrigID - Triangulation for Identity
---
### HOW IT WORKS
TrigID uses a novel scheme, inspired by geometric triangulation. It takes common identifiers, encrypts them, then reduces their information content to 20 or fewer bits. This “mashing algorithm” makes what we call “Identity Vectors” that are really just arcs or edges – lines that connects facts in a giant identity graph.  We refer to each arc as a "Mash".

![alt text][howitworks]


### ID TOKENS 

ID tokens are a first-class TrigID crypto-infrastructure component. Each token transaction can carry a set of these Mashes within its data field.

Think of these as the transactions in a database transaction log. When you transfer ID tokens, the ID transaction becomes part of the TrigID database. When someone wants to use the data, they parse the blockchain and assemble the TrigID graph the same way that a conventional database is assembled from a transaction log backup.

All validation of Mash data is carried-out off-chain, so very little sophistication is required within the ID Smart Contract.

![alt text][tokens]

[howitworks]: https://github.com/trigid/TrigID-solidity/blob/master/images/trigid-how-it-works.png "How it works"
[tokens]: https://github.com/trigid/TrigID-solidity/blob/master/images/id-tokens.png "ID tokens"
