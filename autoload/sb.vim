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
    let prefix = ''
    let ref = a:name
    " Note: the Vim documentation specifies that certain group names
    " are special, but only if they are the first in the group list.
    " This is not taken into account here.
    if index(["ALL", "ALLBUT", "TOP", "CONTAINED"], ref) != -1
      return ref
    endif
    if ref[0] == '!'
      return ref[1:]
    endif
    if ref[0] == '@'
      let prefix = '@'
      let ref = ref[1:]
    endif
    return prefix . self.prefix . ref
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
  func! this.xmatch(...)
    return self
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
  func! this.xkeyword(...)
    return self
  endfunc

  " Builds a 'syntax region ...' command
  func! this.region(name, start, end, ...)
    let obj = {
      \ 'name': self.ref(a:name),
      \ 'start': a:start,
      \ 'end':   a:end,
      \ 'opts':  a:000
    \ }
    let obj.cmd = join(
      \ ['syn region', obj.name, 'start=' . obj.start, 'end=' . obj.end, join(obj.opts, ' ')],
      \ ' '
    \ )
    return self.push(obj)
  endfunc
  func! this.xregion(...)
    return self
  endfunc

  " Builds a 'syntax cluster contains=...' command
  func! this.cluster(name, children, ...)
    let obj = {
      \ 'name': self.ref(a:name),
      \ 'children': map(copy(a:children), { i, c -> self.ref(c) }),
      \ 'opts':  a:000
    \ }
    let obj.cmd = join(
      \ ['syn cluster', obj.name, 'contains=' . join(obj.children, ','), join(obj.opts, ' ')],
      \ ' '
    \ )
    return self.push(obj)
  endfunc
  func! this.xcluster(...)
    return self
  endfunc

  " Builds a 'syntax cluster add=...' command
  func! this.clusteradd(name, add, ...)
    let obj = {
      \ 'name': self.ref(a:name),
      \ 'add': map(copy(a:add), { i, c -> self.ref(c) }),
      \ 'opts':  a:000
    \ }
    let obj.cmd = join(
      \ ['syn cluster', obj.name, 'add=' . join(obj.add, ','), join(obj.opts, ' ')],
      \ ' '
    \ )
    return self.push(obj)
  endfunc
  func! this.xclusteradd(...)
    return self
  endfunc

  " Builds a 'hi def link ...' command
  func! this.hi(from, to)
    let obj = {
      \ 'from': self.ref(a:from),
      \ 'to':   a:to,
    \ }
    let obj.cmd = join(['hi def link', obj.from, obj.to], ' ')
    return self.push(obj)
  endfunc
  func! this.xhi(...)
    return self
  endfunc

  func! this.next(...)
    let groups = map(copy(a:000), { i, g -> self.ref(g) })
    return 'nextgroup=' . join(groups, ',')
  endfunc
  func! this.xnext(...)
    return ''
  endfunc

  func! this.lcontained(refs)
    if len(a:refs) == 0
      return 'contained'
    endif
    let groups = map(copy(a:refs), { i, g -> self.ref(g) })
    return 'contained containedin=' . join(groups, ',')
  endfunc
  func! this.xlcontained(...)
    return ''
  endfunc

  func! this.contained(...)
    if len(a:000) == 0
      return 'contained'
    endif
    let groups = map(copy(a:000), { i, g -> self.ref(g) })
    return 'contained containedin=' . join(groups, ',')
  endfunc
  func! this.xcontained(...)
    return ''
  endfunc

  func! this.lcontains(refs)
    let groups = map(copy(a:refs), { i, g -> self.ref(g) })
    return 'contains=' . join(groups, ',')
  endfunc
  func! this.xlcontains(...)
    return ''
  endfunc

  func! this.contains(...)
    let groups = map(copy(a:000), { i, g -> self.ref(g) })
    return 'contains=' . join(groups, ',')
  endfunc
  func! this.xcontains(...)
    return ''
  endfunc

  return this
endfunc
