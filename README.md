> [!NOTE]
> This package has been replaced by [Uneventful](https://uneventful.js.org/), which fulfills almost all of the original vision for this project, in modern ESM and TypeScript, with the addition of automatic resource cleanup, and many more features besides.  Check it out!

<a href="https://promisesaplus.com/"><img src="https://promisesaplus.com/assets/logo-small.png" align="right" alt="Promises/A+ logo" /></a>

# High-performance Multi-Paradigm Asynchronous Programming

> *Note: this package is less than a week old at this writing, doesn't have anything remotely like a stable API, and has no real documentation yet.  That said, it is* ***awesomely cool*** *and you should definitely look at it again once it reaches at least 0.1.x.  Right now, it's still in that totally experimental, proof-of-concepty 0.0.x phase of development, so don't bother unless you find exotic async algorithms and weird V8 optimization tricks endlessly fascinating.  (Oh, and this is a hobby project at the moment, so there are no particular guarantees as to* ***when*** *it'll get out of 0.0.x!)*

### What Axos is For

Promises.  Observables.  EventStreams.  FRP.  Generators.  Callbacks and thunks.  RxJs, Kefir, and Bacon.  What's *really* the best way to write async code?

The truth is, there isn't *one* best way.  Different APIs work better for expressing different use cases, and sometimes you have to use more than one in the same application.  *(Heretic!  Burn the witch!)*

That's why I created Axos.  Axos is a multi-paradigm library that combines *all* the best async APIs in *one* library, while still being faster and using less memory than any other two async libraries put together.  (In fact, it currently beats any *one* library that isn't Bluebird!)

Using Axos, you can turn generators into promises or Bacon/RxJS-like event streams and properties, and you can can read and write streams or await promises from inside generators.  Whatever your paradigm, Axos supports it, so you can use the best tools for the job at hand -- without adding the overhead of different schedulers and needing to cast or convert objects between libraries.  (That being said, Axos is also designed to support low-overhead interop with other libraries, whether they use callbacks, promises, or something else altogether.)

### How Axos Works

Axos stands for "Asynchronous eXchange of Ordered Signals", and under the hood, it actually uses a completely different paradigm than anything the other guys use.  Specifically designed for maximum performance with V8's JIT, it almost completely avoids the explosion of slow and memory-hungry closures used by most async libraries.

Borrowing some algorithm ideas from the [Trellis](http://peak.telecommunity.com/DevCenter/Trellis) (an FRP library I wrote for Python a few years back), Axos uses only three kinds of objects: Cells, Strategies, and Operators.

Depending on the Strategy, a Cell can act like a promise, an event emitter, a reactive EventStream or Property, or run a generator.  For that matter, Strategies can be used to fully specify arbitrary functional co-ordination patterns (like `map()`, `filter()`, `flatMap()`, `zip()`, etc.), using just a simple flat function without any internal callbacks or per-event objects or closures.

In effect, Axos implements a sort of micro-[CSP](http://en.wikipedia.org/wiki/Communicating_sequential_processes) framework: each Cell represents a tiny "process" with a state and a receiving function that's invoked whenever the process receives a message, and can emit messages to its equivalent of `stdout`.  Which makes it incredibly flexible when it comes to implementing new or specialized co-ordination patterns and async APIs.

But, if all you want to do is use *existing* async constructs, you can just use one (or more) of the provided strategy/wrapper libraries directly...

### Planned API

```javascript
var Promise = require('axos/Promise'),  // promises
    rx      = require('axos/rx'),       // TODO: event streams, properties, etc.
    ado     = require('axos/ado');      // TODO: generators, streams, channels, & queues
```

At least, that's the *plan*.  Right now, Axos is still an in-development proof-of-concept, and doesn't offer any of that stuff, aside from the tiny Promises/A+ implementation you'll find in `"axos/Promise"`.  But hey, I've only been working on this thing for a few days so far...

### Performance Preview

In the meantime, though, here's a little preview benchmark, to show how Axos currently stacks up against everything else, performance-wise, on [Gorgi Kosev's](http://spion.github.io/posts/analysis-generators-and-other-async-patterns-node.html) Doxbee-sequential benchmark:

```
results for 10000 parallel executions, 1 ms per I/O op

file                                     time(ms)  memory(MB)
callbacks-baseline.js                         208       33.41
promises-bluebird-generator.js                248       29.08
promises-pjeby-axos.js                        308       61.71
promises-bluebird.js                          351       50.44
promises-cujojs-when.js                       405       67.60
promises-tildeio-rsvp.js                      500       74.64
callbacks-caolan-async-waterfall.js           611       80.27
promises-lvivski-davy.js                      695      111.13
promises-dfilatov-vow.js                      760      136.60
promises-calvinmetcalf-lie.js                 796      165.22
promises-ecmascript6-native.js               1042      188.24
generators-tj-co.js                          1044      161.27
promises-obvious-kew.js                      1334      257.33
promises-then-promise.js                     1645      236.00
promises-medikoo-deferred.js                 2075      254.26
observables-Reactive-Extensions-RxJS.js      3003      290.55
observables-pozadi-kefir.js                  5846      190.34
promises-kriskowal-q.js                      8277      739.07
observables-caolan-highland.js               9497      559.50
observables-baconjs-bacon.js.js             22097      853.16

Platform info:
Darwin 14.0.0 x64
Node.JS 2.0.2
V8 4.2.77.20
Intel(R) Core(TM) i5-4260U CPU @ 1.40GHz × 4
```

The performance of Axos promises varies a bit by platform and from one run to the next, but is currently almost always within +/-5% of bluebird's speed (and consistently faster than bluebird promises on the platform shown above), within +20% of its memory use, and beating *everything* else -- after only a few days of initial development work.  The reactive wrapper isn't done yet, but I expect it to be about the same speed as Axos's promises...  which means *way* faster than *every other reactive framework*, including Kefir.

The best part of all this, though, is that Axos is truly *generic*: if somebody invents a newer and cooler async API than generators, observables, or promises, Axos should be capable of offering it with world-class performance.

What's the secret?  Careful design for JIT-friendliness, including a 100% monomorphic core design, and never using closures or data objects when they can be replaced by argument-passing.

All that being said, there is no guarantee that the current performance will get any better, or that it won't degrade once I add in some of my planned features.  Fortunately, most of the things I expect to add to the algorithmic core will be on less-frequently used code paths (e.g. BaconJS-style dirty-read prevention), so I don't expect them to slow things down much.
