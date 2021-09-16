# authorized_contract

Example cairo contract using the StarkNet that uses authorization (mostly taken from documentation).

## Usage

```
$ ./authorized_contract.sh
```

**Before you run it, this will:**

1. Prepare and publish the cairo contract
2. Create a private/public key "user"
3. Receive a balance for that user
4. Change the balance using an invalid signature
5. Change the balance using a valid signature
6. Receive the changed user balance

## What I learned using this example

- StarkNet uses ECDSA signatures, same as bitcoin but different from Hyper* which uses Curve25519. I opened an issue
    [asking for support](https://github.com/starkware-libs/cairo-lang/issues/15).
- StarkNet's ECDSA signatures are of the `felt` data type. `felt` types have currently 252bit data space. Which is a lot
    for numeric operations but 4bit short of the computationally useful 256bit support. This makes it also a bit
    awkward to create a private key that is 252bit long but not 256bit. I opted for a 248bit random key. Note: Curve25519
    have 256bit public keys, 512bit private keys and 512bit signatures.

## Open Questions

- What is a good way to create 252bit random keys instead of 248bit?
- Pedersen Hash's are used _everywhere_ and I am not sure about its concrete properties?!
- How does [PrivacyPass](https://kobi.one/2019/01/05/exploring-privacypass.html), as shown in [Stardrop](https://kobi.one/2021/07/14/stardrop.html) work?
