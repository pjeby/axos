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
            @op = @arg = @sink = @tag = null; @length = 0

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
            return no unless @sink?
            any_tag = arguments.length<2
            return yes if @sink is cell and (any_tag or @tag is tag)
            return no unless @length
            for c, i in this by 2
                return yes if c is cell and (any_tag or this[i+1] is tag)
            return no

        addSink: (cell, tag) ->
            if @sink?
                this[@length++] = cell
                this[@length++] = tag
            else
                @sink = cell
                @tag = tag
            send(cell, tag, @op, @arg) if @op?.isFinal


        removeSink: (cell, tag) ->
            return unless @sink?
            any_tag = arguments.length<2
            out = 0
            out = -2 if @sink is cell and (any_tag or @tag is tag)
            if @length
                for c, i in this by 2
                    continue if c is cell and (any_tag or this[i+1] is tag)
                    if out<0
                        @sink = c; @tag = this[i+1]; out = 0
                    else
                        this[out++] = c; this[out++] = this[i+1];
            if out<0
                @sink = @tag = null
                out = 0
            @length = out

        notify: ->
            op = @op
            arg = @arg
            isFinal = op?.isFinal
            out = 0
            out = -2 if receive(@sink, @tag, op, arg) is NO_MORE or isFinal
            if @length
                for c, i in this by 2
                    if receive(c, this[i+1], op, arg) is NO_MORE or isFinal
                        if out < 0
                            @sink = c; @tag = this[i+1]; out = 0
                        else
                            this[out++] = c; this[out++] = this[i+1]
            if out<0
                @sink = @tag = null
                out = 0
            @length = if isFinal then 0 else out
            return






## Message Sending

    afterIO = process?.nextTick ? setImmediate ? (fn) -> setTimeout(fn, 0)
    mq = []; mq_head = mq_tail = 0
    put = (v) -> mq[mq_tail++] = v
    take = -> v = mq[mq_head]; mq[mq_head++] = null; v

    scheduled = draining = no

    send = (cell, tag, op, arg) ->
        put(cell); put(tag); put(op); put(arg)
        schedule() unless scheduled or draining

    schedule = ->
        axos.afterIO(drain) unless scheduled
        scheduled = yes

    drain = -> scheduled = no; io_send()

    io_send = ->
        if draining
            throw new Error("io_send() must be invoked in a Zalgo-safe way")
        draining = yes
        send(arguments...) if arguments.length
        receive(take(), take(), take(), take()) while mq_head<mq_tail
        mq_head = mq_tail = 0
        draining = no

    current_receiver = null

    receive = (cell, tag, op, arg) ->
        return NO_MORE if cell.op?.isFinal
        old_receiver = current_receiver
        current_receiver = cell
        if (rcv = cell.strategy.onReceive)?
            rcv = rcv.call(cell.state, cell, tag, op, arg)
        else cell.set(op, arg)
        cell.notify() if cell.op? and cell.sink?
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

















