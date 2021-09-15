%builtins output

from starkware.cairo.common.serialize import serialize_word

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
