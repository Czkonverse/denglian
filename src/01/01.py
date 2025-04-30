import hashlib
import time

def run(user_name, nums_of_zero_prefix):

    start_time = time.time()

    nounce = 0
    while True:
        input_str = f"{user_name}{nounce}"
        hash_res = hashlib.sha256(input_str.encode()).hexdigest()
        # print(f"Hash: {hash_res}")

        if hash_res.startswith("0" * nums_of_zero_prefix):
            print(f"Found nounce: {nounce}")
            print(f"Hash: {hash_res}")

            break

        nounce += 1

    end_time = time.time()

    elapsed_time = end_time - start_time

    print(f"Time spent: {elapsed_time:.4f} seconds")


if __name__ == "__main__":
    # 0 input params
    nums_of_zero_prefix = 5

    user_name = "Kunverse"

    run(user_name, nums_of_zero_prefix)