using Diffractor
using Diffractor: var"'", ∂⃖
using ChainRules
using ChainRules: Zero
using Symbolics

using Test

# Unit tests
function tup2(f)
    a, b = ∂⃖{2}()(f, 1)
    c, d = b((2,))
    e, f = d(Zero(), 3)
    f((4,))
end

@test tup2(tuple) == (Zero(), 4)

my_tuple(args...) = args
ChainRules.rrule(::typeof(my_tuple), args...) = args, Δ->Core.tuple(NO_FIELDS, Δ...)
@test tup2(my_tuple) == (Zero(), 4)

# Check characteristic of exp rule
@variables ω α β γ δ ϵ ζ η
(x1, c1) = ∂⃖{3}()(exp, ω)
@test simplify(x1 == exp(ω)).val
((_, x2), c2) = c1(α)
@test simplify(x2 == α*exp(ω)).val
(x3, c3) = c2(Zero(), β)
@test simplify(x3 == β*exp(ω)).val
((_, x4), c4) = c3(γ)
@test simplify(x4 == exp(ω)*(γ + (α*β))).val
(x5, c5) = c4(Zero(), δ)
@test simplify(x5 == δ*exp(ω)).val
((_, x6), c6) = c5(ϵ)
@test simplify(x6 == ϵ*exp(ω) + α*δ*exp(ω)).val
(x7, c7) = c6(Zero(), ζ)
@test simplify(x7 == ζ*exp(ω) + β*δ*exp(ω)).val
(_, x8) = c7(η)
@test simplify(x8 == (η + (α*ζ) + (β*ϵ) + (δ*(γ + (α*β))))*exp(ω)).val

# Integration tests
@test @inferred(sin'(1.0)) == cos(1.0)
@test @inferred(sin''(1.0)) == -sin(1.0)
@test sin'''(1.0) == -cos(1.0)
@test sin''''(1.0) == sin(1.0)
@test sin'''''(1.0) == cos(1.0)
@test sin''''''(1.0) == -sin(1.0)

f_getfield(x) = getfield((x,), 1)
@test f_getfield'(1) == 1
@test f_getfield''(1) == 0
@test f_getfield'''(1) == 0