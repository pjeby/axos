{expect, should} = chai = require 'chai'
should = should()
chai.use require 'sinon-chai'

expect_fn = (item) -> expect(item).to.exist.and.be.a('function')
{spy} = sinon = require 'sinon'

spy.named = (name, args...) ->
    s = if this is spy then spy(args...) else this
    s.displayName = name
    return s

failSafe = (done, fn) -> ->
    try fn.apply(this, arguments)
    catch e then done(e)

Promise = global.Promise ? require 'bluebird'

promised = (fn) -> -> new Promise (res, rej) =>
    try fn.call this, (e, v) -> if e then rej(e) else res(v)
    catch e then rej(e)

{
    Strategy, Cell, KIND_RESULT, TRY, CATCH, send, io_send, afterIO,
    VALUE, ERROR, FINAL_VALUE, FINAL_ERROR
} = axos = require './'















describe "An axos.Strategy instance", ->

  describe "has the same properties as the options used to create it", ->
    for prop in 'onReceive initState onDispose kind'.split(' ')
        it '.'+prop, ->
            s = new Strategy({"#{prop}": t={}})
            expect(s[prop]).to.exist.and.equal(t)

  it "throws if created with invalid properties", ->
      expect(-> new Strategy(x: 'y')).to.throw(/invalid Strategy option/)

  it "has the same shape regardless of the options object's shape", ->
    k = Object.keys(new Strategy())
    for prop in 'onReceive initState onDispose kind'.split(' ')
        s = new Strategy({"#{prop}": null})
        expect(Object.keys(s)).to.deep.equal(k)

  it "has a .withKind(kind) that sets .kind and returns the strategy", ->
      s = new Strategy(kind: 99)
      expect(s.kind).to.equal(99)
      expect(s.withKind(42)).to.equal(s)
      expect(s.kind).to.equal(42)

  it "has a .cell(args...) method that returns a new Cell()", ->
      s = new Strategy()
      expect(s.cell()).to.be.instanceOf(Cell)

  it "passes cell-creation arguments (and cell context) to its .initState()", ->
      s = new Strategy(initState: spy.named('initState'))
      c = s.cell(1, 2, 3)
      expect(s.initState).to.have.been.calledWithExactly(1, 2, 3)
      expect(s.initState).to.have.been.calledOn(c)

  it "uses the return from .initState() as the Cell .state", ->
      state = {}
      s = new Strategy(initState: -> state)
      expect(s.cell().state).to.equal(state)




