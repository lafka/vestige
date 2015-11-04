# Vestige

**Deprecated**: It works, but needs alot more love to become usable. Shell scripts FTW!

Vestige builds shit. It's core purpose is to take a copy of a
repository, run some command in the copy and return a `OK/NOT-OK` status;
maybe with some logs.

## For development

```
# For development, will open up on http://localhost:4000
mix do deps.get && iex -S mix
```

## Create a release for local testing

```
mix release && rel/vestige/bin/vestige console
```

## Building docker image

```
# This will automatically tag vestige:<vsn>
mix dock
```
