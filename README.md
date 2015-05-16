# High-performance Multi-Paradigm Asynchronous Programming

Promises.  Observables.  EventStreams.  FRP.  Generators.  Callbacks and thunks.  RxJs, Kefir, and Bacon.  What's *really* the best way to write async code?

Who cares?  Axos does all of it, faster and using less memory.  Turn Bacon-like streams into generators, generators into promises, or do it all the other way around.  Axos has you covered.

Axos stands for "Asynchronous eXchange of Ordered Signals", and under the hood, it's actually a completely different paradigm than anything the other guys use.  Specifically designed for maximum performance with V8's JIT, it almost completely avoids the explosion of slow and memory-hungry closures used by most async libraries.

qInternally, Axos uses only three kinds of objects, Cells, Strategies, and Links.  Depending on the Strategy, a Cell can act like a promise, an event emitter, a reactive EventStream or Property, or run a generator.  For that matter, Strategies can be used to fully specify arbitrary functional co-ordination patterns (like `map()`, `filter()`, `flatMap()`, `zip()`, etc.), using just a simple flat function without any internal callbacks or per-event objects or closures.

But if all you want to do is use existing async constructs, you can just use one (or more) of the provided strategy/wrapper libraries directly:

    var Promise = require('axos/Promise'),  // promises
        rx      = require('axos/rx'),       // event streams, properties, etc.
        ado     = require('axos/ado');      // generators, streams, channels, & queues

(At least, that's the *plan*.  Right now, Axos is still in development, and doesn't offer any of that stuff, not to mention a complete lack of documentation.  Watch this space for future developments...  no pun intended.)
