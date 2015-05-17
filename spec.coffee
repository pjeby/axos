{expect, should} = chai = require 'chai'
should = should()
chai.use require 'sinon-chai'

expect_fn = (item) -> expect(item).to.exist.and.be.a('function')
{spy} = sinon = require 'sinon'

spy.named = (name, args...) ->
    s = if this is spy then spy(args...) else this
    s.displayName = name
    return s


{
    Strategy, Cell, KIND_RESULT, TRY, CATCH, send, msg, afterIO
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

  describe "have a .link(tag, topic) method that", ->
    it "subscribes to another cell, using the given tag"

  describe "when subscribed to, drop a subscription when", ->
    it "the receiver returns false"
    it "the receiver returns msg(*, *, false)"
    it "the subscription is canceled via .cancel(sink [, tag])"
    it "the subscriber is closed"
    it "the cell is closed"

  describe "if of KIND_VALUE or KIND_RESULT", ->
    it "send their \"current\" value to subscribed cells"












describe "axos.send()", ->

  describe "invokes the onReceive() of the targeted cells", ->

    beforeEach ->
        @c = new Strategy(onReceive: @spy = spy.named('onReceive')).cell()

    it "in the same order as the calls", (done) ->
        send(@c, 1, 2, 3)
        send(@c, 4, 5, 6)
        afterIO =>
            try
                expect(@spy.firstCall).to.have.been.calledWithExactly(@c, 1, 2, 3)
                expect(@spy.secondCall).to.have.been.calledWithExactly(@c, 4, 5, 6)
            catch e
                return done(e)
            done()
        return

    it "after send()'s caller has exited", ->
        send(@c, 1, 2, 3)
        expect(@spy).to.not.have.been.called

    it "in the same event loop pass", (done) ->
        s = spy.named('afterIO', axos, 'afterIO')
        send(@c, 1, 2, 3)
        afterIO =>
            s.restore() # remove the spy
            try
                expect(s).to.have.been.calledOnce
                expect(@spy).to.have.been.called
                expect(@spy.firstCall).to.have.been.calledWithExactly(@c, 1, 2, 3)
                expect(@spy.secondCall).to.have.been.calledWithExactly(@c, 4, 5, 6)
            catch e
                console.log e
                return done(e)
            done()
        send(@c, 4, 5, 6)
        expect(s).to.have.been.calledOnce


  describe "when called from within onReceive, invokes other onReceives", ->

    beforeEach ->
        @s1 = spy.named 'forwarder', (cell, tag, op, arg) => send(@c2, tag, op, arg)
        @c1 = new Strategy(onReceive: @s1).cell()
        @c2 = new Strategy(onReceive: @s2 = spy.named('receiver')).cell()

    it "in the same order as the calls, after caller exits, in same pass", (done) ->
        s = spy.named('afterIO', axos, 'afterIO')
        send(@c1, 1, 2, 3)
        expect(@s1).to.not.have.been.called
        expect(@s2).to.not.have.been.called
        afterIO =>
            try
                s.restore()
                expect(s).to.have.been.calledOnce
                expect(@s1.firstCall).to.have.been.calledWithExactly(@c1, 1, 2, 3)
                expect(@s1.secondCall).to.have.been.calledWithExactly(@c1, 4, 5, 6)
                expect(@s2.firstCall).to.have.been.calledWithExactly(@c2, 1, 2, 3)
                expect(@s2.secondCall).to.have.been.calledWithExactly(@c2, 4, 5, 6)
                expect(@s2.firstCall).to.have.been.calledAfter(@s1.secondCall)
            catch e
                console.log e
                return done(e)
            done()
        send(@c1, 4, 5, 6)
        expect(s).to.have.been.calledOnce
        return













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



















