## 1. Fix

- [x] 1.1 In `Merchant.lua`, read the row again in the purchase callback and drop the purchase (return false, log it) when the name, link or price differs or the row is gone.
- [x] 1.2 Test: unchanged row buys; another item at the index, a changed price and a closed vendor buy nothing and log; break the check and confirm the tests fail.

## 2. Verify

- [x] 2.1 `make test` and `make check`.