describe "axos.Cell instances", ->

  describe "when created via new Cell(kind, strategy, state)", ->
    it "have the specified kind, strategy, and state", ->
        c = new Cell(k=99, s=new Strategy(), st={})
        expect(c.kind).to.equal(99)
        expect(c.strategy).to.equal(s)
        expect(c.state).to.equal(st)

    it "default to being of KIND_RESULT if unspecified", ->
        expect(new Cell().kind).to.equal(KIND_RESULT)

    it "default to a null state if unspecified", ->
        expect(new Cell().state).to.not.exist

    it "default to a default strategy if none given"

























  describe "have a .set() method that", ->

    it "errors if called outside .onReceive() or .onRecalc()", promised (done) ->
        c = new Strategy(
            onReceive: failSafe done, (c) -> c.set(1, 2)
        ).cell()
        expect(-> c.set(1,2)).to.throw(/must be called from/)
        io_send(c, 3, 4, 5)
        expect(-> c.set(1,2)).to.throw(/must be called from/)
        done()

    it "sets the .op and .arg", promised (done) ->
        c = new Strategy(
                onReceive: failSafe done, (c) ->
                    c.set(1,2)
                    expect(c.op).to.equal(1)
                    expect(c.arg).to.equal(2)
                    done()
            ).cell()
        io_send(c,3,4,5)

    it "has setValue(), setError(), finish() and abort() shortcuts", ->
        c = new Strategy().cell()
        s = spy.named('set', c, 'set')
        expect(-> c.setValue(1)).to.throw(/must be called from/)
        expect(s).to.have.been.calledWithExactly(VALUE, 1)
        s.reset()
        expect(-> c.setError(2)).to.throw(/must be called from/)
        expect(s).to.have.been.calledWithExactly(ERROR, 2)
        s.reset()
        expect(-> c.finish(3)).to.throw(/must be called from/)
        expect(s).to.have.been.calledWithExactly(FINAL_VALUE, 3)
        s.reset()
        expect(-> c.abort(4)).to.throw(/must be called from/)
        expect(s).to.have.been.calledWithExactly(FINAL_ERROR, 4)
        s.restore()





    it "is a no-op if a final op has previously been set", ->
        s = new Strategy(onReceive: (cell, tag, op, arg) -> cell.set(op, arg))

        c = s.cell()
        io_send(c, 1, ERROR, 2)
        expect(c.op).to.equal(ERROR)
        expect(c.arg).to.equal(2)

        for [op, arg] in [[FINAL_VALUE, 3], [ERROR, 4], [VALUE, 5]]
            io_send(c, 1, op, arg)
            expect(c.op).to.equal(FINAL_VALUE)
            expect(c.arg).to.equal(3)

        c = s.cell()
        io_send(c, 1, VALUE, 1)
        expect(c.op).to.equal(VALUE)
        expect(c.arg).to.equal(1)

        for [op, arg] in [[FINAL_ERROR, 2], [VALUE, 3], [ERROR, 4]]
            io_send(c, 1, op, arg)
            expect(c.op).to.equal(FINAL_ERROR)
            expect(c.arg).to.equal(2)


    it "sends *last* op and arg to the cell's subscribers"
















  describe "have a .triggerRecalc() method that", ->
    it "errors if called outside .onReceive()"
    it "calls .onRecalc(cell) on the state once, after onReceive() returns"

  describe "have an .addSink(otherCell, tag) method that", ->
    it "subscribes otherCell to receive messages, with the given tag"
    it "can add multiple sinks to the same source"

  describe "when subscribed to, drop a subscription when", ->
    it "the receiver returns NO_MORE"
    it "the receiver sets a final value/state"
    it "the subscription is canceled via .removeSink(cell [, tag])"
    it "the subscriber is closed"

  describe "if of KIND_VALUE or KIND_RESULT", ->
    it "send their \"current\" value to subscribed cells"

























describe "axos.send()", ->

  describe "invokes the onReceive() of the targeted cells", ->

    beforeEach ->
        @c = new Strategy(onReceive: @spy = spy.named('onReceive')).cell()

    it "in the same order as the calls", promised (done) ->
        send(@c, 1, 2, 3)
        send(@c, 4, 5, 6)
        afterIO failSafe done, =>
            expect(@spy.firstCall).to.have.been.calledWithExactly(@c, 1, 2, 3)
            expect(@spy.secondCall).to.have.been.calledWithExactly(@c, 4, 5, 6)
            done()

    it "after send()'s caller has exited", ->
        send(@c, 1, 2, 3)
        expect(@spy).to.not.have.been.called

    it "in the same event loop pass", promised (done) ->
        s = spy.named('afterIO', axos, 'afterIO')
        send(@c, 1, 2, 3)
        afterIO failSafe done, =>
            s.restore() # remove the spy
            expect(s).to.have.been.calledOnce
            expect(@spy).to.have.been.called
            expect(@spy.firstCall).to.have.been.calledWithExactly(@c, 1, 2, 3)
            expect(@spy.secondCall).to.have.been.calledWithExactly(@c, 4, 5, 6)
            done()
        send(@c, 4, 5, 6)
        expect(s).to.have.been.calledOnce










  describe "when called from within onReceive, invokes other onReceives", ->

    beforeEach ->
        @s1 = spy.named 'forwarder', (cell, tag, op, arg) => send(@c2, tag, op, arg)
        @c1 = new Strategy(onReceive: @s1).cell()
        @c2 = new Strategy(onReceive: @s2 = spy.named('receiver')).cell()

    it "in the same order as the calls, after caller exits, in same pass", promised (done) ->
        s = spy.named('afterIO', axos, 'afterIO')
        send(@c1, 1, 2, 3)
        expect(@s1).to.not.have.been.called
        expect(@s2).to.not.have.been.called
        afterIO failSafe done, =>
            s.restore()
            expect(s).to.have.been.calledOnce
            expect(@s1.firstCall).to.have.been.calledWithExactly(@c1, 1, 2, 3)
            expect(@s1.secondCall).to.have.been.calledWithExactly(@c1, 4, 5, 6)
            expect(@s2.firstCall).to.have.been.calledWithExactly(@c2, 1, 2, 3)
            expect(@s2.secondCall).to.have.been.calledWithExactly(@c2, 4, 5, 6)
            expect(@s2.firstCall).to.have.been.calledAfter(@s1.secondCall)
            done()
        send(@c1, 4, 5, 6)
        expect(s).to.have.been.calledOnce


















