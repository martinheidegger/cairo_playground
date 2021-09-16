%builtins output

from starkware.cairo.common.serialize import serialize_word

# This is minimal cairo program with the goal to figure out
# the index of  "input.item" within an array of "input.list".

# The output of the program should be an integer (like "2")
# which means that the input's id is on the item 
func main{output_ptr : felt*}():
    alloc_locals

    local list : felt*
    local item
    local index
    %{
        ids.item = item = program_input['item']
        ids.list = list = segments.add()
        for i, val in enumerate(program_input['list']):
           if val == item:
               ids.index = i
           memory[list + i] = val
    %}

    serialize_word(index)
    return ()
end
