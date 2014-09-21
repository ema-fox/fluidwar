SIZE = 50

class Map
  construcotr: (@size) ->

map = for i in [0...SIZE]
        new Int8Array SIZE

for i in [0...SIZE * 0.7 | 0]
  map[i][SIZE / 3 | 0] = 2

for i in [SIZE * 0.3...SIZE | 0]
  map[i][SIZE * 0.7 | 0] = 2

soliders = 0

for j in [0...4]
  for i in [0...SIZE]
    map[i][j] = 1
    soliders++

player = [SIZE * 0.8 | 0, SIZE * 0.8 | 0]

gim = (m, [p0, p1]) ->
  m[p0][p1]

sim = (m, [p0, p1], val) ->
  m[p0][p1] = val

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
    if 0 <= p[0] < SIZE and 0 <= p[1] < SIZE and not visited[p]
      if not (gim(map, p) is 2)
        res.push p
  shuffle res
  res

nvis = 0

walkToPlayer = -> 
  nvis = 0
  frontier = [player]
  movedSoliders = 0
  fixed = {}
  visited = {}
  visited[player] = true
  while movedSoliders < soliders # and frontier.length > 0
    newfrontier = []
    #shuffle frontier
    for p in frontier
      fixed[p] = true
      for pb in ngbrs p, visited
        newfrontier.push pb
        visited[pb] = true
        nvis++
      for pb in ngbrs p, fixed
        if gim(map, pb) is 1
          if gim(map, p) is 0# and Math.random() > 0.5
            sim(map, p, 1)
            sim(map, pb, 0)
          else
            pc = ngbrs(pb, fixed)[0]
            if pc and gim(map, pc) is 0
              sim(map, pc, 1)
              sim(map, pb, 0)
      if gim(map, p) is 1
        movedSoliders++
    frontier = newfrontier
  null

distort = ->
  for p0 in [0...SIZE]
    for p1 in [0...SIZE]
      if Math.random() > 0.5
        pa = [p0, p1]
        n = ngbrs pa, {}
        pb = n[Math.random() * n.length | 0]
        if pb and gim(map, pa) is 1 and gim(map, pb) is 0
          tmp = gim map, pa
          sim map, pa, gim(map, pb)
          sim map, pb, tmp

printMap = ->
  for line in map
    res = ""
    for tile in line
      res += if tile is 0 then " " else if tile is 1 then "." else "#"
    console.log res

ctx = null

draw = ->
  ctx.fillStyle = "#000000"
  ctx.fillRect 0, 0, SIZE * 10, SIZE * 10
  for p0 in [0...SIZE]
    for p1 in [0...SIZE]
      foo = map[p0][p1]
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
