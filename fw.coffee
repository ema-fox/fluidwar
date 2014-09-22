###
Copyright (c) 2014 Emanuel Rylke

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
###

SIZE = 100
PXSIZE = 5

COLORS = ['#073642', '#586e75', '#b58900', '#268bd2']

class Map
  constructor: (@size) ->
    @map = new Int8Array (@size * @size)

  get: ([p0, p1]) ->
    @map[p0 * @size + p1]

  set: ([p0, p1], v) ->
    @map[p0 * @size + p1] = v

map = new Map SIZE

nsoliders = []

nsoliders[2] = 0
player = [SIZE * 0.8 | 0, SIZE * 0.8 | 0]

for j in [0...SIZE * 0.1 | 0]
  for i in [0...SIZE]
    map.set [i, j], 2
    nsoliders[2]++

nsoliders[3] = 0
computer = [SIZE * 0.2 | 0, SIZE * 0.2 | 0]

for j in [SIZE * 0.9 | 0...SIZE]
  for i in [0...SIZE]
    map.set [i, j], 3
    nsoliders[3]++

shuffle = (xs) ->
  for i in [0...xs.length]
    tmp = xs[i]
    r = Math.random() * xs.length | 0
    xs[i] = xs[r]
    xs[r] = tmp
  null

ngbrs = ([p0, p1], visited, fromSolid) ->
  res = []
  for p in [[p0 - 1, p1], [p0 + 1, p1], [p0, p1 - 1], [p0, p1 + 1]]
    if 0 <= p[0] < SIZE and 0 <= p[1] < SIZE and not visited.get(p)
      if fromSolid or not (map.get(p) is 1)
        res.push p
  shuffle res
  res

nvis = 0

walkToPlayer = (pp, pn) ->
  frontier = [pp]
  movedSoliders = 0
  fixed = new Map SIZE
  visited = new Map SIZE
  visited.set pp, 1
  while movedSoliders < nsoliders[pn] and frontier.length > 0
    newfrontier = []
    #shuffle frontier
    for p in frontier
      fixed.set p, 1
      for pb in ngbrs p, visited, (map.get(p) is 1)
        newfrontier.push pb
        visited.set pb, 1
        nvis++
      for pb in ngbrs p, fixed, false
        pfoo = map.get p
        pbar = map.get pb
        if pfoo is 2 and pbar is 0
            computer = p
        if pbar is pn
          if pfoo > 1 and not (pfoo is pn) and Math.random() > 0.9
            map.set p, pn
            nsoliders[pfoo]--
            nsoliders[pn]++
          else if pfoo is 0 and Math.random() > 0.2
            map.set p, pn
            map.set pb, 0
          else
            pc = ngbrs(pb, fixed, false)[0]
            if pc and map.get(pc) is 0
              map.set pc, pn
              map.set pb, 0
      if map.get(p) is pn
        movedSoliders++
    frontier = newfrontier
  null

ctx = null

draw = ->
  ctx.fillStyle = COLORS[0]
  ctx.fillRect 0, 0, (SIZE + 4) * PXSIZE, SIZE * PXSIZE
  for p0 in [0...SIZE]
    for p1 in [0...SIZE]
      foo = map.get [p1, p0]
      if foo
        ctx.fillStyle = COLORS[foo]
        ctx.fillRect p0 * PXSIZE, p1 * PXSIZE, PXSIZE, PXSIZE
  total = nsoliders[2] + nsoliders[3]
  ctx.fillStyle = COLORS[2]
  ctx.fillRect SIZE * PXSIZE, 0, PXSIZE * 2, ((nsoliders[2] / total) * SIZE | 0) * PXSIZE
  ctx.fillStyle = COLORS[3]
  ctx.fillRect (SIZE + 2) * PXSIZE, 0, PXSIZE * 2, ((nsoliders[3] / total) * SIZE | 0) * PXSIZE
  null

ccounter = 0

step = ->
  nvis = 0
  ccounter += 0.01

  computer = [SIZE / 2 + Math.sin(ccounter) * SIZE * 0.45 | 0,
              SIZE / 2 + Math.cos(ccounter) * SIZE * 0.45 | 0]
  walkToPlayer(player, 2)
  walkToPlayer(computer, 3)
  draw()
  if nsoliders[2] is 0
    alert "The computer won :("
    clearInterval intervalId
  if nsoliders[3] is 0
    alert "You won!"
    clearInterval intervalId

intervalId = null

$ ->
  cnvs = $ 'canvas'
  ctx = cnvs[0].getContext '2d'
  $(document).mousemove (evt) ->
    player = [Math.max(0, Math.min(SIZE - 1, (evt.pageY - cnvs.offset().top) / PXSIZE | 0)),
              Math.max(0, Math.min(SIZE - 1, (evt.pageX - cnvs.offset().left) / PXSIZE | 0))]
  bla = $ '<img src="lwmap.png">'
  bla.load ->
    blactx = ($ '<canvas height="100" width="100">')[0].getContext '2d'
    blactx.drawImage bla[0], 0, 0
    d = (blactx.getImageData 0, 0, 100, 100).data
    for i in [0...100 * 100]
      if d[i * 4] < 128
        if map.map[i] > 1
          nsoliders[map.map[i]]--
        map.map[i] = 1
    intervalId = setInterval step, 40
