" Pattern builder

" Join a list of patterns with the given separator
func! s:join(ps, s)
  return join(a:ps, a:s)
endfunc

" Wrap the given pattern with an open and close pattern
func! s:wrap(o, p, c)
  return a:o . a:p . a:c
endfunc

" grp: group
" Given a variadic number of patterns as arguments,
" join them and wrap with group delimiters.
" Does NOT capture matches - see cgrp for capturing groups.
" Boolean AND
func! s:grp(...)
  return s:lgrp(a:000)
endfunc

" lgrp: list group
" Given a list of atoms, combine them into a group
" Boolean AND
func! s:lgrp(ps)
  return s:wrap('\%(', s:join(a:ps, ''), '\)')
endfunc

" cgrp: capturing group
" Same as group but captures matches into \1 .. \9
" Keep in mind there is a limit of 9 capturing groups per
" pattern. If you get an error like `(NFA regexp) Too many '('`,
" you have exceeded this limit.
func! s:cgrp(...)
  return s:lcgrp(a:000)
endfunc

" lcgrp: list capturing group
" Given a list of atoms, combine them into a group
" Boolean AND
func! s:lcgrp(ps)
  return s:wrap('\(', s:join(a:ps, ''), '\)')
endfunc

" agrp: any group
" Group which matches any atom given a list of patterns
" Boolean OR
func! s:agrp(...)
  return s:lagrp(a:000)
endfunc

" lagrp: list any group
" Group which matches any atom given a list of patterns
" Boolean OR
func! s:lagrp(ps)
  return s:grp(s:join(a:ps, '\|'))
endfunc

" Given a list of atoms, combine them into a collection of atoms
" See :h E69
func! s:col(ps)
  return s:wrap('\[', s:join(a:ps, ''), ']')
endfunc

" Given a list of atoms, combine them into a sequence of optional
" atoms
" See :h E69
func! s:seq(ps)
  return s:wrap('\%[', s:join(a:ps, ''), ']')
endfunc

" Matches {min,max} of the specified atom
" See :h /multi
func! s:multi(p, min, max)
  return s:join([a:p, '\{', a:min, ',', a:max, '}'], '')
endfunc

" Matches 0 or 1 of the specified atom (greedy)
func! s:opt(p)
  return a:p . '\?'
endfunc

" Positive lookahead
func! s:pla(p)
  return a:p . '\@='
endfunc

" Negative lookahead
func! s:nla(p)
  return a:p . '\@!'
endfunc

" Positive lookbehind
func! s:plb(p)
  return a:p . '\@<='
endfunc

" Negative lookbehind
func! s:nlb(p)
  return a:p . '\@<!'
endfunc

" NO-OP
" returns empty string
" Useful for disabling a portion of a
" pattern in development
func! s:nop(...)
  return ''
endfunc

" Passthrough
" returns first argument
" Useful for disabling a portion of a
" pattern in development
func! s:pt(a)
  return a:a
endfunc

" pb#new returns a new pattern builder
" Accepts an optional 'options' dictionary which can contain the following keys:
"   delim:
"     Delimits the start and end of the pattern, and cannot
"     appear anywhere within the pattern
"     Default: +
"   ignorecase: (0 or 1)
"     Whether the patterns built with the builder should be case-insensitive
"     Default: 0
func! g:pb#new(...)
  let opts = (a:0 >= 1) ? a:1 : {}
  let opts = extend({
    \ 'delim':     '+'
    \ 'ignorecase': 0,
  \ }, opts)

  let this = {
    \ 'opts': opts,
    \ 'pats': []
  \ }

  " Finalizes the Pattern Builder object,
  " converting the pattern into a string
  func! this.make()
    let pat = ''
    if self.opts.ignorecase == 0
      let pat = pat . '\C'
    endif
    return self.delim . pat . join(self.pats, '') . self.delim
  endfunc

  func! this.chain(f, ...)
    let args = []
    for a in a:000
      let s = a
      if type(a) == v:t_dict
        let s = call(a.make)
      else
        let s = printf('%s', s)
      endif
      add(args, s)
    endfor
    let res = call(a:f, args)
    add(self.pats, res)
    return self
  endfunc

  func! this.join(ps, s)
    return self.chain(l:join, ps, s)
  endfunc

  func! this.wrap(o, p, c)
    return self.chain(s:wrap, a:o, a:p, a:c)
  endfunc

  func! this.grp(...)
    return self.chain(s:grp, a:...)
  endfunc

  func! this.lgrp(ps)
    return self.chain(s:lgrp, a:ps)
  endfunc

  func! this.cgrp(...)
    return self.chain(s:cgrp, a:...)
  endfunc

  func! this.lcgrp(ps)
    return self.chain(s:lcgrp, a:ps)
  endfunc

  func! this.agrp(...)
    return self.chain(s:agrp, a:...)
  endfunc

  func! this.lagrp(ps)
    return self.chain(s:lagrp, a:ps)
  endfunc

  func! this.col(ps)
    return self.chain(s:col, a:ps)
  endfunc

  func! this.seq(ps)
    return self.chain(s:seq, a:ps)
  endfunc

  func! this.multi(p, min, max)
    return self.chain(s:multi, a:p, a:min, a:max)
  endfunc

  func! this.opt(p)
    return self.chain(s:opt, a:p)
  endfunc

  func! this.pla(p)
    return self.chain(s:pla, a:p)
  endfunc

  func! this.nla(p)
    return self.chain(s:nla, a:p)
  endfunc

  func! this.plb(p)
    return self.chain(s:plb, a:p)
  endfunc

  func! this.nlb(p)
    return self.chain(s:nlb, a:p)
  endfunc

  func! this.nop(...)
    return self.chain(s:nop, a:...)
  endfunc

  func! this.pt(a)
    return self.chain(s:pt, a:a)
  endfunc

  return this
endfunc
