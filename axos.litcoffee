# AXOS: Asynchronous eXchange of Ordered Signals

## Strategies

    class Strategy

        constructor: (opts={}) ->
            @kind = opts.kind
            @initState = opts.initState
            @onReceive = opts.onReceive
            @onDispose = opts.onDispose
            for own k of opts
                unless @hasOwnProperty(k)
                    throw new TypeError("invalid Strategy option: #{k}")

        cell: ->
            cell = new Cell(@kind, this)
            if initState = @initState
                cell.state = initState.apply(cell, arguments)
            return cell

        withKind: (kind) ->
            @kind = kind
            return this

















## Cells

    class Cell
        constructor: (@kind, @strategy, @state) ->

## Message Sending

    afterIO = setImmediate ? (fn) -> setTimeout(fn, 0)

    mq = []
    scheduled = draining = no

    send = (cell, tag, op, arg) ->
        mq.push(cell, tag, op, arg)
        schedule() unless scheduled or draining

    schedule = ->
        axos.afterIO(drain) unless scheduled
        scheduled = yes

    drain = ->
        scheduled = no
        io_send()

    io_send = ->
        if draining
            throw new Error("io_send() must be invoked in a Zalgo-safe way")
        draining = yes
        send(arguments...) if arguments.length
        while mq.length
            cell = mq.shift()
            cell.strategy.onReceive?.call(
                cell.state, cell, mq.shift(), mq.shift(), mq.shift()
            )
        draining = no






## Operators

    class Operator
        constructor: (opts = {}) ->
            @isValue = isValue = opts.isValue ? no
            @isError = isError = opts.isError ? !isError
            @isFinal = isFinal = opts.isFinal ? no

            @final   = if @isFinal then this else opts.final
            @nonFinal = if @isFinal then opts.nonFinal else this
            @value    = if @isValue then this else opts.value
            @error    = if @isError then this else opts.error

            @value ?= new Operator({isValue:yes, isError:no, isFinal, error:this})
            @error ?= new Operator({isValue:no, isError:yes, isFinal, value:this})
            @final ?= @value.final.error if isError
            @final ?= new Operator({isValue, isError, isFinal:yes, nonFinal: this})
            @nonFinal ?= @value.nonFinal.error if isError

    ERROR = new Operator()
    VALUE = ERROR.value
    FINAL_ERROR = ERROR.final
    FINAL_VALUE = VALUE.final


















## Error Handling

    throwingFunction = ->

    TRY = (fn) ->
        throwingFunction = fn
        return tryingFunction

    CATCH = {err: null}

    tryingFunction = ->
        try
            return throwingFunction.apply(this, arguments)
        catch e
            CATCH.err = e
            return CATCH


## Exposed API

    module.exports = axos = {
        Strategy, Cell, TRY, CATCH, send, io_send, afterIO
        ERROR, VALUE, FINAL_ERROR, FINAL_VALUE
    }




















