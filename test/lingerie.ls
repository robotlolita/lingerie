# -- Dependencies ------------------------------------------------------
assert = require 'assert'
claire = require 'claire'
l      = require '../lib'

# -- Aliases -----------------------------------------------------------
o         = it
equals    = assert.strict-equal
ok        = assert.ok

{for-all, sized} = claire
{Negative, Any, Num, Int, Str, Id, AlphaStr} = claire.data


# -- Constants ---------------------------------------------------------
ws = '\x09\x0A\x0B\x0C\x0D\x20\xA0\u1680\u180E\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A\u202F\u205F\u3000\u2028\u2029\uFEFF'


# -- Helpers -----------------------------------------------------------
capitals = (a) -> "#{a.char-at 0 .to-upper-case!}#{a.to-lower-case!slice 1}"


# -- Tests -------------------------------------------------------------
describe 'λ repeat' ->
  o 'Should return an empty string for `times <= 0`' do
     v = for-all Str, Negative
         .satisfy (a, b) -> ((l.repeat 0, a) is '') and ((l.repeat b, a) is '')
         .as-test!

  o 'Should repeat the given String `times` for `times > 0`' do
     for-all Str
     .satisfy (a) -> (l.repeat 2, a) is "#a#a"
     .as-test!


describe 'λ concatenate' ->
  o 'Should handle gracefully non-strings.' do
     for-all Any, Any
     .satisfy (a, b) -> (l.concatenate a, b) is "#a#b"
     .as-test!

  o 'Should return all arguments concatenated.' do
     for-all Str, Str, Str, Str
     .satisfy (a, b, c, d) -> (l.concatenate a,b,c,d) is "#a#b#c#d"
     .as-test!       


xdescribe 'λ trim' ->
  o 'Should remove whitespace from both sides.' do
     for-all Str
     .satisfy (a) -> (l.trim "#ws#a#ws") is a
     .as-test!


xdescribe 'λ trim-left' ->
  o 'Should remove whitespace only at the beginning.' do
     for-all Str
     .satisfy (a) -> (l.trim-left "#ws#a#ws") is "#a#ws"
     .as-test!


xdescribe 'λ trim-right' ->
  o 'Should remove whitespace only at the end.' do
     for-all Str
     .satisfy (a) -> (l.trim-right "#ws#a#ws") is "#ws#a"
     .as-test!


describe 'λ starts-with' ->
  o 'Should return true if `what` is at the beginning of the string.' do
     for-all Id, Id
     .given (isnt)
     .satisfy (a, b) -> l.starts-with a, "#a#b"
     .as-test!

  o 'Should return false if `what` is not at the beginning of the string.' do
     for-all Id
     .given (isnt)
     .satisfy (a) -> not (l.starts-with '0', a)
     .as-test!


describe 'λ ends-with' ->
  o 'Should return true if `what` is at the end of the string.' do
     for-all Id, Id
     .given (isnt)
     .satisfy (a, b) -> l.ends-with b, "#a#b"
     .as-test!

  o 'Should return false if `what` is not at the end of the string.' do
     for-all Id
     .given (isnt)
     .satisfy (a) -> not (l.ends-with '→', a)
     .as-test!


describe 'λ is-empty' ->
  o 'Should return true if the string is empty' ->
     ok (l.is-empty '')

  o 'Should return false if the string is not empty' do
     for-all Str
     .given (.length > 0)
     .satisfy (a) -> not (l.is-empty a)
     .as-test!


describe 'λ has' ->
  o 'Should return true if `what` is contained in the string.' do
     for-all (sized (->10), Str), (sized (->10), Str)
     .satisfy (a, b) -> l.has a, "#a#b"
     .as-test!

  o 'Should differentiate casing.' do
     for-all AlphaStr, AlphaStr
     .given (a, b) -> (a isnt '') && (b isnt '')
     .satisfy (a, b) -> not (l.has a.to-upper-case!, "#a#b".to-lower-case!)
     .as-test!

  o 'Should return false if `what` is not contained in the string.' do
     for-all AlphaStr, AlphaStr
     .given (a, b) -> (a isnt '') && (b isnt '')
     .satisfy (a, b) -> not (l.has a.to-lower-case!, b.to-upper-case!)
     .as-test!


describe 'λ upcase' ->
  o 'Should return the string converted to upper case' do
     for-all Str
     .satisfy (a) -> (l.upcase a) is a.to-upper-case!
     .as-test!


describe 'λ downcase' ->
  o 'Should return the string converted to lower case.' do
     for-all Str
     .satisfy (a) -> (l.downcase a) is a.to-lower-case!
     .as-test!


describe 'λ capitalise' ->
  o 'Should capitalise only the first word, downcase the rest.' do
     for-all AlphaStr
     .satisfy (a) -> (l.capitalise "#a #a") is "#{capitals a} #{a.to-lower-case!}"
     .as-test!


describe 'λ capitalise-words' ->
  o 'Should capitalise all words.' do
     for-all AlphaStr
     .satisfy (a) -> (l.capitalise-words "#a #a #a") is "#{capitals a} #{capitals a} #{capitals a}"
     .as-test!


describe 'λ dasherise' ->
  o 'Should replace all whitespace by dashes.' do
     for-all Id, Id, Id
     .satisfy (a, b, c) -> (l.dasherise " #a #b #c ") is "#{a}-#{b}-#{c}"
     .as-test!
     

describe 'λ camelise' ->
  o 'Should replace all whitespace separating words by the next letter upercased.' do
     for-all AlphaStr
     .given (.length > 0)
     .satisfy (a) -> (l.camelise "#a #a #a") is "#{a.to-lower-case!}#{capitals a}#{capitals a}"
     .as-test!

  o 'Should replace all hyphens separatig words by the next letter upercased.' do
     for-all AlphaStr
     .given (.length > 0)
     .satisfy (a) -> (l.camelise "#{a}-#{a}-#{a}") is "#{a.to-lower-case!}#{capitals a}#{capitals a}"
     .as-test!

  o 'Should replace all underscores by the next letter uppercased.' do
     for-all AlphaStr
     .given (.length > 0)
     .satisfy (a) -> (l.camelise "#{a}_#{a}_#{a}") is "#{a.to-lower-case!}#{capitals a}#{capitals a}"
     .as-test!


describe 'λ first' ->
  o 'Should return an empty string for empty strings' ->
     equals '', (l.first '')

  o 'Should return the first character in the string.' do
     for-all Str
     .satisfy (a) -> (l.first a) is a.char-at 0
     .as-test!
     

describe 'λ rest' ->
  o 'Should return all but the first character in the string.' do
     for-all Str
     .satisfy (a) -> (l.rest a) is a.slice 1
     .as-test!


describe 'λ last' ->
  o 'Should return the last character in the string.' do
     for-all Str
     .given (.length > 0)
     .satisfy (a) -> (l.last a) is a.char-at (a.length - 1)
     .as-test!

  o 'Should return an empty string for empty strings.' ->
     equals '' (l.last '')

     
describe 'λ but-last' ->
  o 'Should return all but the last character.' do
     for-all Str
     .satisfy (a) -> (l.but-last a) is a.slice 0 -1
     .as-test!


describe 'λ take' ->
  o 'Should return the first n characters.' do
     for-all Str, Int
     .satisfy (a, n) -> (l.take n, a) is a.slice 0, n
     .as-test!


describe 'λ drop' ->
  o 'Should return all but the first n characters.' do
     for-all Str, Int
     .satisfy (a, n) -> (l.drop n, a) is a.slice n
     .as-test!
