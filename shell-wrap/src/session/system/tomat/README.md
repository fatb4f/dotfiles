# Tomat lockout producer contract

These files document the commands a break producer should run. They are examples
only; they do not enable live lockout by themselves.

Break start:

```sh
break_seconds="<duration supplied by the break event>"
until_epoch="$(( $(date +%s) + break_seconds ))"
sudo /usr/local/bin/session lockout set "$until_epoch"
```

Break end or skip:

```sh
sudo /usr/local/bin/session lockout clear
```

The producer computes or forwards the deadline at the transition edge. It should
not query live daemon state from the auth path. Clearing the deadline is an early
release optimization; expiry of the root-owned deadline remains authoritative.
