x = 1
y = {}
y.x = -> 3

ok x is 1
ok typeof(y.x) is 'function'
ok y.x instanceof Function
ok y.x() is 3


# The empty function should not cause a syntax error.
->
() ->


# Multiple nested function declarations mixed with implicit calls should not
# cause a syntax error.
(one) -> (two) -> three four, (five) -> six seven, eight, (nine) ->


obj = {
  name: 'Fred'

  bound: ->
    (=> ok(this.name is 'Fred'))()

  unbound: ->
    (-> ok(!this.name?))()

  nested: ->
    (=>
      (=>
        (=>
          ok this.name is 'Fred'
        )()
      )()
    )()
}

obj.unbound()
obj.bound()
obj.nested()


# Python decorator style wrapper that memoizes any function
memoize = (fn) ->
  cache = {}
  self  = this
  (args...) ->
    key = args.toString()
    return cache[key] if cache[key]
    cache[key] = fn.apply(self, args)

Math = {
  Add: (a, b) -> a + b
  AnonymousAdd: ((a, b) -> a + b)
  FastAdd: memoize (a, b) -> a + b
}

ok Math.Add(5, 5) is 10
ok Math.AnonymousAdd(10, 10) is 20
ok Math.FastAdd(20, 20) is 40


# Parens are optional on simple function calls.
ok 100 > 1 if 1 > 0
ok true unless false
ok true for i in [1..3]

okFunc = (f) -> ok(f())
okFunc -> true

# Optional parens can be used in a nested fashion.
call = (func) -> func()

result = call ->
  inner = call ->
    Math.Add(5, 5)

ok result is 10


# More fun with optional parens.
fn = (arg) -> arg

ok fn(fn {prop: 101}).prop is 101


# Multi-blocks with optional parens.
result = fn( ->
  fn ->
    "Wrapped"
)

ok result()() is 'Wrapped'


# And even with strange things like this:
funcs  = [((x) -> x), ((x) -> x * x)]
result = funcs[1] 5

ok result is 25

result = ("hello".slice) 3

ok result is 'lo'


# And with multiple single-line functions on the same line.
func = (x) -> (x) -> (x) -> x
ok func(1)(2)(3) is 3


# Ensure that functions with the same name don't clash with helper functions.
del = -> 5
ok del() is 5

# Ensure that functions can have a trailing comma in their argument list
mult = (x, mids..., y) ->
  x *= n for n in mids
  x *= y

ok mult(1, 2,) is 2
ok mult(1, 2, 3,) is 6
ok mult(10,[1..6]...,) is 7200


# Test for inline functions with parentheses and implicit calls.
combine = (func, num) -> func() * num
result  = combine (-> 1 + 2), 3

ok result is 9


# Test for calls/parens/multiline-chains.
f = (x) -> x
result = (f 1).toString()
  .length

ok result is 1


# Test implicit calls in functions in parens:
result = ((val) ->
  [].push val
  val
)(10)

ok result is 10


# More paren compilation tests:
reverse = (obj) -> obj.reverse()
ok reverse([1, 2].concat 3).join(' ') is '3 2 1'

# Passing multiple functions without paren-wrapping is legal, and should compile.
sum = (one, two) -> one() + two()
result = sum ->
  7 + 9
, ->
  1 + 3

ok result is 20


# Implicit call with a trailing if statement as a param.
func = -> arguments[1]
result = func 'one', if false then 100 else 13
ok result is 13


# Test more function passing:
result = sum( ->
  1 + 2
, ->
  2 + 1
)
ok result is 6

sum = (a, b) -> a + b
result = sum(1
, 2)

ok result is 3


# This is a crazy one.
x = (obj, func) -> func obj
ident = (x) -> x

result = x {one: ident 1}, (obj) ->
  inner = ident(obj)
  ident inner

ok result.one is 1


# Assignment to a Object.prototype-named variable should not leak to outer scope.
(->
  constructor = 'word'
)()

ok constructor isnt 'word'


# Trying an implicit object call with a trailing function.
a = null
meth = (arg, obj, func) -> a = [obj.a, arg, func()].join ' '

meth 'apple', b: 1, a: 13, ->
  'orange'

ok a is '13 apple orange'


# Ensure that empty functions don't return mistaken values.
obj =
  func: (@param, @rest...) ->

ok obj.func(101, 102, 103, 104) is undefined
ok obj.param is 101
ok obj.rest.join(' ') is '102 103 104'
