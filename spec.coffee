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

describe "Axos", ->

    it "is a function", ->
        expect_fn(axos)

