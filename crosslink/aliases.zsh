# Start crosslink server with config and particular agenda
# $1 => yaml config
# $2 => agenda prop name
function cla() {
	pa crosslink-next
	./server training-content/configs/"$1" -g "$2"
}

# Export static version of crosslink slide content
# $1 => yaml config
# $2 => path to export to
function cle() {
	pa crosslink-next
	./server training-content/configs/"$1" -b "$2"
}
