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
        constructor: (@kind, @strategy, @state) -> @op = @arg = @sinks = null

        setValue: (val) -> @set(VALUE, val)
        setError: (err) -> @set(ERROR, err)
        finish: (val) -> @set(FINAL_VALUE, val)
        abort:  (err) -> @set(FINAL_ERROR, err)

        set: (op, arg) ->
            throw new TypeError(
                "set() must be called from onReceive() or onRecalc()"
            ) unless this is current_receiver
            return if @op?.isFinal
            @op = op
            @arg = arg
            return

        hasSink: (cell, tag) ->
            return no unless (sinks = @sinks)?.length
            any_tag = arguments.length<2
            for c, i in sinks = (@sinks ? []) by 2
                if c is cell and (any_tag or sinks[i+1] is tag)
                    return yes
            return no

        addSink: (cell, tag) ->
            (@sinks ?= []).push(cell, tag)
            send(cell, tag, @op, @arg) if @op?.isFinal

        removeSink: (cell, tag) ->
            return unless (sinks = @sinks)?.length
            out = 0
            any_tag = arguments.length<2
            for c, i in sinks by 2
                continue if c is cell and (any_tag or sinks[i+1] is tag)                    
                sinks[out++] = c
                sinks[out++] = sinks[i+1]
            sinks.length = out

        notify: ->
            return unless (sinks = @sinks)?.length
            op = @op
            arg = @arg
            out = 0
            for c, i in sinks by 2
                unless receive(c, sinks[i+1], op, arg) is NO_MORE
                    sinks[out++] = c
                    sinks[out++] = sinks[i+1]

            sinks.length = if op?.isFinal then 0 else out
            return





























## Message Sending

    afterIO = process?.nextTick ? setImmediate ? (fn) -> setTimeout(fn, 0)

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
        receive(mq.shift(), mq.shift(), mq.shift(), mq.shift()) while mq.length
        draining = no

    current_receiver = null

    receive = (cell, tag, op, arg) ->
        return NO_MORE if cell.op?.isFinal
        old_receiver = current_receiver
        current_receiver = cell
        if (rcv = cell.strategy.onReceive)?
            rcv = rcv.call(cell.state, cell, tag, op, arg)
        else
            cell.set(op, arg)
        cell.notify() if cell.op?
        current_receiver = old_receiver
        return rcv

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

    NO_MORE = {}
















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
        ERROR, VALUE, FINAL_ERROR, FINAL_VALUE, NO_MORE
    }

















