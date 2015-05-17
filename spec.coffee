{expect, should} = chai = require 'chai'
should = should()
chai.use require 'sinon-chai'

axos = require './'

expect_fn = (item) -> expect(item).to.exist.and.be.a('function')
{spy} = sinon = require 'sinon'

spy.named = (name, args...) ->
    s = if this is spy then spy(args...) else this
    s.displayName = name
    return s




























describe "An axos.Strategy instance", ->
  it "has the same properties as the options used to create it"
  it "throws if created with invalid properties"
  it "can have an arbitrary .create() method"
  it "has properties in the same order regardless of the input object order"
  it "has a .cell(args...) method that returns a new Cell()"
  it "has a .cellOfKind(kind, args...) that returns a new Cell of that kind"
  it "passes cell-creation arguments to its .initState()"
  it "uses the return from .initState() as the Cell .state"

describe "axos.Cell instances", ->

  it "can be created with new Cell(kind, strategy, state)"

  describe "when newly created", ->
    it "have the specified kind and strategy"
    it "pass any extra constructor arguments to the strategy's .initState()"
    it "use the return from .initState() as their .state"
    it "default to being of KIND_RESULT if unspecified"
    it "default to a null state if no .initState()"
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
    it "in the same order as the calls"
    it "after send()'s caller has exited"
    it "in the same event loop pass"
  describe "when called from within onReceive, invokes other onReceives", ->
    it "in the same order as the calls"
    it "after send()'s caller has exited"
    it "in the same event loop pass"

describe "axos.TRY(fn) returns a wrapper function that", ->
    it "is the same function each time"
    it "invokes the wrapped function with the same context and arguments"
    it "returns the result of invoking fn"
    it "returns axos.CATCH if there's an error"
    it "sets axos.CATCH.err to the error thrown"

























