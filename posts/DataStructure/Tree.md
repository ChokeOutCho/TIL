# 트리

데이터를 계층적인 구조로 저장하고 관리하기 위해 사용하는 비선형 자료구조. 나무를 거꾸로 세운 모양을 하고 있어 '트리'라고 부른다. 폴더 시스템, HTML 문서 구조, 데이터베이스 인덱싱 등 실생활과 컴퓨터 시스템 곳곳에서 자주 사용된다.

### 1. 구성 요소
트리는 노드들이 간선(Edge)으로 연결된 형태이다.
* 루트 노드: 트리의 가장 상단에 있는 노드.
* 부모 노드: 특정 노드와 연결된 상위 노드.
* 자식 노드: 특정 노드와 연결된 하위 노드.
* 단말(Leaf) 노드: 자식이 없는 가장 아래 노드.
* 형제(Sibling) 노드: 같은 부모를 가진 노드.

### 2. 주요 용어
* 깊이: 루트 노드에서 특정 노드까지의 간선 개수. (루트의 깊이는 0)
* 높이: 특정 노드에서 가장 아래에 있는 단말 노드까지의 간선 개수. (트리의 높이 == 루트의 높이)
* 레벨: 루트 노드를 1단계(혹은 0단계)로 하여 아래로 내려갈수록 1씩 증가하는 단계.
* 차수(Degree): 노드가 가진 자식 노드의 개수.

### 3. 특징
* **계층적 구조:** 데이터 간의 부모-자식 관계를 명확하게 표현한다.
* **연결성:** 노드 사이에 순환(Cycle)이 없다.(순환 있으면 그래프)
* **루트의 유일성:** 임의의 노드에서 다른 노드로 가는 경로는 오직 하나뿐이다.
* **효율적인 탐색:** 특히 BST같은 구조를 활용하면 데이터를 아주 빠르게 찾거나 삽입/삭제 할 수 있다.

### 4. 대표적인 종류
* 이진(Binary) 트리: 모든 노드가 최대 2개의 자식 노드만을 가지는 트리.
* 이진 탐색(Search) 트리: 왼쪽 자식은 부모보다 작고, 오른쪽 자식은 부모보다 큰 규칙을 가진 이진 트리.
* 힙(Heap): 최대값이나 최소값을 빠르게 찾아내기 위한 이진 트리 기반 구조. 우선순위 큐를 구현할 때 활용됨.

### 5. 활용처:
* 파일 시스템
* DB(비트리)
* 당장 내 프로젝트들에도 속도가 중요한 다양한 곳에서 쓰고있음.. (RB트리 위주)
<br><br><br>

# 이진 검색 트리
이제 지울때 BST를 유지해야한다. 지운
```cpp
// 트리 노드 구조체
struct Node {
    int data;
    Node* left;
    Node* right;

    Node(int val) : data(val), left(nullptr), right(nullptr) {}
};
```
```cpp
// 이진 탐색 트리 클래스
class BinarySearchTree {
private:
    Node* root;
    Node* insert(Node* node, int val) {
        if (node == nullptr) return new Node(val);
        if (val < node->data) node->left = insert(node->left, val);
        else if (val > node->data) node->right = insert(node->right, val);
        return node;
    }

    // 탐색 함수: 재귀적으로 노드를 찾음
    Node* search(Node* node, int val) {
        if (node == nullptr || node->data == val) return node;
        if (val < node->data) return search(node->left, val);
        return search(node->right, val);
    }

    // 최소값 노드를 찾는 함수 (삭제 시 사용)
    Node* findMin(Node* node) {
        while (node->left != nullptr) node = node->left;
        return node;
    }

    // 삭제 함수
    Node* remove(Node* node, int val) {
        if (node == nullptr) return node;

        if (val < node->data) node->left = remove(node->left, val);
        else if (val > node->data) node->right = remove(node->right, val);
        else {
            // 1. 자식이 없거나 하나인 경우
            if (node->left == nullptr) {
                Node* temp = node->right;
                delete node;
                return temp;
            } else if (node->right == nullptr) {
                Node* temp = node->left;
                delete node;
                return temp;
            }
            // 2. 자식이 둘인 경우: 오른쪽 서브트리의 최소값 노드를 찾아 대체
            Node* temp = findMin(node->right);
            node->data = temp->data;
            node->right = remove(node->right, temp->data);
        }
        return node;
    }

    void inorder(Node* node) {
        if (node != nullptr) {
            inorder(node->left);
            std::cout << node->data << " ";
            inorder(node->right);
        }
    }

public:
    BinarySearchTree() : root(nullptr) {}

    void insert(int val) { root = insert(root, val); }
    
    bool search(int val) { return search(root, val) != nullptr; }

    void remove(int val) { root = remove(root, val); }

    void display() { inorder(root); std::cout << std::endl; }
};
```

