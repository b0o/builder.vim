" Syntax builder

" sb#new returns a new syntax builder
" Accepts 1 argument:
"   Arg #1 - Syntax prefix
"     A string to prefix all syntax group names
"     in order to avoid collisions with other syntax
"     definitions
func! g:sb#new(prefix)
  let this = { 'prefix': a:prefix }

  " Object which holds all syntax definitions
  let this.objs = []

  " Push a new obj onto the list of objs
  func! this.push(...)
    call extend(self.objs, a:000)
    return self
  endfunc

  " Execute all syntax commands in syns.objs
  func! this.exec()
    for obj in self.objs
      execute obj.cmd
    endfor
    return self
  endfunc

  " Builds a 'syntax match ...' command
  func! this.match(name, pat, ...)
    let obj = {
      \ 'name': self.prefix . a:name,
      \ 'pat':  a:pat,
      \ 'opts': a:000,
      \ 'cmd':  join(
        \ ['syn match', self.prefix . a:name, a:pat, join(a:000, ' ')],
        \ ' '
      \ )
    \ }
    return self.push(obj)
  endfunc

  " A disabled match
  " Useful for disabling a match
  " statement during development
  func! this.xmatch(...)
    return self
  endfunc

  return this
endfunc
