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

  " ref takes a non-prefixed name and returns the
  " full version
  func! this.ref(name)
    return self.prefix . a:name
  endfunc

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
      \ 'name': self.ref(a:name),
      \ 'pat':  a:pat,
      \ 'opts': a:000,
    \ }
    let obj.cmd = join(
      \ ['syn match', obj.name, obj.pat, join(obj.opts, ' ')],
      \ ' '
    \ )
    return self.push(obj)
  endfunc

  " Builds a 'syntax keyword ...' command
  func! this.keyword(name, ...)
    let obj = {
      \ 'name': self.ref(a:name),
      \ 'opts': a:000,
    \ }
    let obj.cmd = join(
      \ ['syn keyword', obj.name, join(obj.opts, ' ')],
      \ ' '
    \ )
    return self.push(obj)
  endfunc

  " Builds a 'syntax region ...' command
  func! this.region(name, start, end, ...)
    let obj = {
      \ 'name': self.ref(a:name),
      \ 'start': a:start,
      \ 'end':   a:end,
      \ 'opts':  a:000,
    \ }
    let obj.cmd = join(
      \ ['syn region', obj.name, 'start=' . obj.start, 'end=' . obj.end, join(obj.opts, ' ')],
      \ ' '
    \ )
    return self.push(obj)
  endfunc

  " Disabled groups
  " Useful for disabling a syntax group during development
  func! this.xmatch(...)
    return self
  endfunc
  func! this.xkeyword(...)
    return self
  endfunc
  func! this.xregion(...)
    return self
  endfunc

  return this
endfunc
