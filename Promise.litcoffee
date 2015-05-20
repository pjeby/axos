# Axos Promises

    { Cell, Strategy, NO_MORE, FINAL_VALUE, FINAL_ERROR, TRY, CATCH, send,
      io_send
    } = axos = require('./')

    empty = new Strategy()
    Cell::then = (onF, onR) -> promiseResolver.cell(this, onF, onR)

    module.exports = axos.Promise = class Promise

        constructor: (init = empty.cell()) ->
            if init instanceof Cell
                @__cell__ = init
            else if typeof init is "function"
                runInitializer init, null, @__cell__ = empty.cell(), 1
            else
                throw new TypeError(
                    "Promise must be created from cell or function"
                )

        then: (onF, onR) -> new Promise promiseResolver.cell(@__cell__, onF, onR)

        @deferred: ->
            d = {}
            d.promise = empty.cell()
            runInitializer ( (res, rej) ->
                d.resolve = res
                d.reject = rej), null, d.promise, 1
            return d
        
        @promisify: (fn) -> ->
            cell = empty.cell()
            args = Array(arguments.length + 1)
            args[i] = a for a, i in arguments
            args[arguments.length] = (e, v) ->
                if e then send(cell, 1, FINAL_ERROR, e)
                else send(cell, 1, FINAL_VALUE, v)
            fn.apply(this, args)
            return cell

    promiseResolver = new Strategy(

        onReceive: (cell, tag, op, arg) ->
            if typeof tag is "function"
                return cell.abort(arg) if op.isError
                arg = TRY1(tag, arg)
                return cell.abort(CATCH.err) if arg is CATCH
                op = FINAL_VALUE
            else if typeof tag is "object"
                tag = if op.isError then tag.onR else tag.onF
                if typeof tag is "function"
                    arg = TRY1(tag, arg)
                    return cell.abort(CATCH.err) if arg is CATCH
                    op = FINAL_VALUE
            # XXX fast path state set if set via node-callback    
            # promise resolution procedure step
            return cell.abort(arg) if op.isError
            arg = arg.__cell__ if arg instanceof Promise
            while arg instanceof Cell
                if arg is cell
                    return cell.abort(
                        new TypeError("Can't resolve promise to itself")
                    )
                else
                    unless arg.op?
                        arg.addSink(cell, 0)
                        return NO_MORE
                    {op, arg} = arg
                    return cell.abort(arg) if op.isError
                    arg = arg.__cell__ if arg instanceof Promise

            if typeof arg in ["object", "function"] and arg isnt null
                if (thenF = TRY1(getThen, arg)) is CATCH
                    return cell.abort(CATCH.err)
                if typeof thenF is "function"
                    runInitializer(thenF, arg, cell, 0)
                    return NO_MORE

            # Not a promise, just return it
            return cell.finish(arg)

        initState: (other, onF, onR) ->
            if other instanceof Cell
                if typeof onR isnt "function"
                    if typeof onF isnt "function"
                        tag = 0
                    else
                        tag = onF
                else
                    tag = {onF, onR}
                other.addSink(this, tag) 
            return 
    )

    getThen = (x) -> x.then
    
    runInitializer = (init, rcv, cell, step) ->

        resolve = (v) -> unless cell is null
            send(cell, step, FINAL_VALUE, v); cell = null
        reject  = (e) -> unless cell is null
            send(cell, step, FINAL_ERROR, e); cell = null

        if TRY(init).call(rcv, resolve, reject) is CATCH and cell isnt null
            cell.abort(CATCH.err)
        return


    TRY1 = (cb, arg) ->
        try return cb(arg)
        catch e
            CATCH.err = e
            return CATCH