describe "axos.io_send()", ->

    beforeEach ->
        @c = new Strategy(onReceive: @spy = spy.named('onReceive')).cell()

    it "throws if called from inside send() processing", promised (done) ->
        s = spy.named 'onReceive', failSafe done, =>
            expect(io_send).throws(/Zalgo/)
            done()
        c = new Strategy(onReceive: s).cell()
        send(c, 1, 2, 3)

    it "flushes pending send() calls", ->
        send(@c, 1, 2, 3)
        expect(@spy).to.not.have.been.called
        io_send()
        expect(@spy).to.have.been.calledWithExactly(@c, 1, 2, 3)

    it "doesn't affect an already-scheduled draining", ->
        s = spy.named('afterIO', axos, 'afterIO')
        send(@c, 1, 2, 3)
        expect(s).to.have.been.calledOnce
        io_send()
        send(@c, 4, 5, 6)
        expect(s).to.have.been.calledOnce
        s.restore()

    it "accepts the same arguments as send(), executing them in order", ->
        send(@c, 1, 2, 3)
        io_send(@c, 4, 5, 6)
        expect(@spy.firstCall).to.have.been.calledWithExactly(@c, 1, 2, 3)
        expect(@spy.secondCall).to.have.been.calledWithExactly(@c, 4, 5, 6)









describe "Operators", ->

    it "should have appropriate .isError/.isValue/.isFinal properties", ->
        expect(VALUE.isValue).to.be.true
        expect(ERROR.isError).to.be.true
        expect(FINAL_VALUE.isValue).to.be.true
        expect(FINAL_ERROR.isError).to.be.true

        expect(VALUE.isError).to.be.false
        expect(ERROR.isValue).to.be.false
        expect(FINAL_VALUE.isError).to.be.false
        expect(FINAL_ERROR.isValue).to.be.false

        expect(VALUE.isFinal).to.be.false
        expect(ERROR.isFinal).to.be.false
        expect(FINAL_VALUE.isFinal).to.be.true
        expect(FINAL_ERROR.isFinal).to.be.true

    it "should have symmetric .final/.nonFinal properties", ->
        expect(VALUE).to.equal(FINAL_VALUE.nonFinal)
        expect(ERROR).to.equal(FINAL_ERROR.nonFinal)
        expect(FINAL_VALUE).to.equal(VALUE.final)
        expect(FINAL_ERROR).to.equal(ERROR.final)

    it "should have symmetric .value/.error properties", ->
        expect(VALUE).to.equal(ERROR.value)
        expect(ERROR).to.equal(VALUE.error)
        expect(FINAL_VALUE).to.equal(FINAL_ERROR.value)
        expect(FINAL_ERROR).to.equal(FINAL_VALUE.error)












describe "axos.TRY(fn) returns a wrapper function that", ->

    it "is the same function each time", ->
        x = TRY(f1 = ->)
        y = TRY(f2 = ->)
        expect(x).to.exist.and.equal(y)

    it "invokes the wrapped function with the same context and arguments", ->
        s1 = spy.named('s1')
        TRY(s1).call(ctx = {}, 1, 2, 3)
        s1.should.have.been.calledWithExactly(1,2,3)
        s1.should.have.been.calledOn(ctx)

    it "returns the result of invoking fn", ->
        expect(TRY(-> 42)()).to.exist.and.equal(42)

    it "returns axos.CATCH if there's an error", ->
        expect(TRY(-> throw new Error)()).to.equal(CATCH)

    it "sets axos.CATCH.err to the error thrown", ->
        err = new Error()
        expect(TRY(-> throw err)().err).to.equal(err)



















