gulp = require('gulp')
coffee = require 'gulp-coffee'
require 'coffee-script/register'

package_name = JSON.parse(require('fs').readFileSync "package.json").name
main = "#{package_name}.*coffee{.md,}"

gulp.task 'build', ->
    gulp.src([main, 'Promise.litcoffee'])
    #.pipe require('gulp-writ')()
    #.on 'error', ->gutil.log
    .pipe coffee()
    #.on 'error', ->gutil.log
    .pipe gulp.dest('.')
    #.pipe filelog()

runTests = (sources, opts={}) ->
    opts.reporter ?= "dot"
    gulp.src sources, buffer: false
    .pipe require('gulp-mocha')(opts)
    .on "data", (->)
    .on 'end', shouldnt = -> delete Object::should
    .on 'error', (err) ->
        console.log err.toString()
        console.log err.stack if err.stack?
        shouldnt()
        @emit 'end'

gulp.task 'test', ['build'], ->
    global.testPromises = no
    runTests 'spec.*coffee{.md,}', reporter: 'spec', #bail: yes

gulp.task 'test-promises', ['build'], TEST_PROMISES = ->
    global.testPromises = yes
    runTests 'spec.*coffee{.md,}', timeout: 200, slow: Infinity, bail: yes

gulp.task 'test-all', ['test'], TEST_PROMISES
    
gulp.task 'default', ['test'], ->
    gulp.watch [main, 'spec.*coffee{.md,}'], ['test']

