SIZE = 50

class Map
  constructor: (@size) ->
    @map = new Int8Array (@size * @size)

  get: ([p0, p1]) ->
    @map[p0 * @size + p1]

  set: ([p0, p1], v) ->
    @map[p0 * @size + p1] = v

map = new Map SIZE

for i in [0...SIZE * 0.7 | 0]
  map.set [i, SIZE / 3 | 0], 2

for i in [SIZE * 0.3...SIZE | 0]
  map.set [i, SIZE * 0.7 | 0], 2

soliders = 0

for j in [0...4]
  for i in [0...SIZE]
    map.set [i, j], 1
    soliders++

player = [SIZE * 0.8 | 0, SIZE * 0.8 | 0]

shuffle = (xs) ->
  for i in [0...xs.length]
    tmp = xs[i]
    r = Math.random() * xs.length | 0
    xs[i] = xs[r]
    xs[r] = tmp
  null

ngbrs = ([p0, p1], visited) ->
  res = []
  for p in [[p0 - 1, p1], [p0 + 1, p1], [p0, p1 - 1], [p0, p1 + 1]]
    if 0 <= p[0] < SIZE and 0 <= p[1] < SIZE and not visited.get(p)
      if not (map.get(p) is 2)
        res.push p
  shuffle res
  res

nvis = 0

walkToPlayer = -> 
  nvis = 0
  frontier = [player]
  movedSoliders = 0
  fixed = new Map SIZE
  visited = new Map SIZE
  visited.set player, 1
  while movedSoliders < soliders # and frontier.length > 0
    newfrontier = []
    #shuffle frontier
    for p in frontier
      fixed.set p, 1
      for pb in ngbrs p, visited
        newfrontier.push pb
        visited.set pb, 1
        nvis++
      for pb in ngbrs p, fixed
        if map.get(pb) is 1
          if map.get(p) is 0# and Math.random() > 0.5
            map.set p, 1
            map.set pb, 0
          else
            pc = ngbrs(pb, fixed)[0]
            if pc and map.get(pc) is 0
              map.set pc, 1
              map.set pb, 0
      if map.get(p) is 1
        movedSoliders++
    frontier = newfrontier
  null

ctx = null

draw = ->
  ctx.fillStyle = "#000000"
  ctx.fillRect 0, 0, SIZE * 10, SIZE * 10
  for p0 in [0...SIZE]
    for p1 in [0...SIZE]
      foo = map.get [p0, p1]
      if foo
        ctx.fillStyle = "rgb(0, " + foo * 100 + ", 0)"
        ctx.fillRect p0 * 10, p1 * 10, 10, 10 
  ctx.fillStyle = "#ffffff"
  ctx.fillText nvis, 50, 50
  null

step = ->
  walkToPlayer()
  draw()

$ ->
  cnvs = $ 'canvas'
  ctx = cnvs[0].getContext '2d'
  $(document).mousemove (evt) ->
    player = [Math.max(0, Math.min(SIZE - 1, (evt.pageX - cnvs.offset().left) / 10 | 0)), Math.max(0, Math.min(SIZE - 1, (evt.pageY - cnvs.offset().top) / 10 | 0))]
  setInterval step, 40 
