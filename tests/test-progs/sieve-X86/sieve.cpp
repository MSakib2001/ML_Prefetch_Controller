#include <iostream>
#include <vector>

int main(int argc, char* argv[]) {
    int n = std::stoi(argv[1]);

    if (n < 2) {
        std::cout << 0 << std::endl;
        return 0;
    }

    std::vector<bool> is_prime(n + 1, true);
    is_prime[0] = is_prime[1] = false;

    for (int p = 2; p * p <= n; ++p) {
        if (is_prime[p]) {
            for (int i = p * p; i <= n; i += p)
                is_prime[i] = false;
        }
    }

    int prime_count = 0;
    for (int i = 2; i <= n; ++i)
        if (is_prime[i]) ++prime_count;

    std::cout << prime_count << std::endl;
}
