" Pattern builder

" pb#new returns a new pattern builder
" Accepts 0 or 1 arguments:
"   Arg #1 - Pattern delimiter:
"     Delimits the start and end of the pattern, and cannot
"     appear anywhere within the pattern
"     Default: +
func! g:pb#new(...)
  let this = {}
  let this.delim = (a:0 >= 1) ? a:1 : '+'

  " Join a list of patterns with the given separator
  func! this.join(ps, s)
    return join(a:ps, a:s)
  endfunc

  " Wrap the given pattern with an open and close pattern
  func! this.wrap(o, p, c)
    return a:o . a:p . a:c
  endfunc

  " grp: group
  " Given a variadic number of patterns as arguments,
  " join them and wrap with group delimiters.
  " Does NOT capture matches - see cgrp for capturing groups.
  " Boolean AND
  func! this.grp(...)
    return self.lgrp(a:000)
  endfunc

  " lgrp: list group
  " Given a list of atoms, combine them into a group
  " Boolean AND
  func! this.lgrp(ps)
    return self.wrap('\%(', self.join(a:ps, ''), '\)')
  endfunc

  " cgrp: capturing group
  " Same as group but captures matches into \1 .. \9
  " Keep in mind there is a limit of 9 capturing groups per
  " pattern. If you get an error like `(NFA regexp) Too many '('`,
  " you have exceeded this limit.
  func! this.cgrp(...)
    return self.lcgrp(a:000)
  endfunc

  " lcgrp: list capturing group
  " Given a list of atoms, combine them into a group
  " Boolean AND
  func! this.lcgrp(ps)
    return self.wrap('\(', self.join(a:ps, ''), '\)')
  endfunc

  " agrp: any group
  " Group which matches any atom given a list of patterns
  " Boolean OR
  func! this.agrp(...)
    return self.lagrp(a:000)
  endfunc

  " lagrp: list any group
  " Group which matches any atom given a list of patterns
  " Boolean OR
  func! this.lagrp(ps)
    return self.grp(self.join(a:ps, '\|'))
  endfunc

  " Given a list of atoms, combine them into a collection of atoms
  " See :h E69
  func! this.col(ps)
    return self.wrap('\[', self.join(a:ps, ''), ']')
  endfunc

  " Given a list of atoms, combine them into a sequence of optional
  " atoms
  " See :h E69
  func! this.seq(ps)
    return this.wrap('\%[', self.join(a:ps, ''), ']')
  endfunc

  " Matches {min,max} of the specified atom
  " See :h /multi
  func! this.multi(p, min, max)
    return self.join([a:p, '\{', a:min, ',', a:max, '}'], '')
  endfunc

  " Matches 0 or 1 of the specified atom (greedy)
  func! this.opt(p)
    return a:p . '\?'
  endfunc

  " Positive lookahead
  func! this.pla(p)
    return a:p . '\@='
  endfunc

  " Negative lookahead
  func! this.nla(p)
    return a:p . '\@!'
  endfunc

  " Positive lookbehind
  func! this.plb(p)
    return a:p . '\@<='
  endfunc

  " Negative lookbehind
  func! this.nlb(p)
    return a:p . '\@<!'
  endfunc

  " NO-OP
  " returns empty string
  " Useful for disabling a portion of a
  " pattern in development
  func! this.nop(...)
    return ''
  endfunc

  " Passthrough
  " returns first argument
  " Useful for disabling a portion of a
  " pattern in development
  func! this.pt(a)
    return a:a
  endfunc

  " Joins a variable number of pattern pieces together
  " between pattern delimiters to create a complete pattern
  func! this.make(...)
    return self.wrap(self.delim, self.join(extend(['\C'], a:000), ''), self.delim)
  endfunc

  return this
endfunc
