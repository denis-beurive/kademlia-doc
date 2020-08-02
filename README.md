# kademlia-doc

This repository contains some scripts I have written in order to explore the Kademlia distributed hash table.   

Within this document we use the following terms:
* The _current node_ is the node we focus on. It is the node that is taken for reference for _indexing_ the nodes space
  (relatively to the _current node_).
* A _distant node_ is any other nodes than the current one.

And, for the graphical representations we assume that the node IDs are 5 bits long (instead of 160). 

# Kademlia nodes space

The image [kad-tree.gif](images/kad-tree.gif) shows:
* the _current node_ (which ID is `01010`) within the binary tree that represents the nodes space.
* the 5 successively lower subtrees that don't contain the current node.
  Each subtree is given a color (see [buckets.pal](scripts/buckets.pal)).
  The subtree that contains the unique current node is given the color `#00FF00`.
  The subtree that contains the 2 _distant nodes_ closest to the _current node_ is given the color `#C16CF2`...

![kad-tree.gif](images/kad-tree.gif)

> This image has been generated using the script [kad-tree.pl](scripts/kad-tree.pl): `perl kad-tree.pl --bits=5 --node=01010 --palette=buckets.pal | dot -Tgif -Ograph`

The image [kad-grid-buckets.gif](images/kad-grid-buckets.gif) shows the contents of the 5 successively lower subtrees for all nodes within the nodes spaces.
The number in parentheses (in the rectangles that represent distant nodes) is the distance between the _distant node_ and the _current one_.
For example, the distance between the (current) node `00010` and the (distant) node `00001` is `3` (`b00010 xor b00001 = b00011`, which is `3` in decimal). 
Please note that the colors match the ones used for the previous image ([kad-tree.gif](images/kad-tree.gif)).

![kad-grid-buckets.gif](images/kad-grid-buckets.gif)

> This image has been generated using the script [kad-grid.pl](scripts/kad-grid.pl): `perl kad-grid.pl --palette=buckets.pal --type=buckets | dot -Tgif -Ograph`

The image [kad-grid-peers.gif](images/kad-grid-peers.gif) is similar to the image [kad-grid-buckets.gif](images/kad-grid-buckets.gif).
The difference is that each node is given a unique color (see [peers.pal](scripts/peers.pal)). For example, the node `11111` is given the color `#8d9150`.

![kad-grid-peers.gif](images/kad-grid-peers.gif)

> This image has been generated using the script [kad-grid.pl](scripts/kad-grid.pl): `perl kad-grid.pl  --type=peers | dot -Tgif -Ograph`

