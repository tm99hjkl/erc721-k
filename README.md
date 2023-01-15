# erc721-k
Formal specification of ERC-721 in K

# Install K
## Install Nix
For faster installation, you can use [Nix](https://nixos.org/download.html).
```
$ sh <(curl -L https://nixos.org/nix/install) --no-daemon
```

## Install K
Run this command to install K via Nix:
```
$ bash <(curl https://kframework.org/install)
$ kup install k
```

You can update K with:
```
$ kup update k
```

For more details see [here](https://github.com/runtimeverification/k/releases/tag/v5.5.53).

# Usage of this repository
For example, run this command to execute `approve` function of [EIP-721](https://eips.ethereum.org/EIPS/eip-721).
```
$ git clone https://github.com/tm99hjkl/erc721-k
$ kompile erc721.k
$ krun tests/approve/approve.test
```

