# Declare this file as a StarkNet contract and set the required
# builtins.
%lang starknet
%builtins pedersen range_check ecdsa

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.storage import Storage
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.math import assert_lt
from starkware.cairo.common.math_cmp import is_le

# Count for all the keys in a list
@storage_var
func key_count(user : felt) -> (count: felt):
end

# All keys in all lists
@storage_var
func keys(key_address : felt) -> (key: felt):
end

@external
func push_key{
    storage_ptr : Storage*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
}(
    user : felt,
    public_key : felt
):
    let (count) = key_count.read(user)
    let (key_address) = hash2{hash_ptr=pedersen_ptr}(user, count)
    let newcount = count + 1

    key_count.write(user, newcount)
    keys.write(key_address, public_key)

    return ()
end

@external
func pop_key{
    storage_ptr : Storage*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
}(
    user : felt
):
    let (count) = key_count.read(user)
    let newcount = count - 1

    key_count.write(user, newcount)

    return ()
end

@external
func set_key_at{
    storage_ptr : Storage*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
}(
    user : felt,
    public_key : felt,
    index : felt
):
    let (key_address) = hash2{hash_ptr=pedersen_ptr}(user, index)

    keys.write(key_address, public_key)

    return ()
end

@external
func remove_key_at{
    storage_ptr : Storage*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
}(
    user : felt,
    index : felt
):
    let (count) = key_count.read(user)
    assert_lt(index, count)
    if count == 1:
        pop_key(user)
        return()
    end
    let (res) = _move_next_keys_up(user, count, index)
    if res == 1:
        pop_key(user)
        return ()
    end
    return ()
end

@view
func get_minus_one{
    storage_ptr : Storage*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
}() -> (res: felt):
    return (-1)
end

@view
func get_key_index{
    storage_ptr : Storage*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
}(
    user : felt,
    public_key : felt
) -> (res: felt):
    let (count) = key_count.read(user)
    let (index) = _get_key_index(user, public_key, count, 0)
    return (index)
end

@view
func get_key_count{
    storage_ptr : Storage*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
}(
    user : felt
) -> (res : felt):
    let (count) = key_count.read(user)
    return (count)
end

# Returns the balance of the given user.
@view
func get_key_at{
    storage_ptr : Storage*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
}(
    user : felt,
    index : felt
) -> (res : felt):
    let (count) = key_count.read(user)

    let (key_address) = hash2{hash_ptr=pedersen_ptr}(user, index)
    let (res) = keys.read(key_address)
    return (res)
end

func _move_next_keys_up{
    storage_ptr : Storage*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
}(
    user : felt,
    count : felt,
    index : felt
) -> (res: felt):
    let nextindex = index + 1
    let (is_lt_index) = is_le(count, nextindex)
    if is_lt_index == 1:
        return (0)
    end
    let (key) = get_key_at(user, nextindex)
    set_key_at(user, key, index)
    _move_next_keys_up(user, key, nextindex)
    return (1)
end

func _get_key_index {
    storage_ptr : Storage*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
}(
    user : felt,
    public_key: felt,
    count : felt,
    index : felt
) -> (res: felt):
    let (key) = get_key_at(user, index)
    if key == public_key:
        return (index)
    end
    if index == count:
        return (-1)
    end
    let nextindex = index + 1
    let (result) = _get_key_index(user, public_key, count, nextindex)
    return (result)
end