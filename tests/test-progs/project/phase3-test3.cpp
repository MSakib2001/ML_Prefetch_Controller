#include <cstdio>
#include <cstdlib>

struct Node {
    int value;
    Node *next;
};

int main() {
    int N = 200000;

    // Create linked list
    Node *head = nullptr;
    for (int i = 0; i < N; i++) {
        Node *node = (Node*)malloc(sizeof(Node));
        node->value = i;
        node->next = head;
        head = node;
    }

    long long sum = 0;
    Node *curr = head;

    // Pointer chasing: irregular access
    while (curr != nullptr) {
        sum += curr->value;
        curr = curr->next;
    }

    printf("SUM = %lld\n", sum);

    // Free (optional for SE-mode)
    return 0;
}
