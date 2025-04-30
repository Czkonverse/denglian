import hashlib
import time
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives import hashes


def generate_aim_content(user_name, nums_of_zero_prefix=4):
    nounce = 0
    while True:
        input_str = f"{user_name}{nounce}"
        hash_res = hashlib.sha256(input_str.encode()).hexdigest()
        # print(f"Hash: {hash_res}")

        if hash_res.startswith("0" * nums_of_zero_prefix):
            print(f"Found nounce: {nounce}")
            print(f"Hash: {hash_res}")

            return hash_res
        nounce += 1


def generate_key_pair(public_exponent_std=65537, key_size_std=2048):
    private_key = rsa.generate_private_key(
        public_exponent=public_exponent_std, key_size=key_size_std
    )
    public_key = private_key.public_key()

    return private_key, public_key


def signature_private_key(hash_res, private_key):
    hash_bytes = bytes.fromhex(hash_res)

    signature = private_key.sign(hash_bytes, padding.PKCS1v15(), hashes.SHA256())

    return signature


def verify_signature(public_key, hash_value_hex, signature):

    hash_bytes = bytes.fromhex(hash_value_hex)

    try:
        public_key.verify(signature, hash_bytes, padding.PKCS1v15(), hashes.SHA256())
        return True
    except Exception as e:
        return False


def run(user_name):
    # hash with "0000" prefix
    hash_res = generate_aim_content(user_name, 4)

    # generate_key_pair
    private_key, public_key = generate_key_pair()
    # sign the hash
    signature = signature_private_key(hash_res, private_key)
    # verify the signature
    is_valid = verify_signature(public_key, hash_res, signature)
    print(f"Signature valid: {is_valid}")


if __name__ == "__main__":
    user_name = "Kunverse"

    run(user_name)
