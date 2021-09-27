import os
import pytest
import asyncio
from numpy.testing import assert_array_equal

from starkware.starknet.testing.starknet import Starknet
from starkware.starknet.testing.contract import StarknetContract
from starkware.python.utils import (get_random_instance)
from starkware.cairo.common.math_utils import (as_int)

CONTRACT_FILE = os.path.join(os.path.dirname(__file__), "stored_list.cairo")

def get_random_felt():
    # Not recommended in production
    # https://github.com/starkware-libs/cairo-lang/blob/7526bffb78ba64976c4f019b04d059992b43c734/src/starkware/python/utils.py#L121
    return get_random_instance().getrandbits(250)

async def get_contract():
    starknet = await Starknet.empty()
    return await starknet.deploy(CONTRACT_FILE)

@pytest.mark.asyncio
async def test_push_key():
    contract = await get_contract()
    user = get_random_felt()
    key = get_random_felt()

    await contract.push_key(user=user, public_key=key).invoke()

    assert_array_equal(await get_keys(contract, user), [key])

@pytest.mark.asyncio
async def test_pop_key():
    contract = await get_contract()
    user = get_random_felt()
    key = get_random_felt()

    await contract.push_key(user=user, public_key=key).invoke()

    assert_array_equal(await get_keys(contract, user), [key])

def felt_as_int(felt):
    return as_int(felt, 3618502788666131213697322783095070105623107215331596699973092056135872020481)

async def res_as_int(input):
    res = (await input).res
    return felt_as_int(res)

async def get_key_index(contract, user, public_key):
    return await res_as_int(contract.get_key_index(user=user, public_key=public_key).call())

@pytest.mark.asyncio
async def test_get_key_index():
    contract = await get_contract()
    user = get_random_felt()
    key1 = get_random_felt()
    key2 = get_random_felt()
    key3 = get_random_felt()

    await contract.push_key(user=user, public_key=key1).invoke()
    await contract.push_key(user=user, public_key=key2).invoke()
    await contract.push_key(user=user, public_key=key1).invoke()
    await contract.push_key(user=user, public_key=key3).invoke()

    assert_array_equal(await get_keys(contract, user), [key1, key2, key1, key3])

    assert (await get_key_index(contract, user, key1)) == 0
    assert (await get_key_index(contract, user, key2)) == 1
    # 2 is occupied by key1 again
    assert (await get_key_index(contract, user, key3)) == 3

    assert (await get_key_index(contract, user, get_random_felt())) == -1

@pytest.mark.asyncio
async def test_get_minus_one():
    contract = await get_contract()
    assert (await res_as_int(contract.get_minus_one().call())) == -1

@pytest.mark.asyncio
async def test_remove_key_at():

    contract = await get_contract()

    user = get_random_felt()
    key1 = get_random_felt()
    key2 = get_random_felt()
    key3 = get_random_felt()
    key4 = get_random_felt()

    await contract.push_key(user=user, public_key=key1).invoke()
    await contract.push_key(user=user, public_key=key2).invoke()
    await contract.push_key(user=user, public_key=key3).invoke()
    await contract.push_key(user=user, public_key=key4).invoke()

    assert_array_equal(await get_keys(contract, user), [key1, key2, key3, key4])

    await contract.remove_key_at(user=user, index=1).invoke()

    assert_array_equal(await get_keys(contract, user), [key1, key3, key4])

    with pytest.raises(Exception):
        await contract.remove_key_at(user=user, index=4).invoke()

    with pytest.raises(Exception):
        await contract.remove_key_at(user=user, index=-1).invoke()

    await contract.remove_key_at(user=user, index=0).invoke()
    await contract.remove_key_at(user=user, index=0).invoke()
    await contract.remove_key_at(user=user, index=0).invoke()

    assert_array_equal(await get_keys(contract, user), [])

async def get_keys (contract, user):
    count = await res_as_int(contract.get_key_count(user=user).call())
    keys_raw = await asyncio.gather(*[contract.get_key_at(user=user, index=i).call() for i in range(count)])
    return [key.res for key in keys_raw]
