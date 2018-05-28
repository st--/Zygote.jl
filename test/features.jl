using Zygote, Base.Test
using Zygote: gradient

bool = true
f(x) = bool ? 2x : x

struct Foo{T}
  a::T
  b::T
end

@testset "Features" begin

y, back = forward(identity, 1)
dx = back(2)
@test y == 1
@test dx == (2,)

mul(a, b) = a*b
y, back = forward(mul, 2, 3)
dx = back(4)
@test y == 6
@test dx == (12, 8)

@test gradient(mul, 2, 3) == (3, 2)

y, back = forward(f, 3)
dx = back(4)
@test y == 6
dx == (8,)

bool = false

y, back = forward(f, 3)
dx = back(4)
@test y == 3
@test getindex.(dx) == (4,)

y, back = forward(broadcast, *, [1,2,3], [4,5,6])
dxs = back([1,1,1])
@test y == [4, 10, 18]
@test dxs == (nothing, [4, 5, 6], [1, 2, 3])

function pow(x, n)
  r = 1
  for _ = 1:n
    r *= x
  end
  return r
end

@test gradient(pow, 2, 3) == (12, nothing)

@test gradient(x -> 1, 2) == (nothing,)

@test gradient(t -> t[1]*t[2], (2, 3)) == ((3, 2),)

@test gradient(x -> x.re, 2+3im) == ((re = 1, im = nothing),)

@test gradient(x -> x.re*x.im, 2+3im) == ((re = 3, im = 2),)

function f(a, b)
  c = Foo(a, b)
  c.a * c.b
end

@test gradient(f, 2, 3) == (3, 2)

function f(a, b)
  c = (a, b)
  c[1] * c[2]
end

@test gradient(f, 2, 3) == (3, 2)

function f(x, y)
  f = z -> x * z
  f(y)
end

@test gradient(f, 2, 3) == (3, 2)

gradient((a, b...) -> *(a, b...), 2, 3)

function mysum(xs)
  s = 0
  for x in xs
    s += x
  end
  return s
end

@test gradient(mysum, (1,2,3)) == ((1,1,1),)

function f(a, b)
  xs = [a, b]
  xs[1] * xs[2]
end

@test gradient(f, 2, 3) == (3, 2)

end