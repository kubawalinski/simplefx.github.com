user = 'simplefx'
repo = 'simplefx.github.com'
contentFolder = 'simpledata/docs/content'

class Node
  constructor: (@text) ->
    @nodes = []
    @index = false
  addNode: (parts) ->
    if parts.length is 1
      if parts[0] is 'index.html'
        @index = true
      else
        @nodes.push new Node parts[0]
    else
      node = _(@nodes).detect((n) -> n.text is parts[0])
      node.addNode parts.slice(1) if node?

class Tree extends Node
  constructor: (trees) ->
    @nodes = []
    for tree in trees
      @addNode tree.path.split('/')

window.Tree = Tree

toDashes = (str) -> str.replace(/[\s\.\/]/g, '-')

addNestedNode = (tree) ->
  parts = tree.path.split('/')
  id = toDashes(tree.path)
  selector = '#' + _.map(parts[0...-1], toDashes).join('-')
  subList = if tree.type is 'tree' then '<ul></ul>' else ''
  $(selector + ' > ul').append("<li id=\"#{id}\">#{_.last(parts)}#{subList}</li>")

showContentTree = (trees) ->
  for tree in trees
    if tree.path.indexOf('/') is -1
      $('#navigation').append("<li id=\"#{toDashes(tree.path)}\">#{tree.path}<ul></ul></li>")
    else
      addNestedNode tree

getSubTree = (tree, subTreeNames) ->
  subTree = _.first(_.filter(tree, (item) -> item.path is _.first(subTreeNames)))
  if _.size(subTreeNames) is 1
    $.getJSON subTree.url + '?recursive=1&callback=?', (data) -> showContentTree data.data.tree
  else
    $.getJSON subTree.url + '?callback=?', (data) -> getSubTree data.data.tree, _.rest(subTreeNames)

$ ->
  commitsUrl = "https://api.github.com/repos/#{user}/#{repo}/commits?callback=?"
  $.getJSON commitsUrl, (data) ->
    $.getJSON _.first(data.data).commit.tree.url + '?callback=?', (data) ->
      getSubTree data.data.tree, contentFolder.split('/')
