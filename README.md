Example minitest setup using async-http and VCR where I run into an error:

```
Protocol::HTTP1::BadRequest: Message contains both transfer encoding and content length!
```

...and VCR appends new requests to existing requests even though I believe it
should be configured to leave existing cassettes alone.

See `test.rb` for details, run with:

```
bundle install
ruby test.rb
```
