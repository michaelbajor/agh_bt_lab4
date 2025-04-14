## Lab4

Kinda easy-ish "CTF". Everything should be done via Foundry tests. Have fun :)

Each *.t.sol file is a test file associated with the given contract (file names should tell you which contracts are tested). Don't touch the `setUp` function. If there are other `test_*` functions, consider them a reference on how to use certain functionalities.

Your solutions should be present in the `test_exploit` function. You can implement helper contracts if they are required for exploits. More users can also be added.

There is no suggested order of "tasks" - do them in whatever order you want to. One caveat, the `Bank` task will probably be the most challenging of them. It does not mean it's much harder than the rest, but it will require the most complex exploit, which might take some time to develop if you don't have experience with Foundry.

There's a bonus point for the project waiting for whoever manages to solve it during the lab. Small tip: try to solve `PaymentSystem` before `Bank`.

Everything (or at least most) that you'd need to solve every challenge has been talked about during the lectures.

## Usage

### Build

```shell
forge build
```

### Test

```shell
forge test
```

If you'd be using `console.logX` functions and you'd want to see them in the terminal, run the tests with:

```shell
forge test -vv
```

Adding more "v" to the "-vv" will increase verobisity even more (so you can watch the traces).

If you want to run the test defined in a specific contract (for example only in `OnchainWalletTest` contract) run it with:

```shell
forge test --match-contract OnchainWalletTest
```
