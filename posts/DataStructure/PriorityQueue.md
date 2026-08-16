# 우선순위 큐

## 사용처
* 나는 A*와 JPS의 오픈리스트에서 F값이 가장 작은 노드를 찾기위해 썼었다.
* 로그인 타임아웃을 구현할 때 사용한 동료를 봤다. 잘 동작했다.

## 특징
* **최우선순위 즉시 조회:** 가장 큰 값이나 작은 값이 루트 노드에 상주하기 때문에 조회가(top)가 매우매우 빠르다.
* **효율적인 삽입/삭제 ($O(\log N)$):** 데이터를 넣거나 뺄 때 트리의 전체 높이만큼만 (최대 $\log_2 N$번) 부모-자식 간 비교 및 스왑을 수행하므로 대규모 데이터에서도 매우 빠르다.
* **완전 이진 트리 기반의 구조적 균형:** 별도의 회전 없이도 항상 *마지막에 넣고 위로 올린다*는 삽입/삭제 규칙은 완벽한 높이 균형을 유지한다.


## 힙 구현 (노드vs배열)
트리의 구현 방식은 크게 두 가지가 있다.

* 노드로 만들어진 트리: 노드를 사용하면 회전을 통한 균형을 잡을 수 있고, 탐색 속도도 빠르겠다. 중간 삽입 또한 가능하겠다. 노드가 생성되고 그 자리에 있기 때문에 이터레이터도 만들 수 있다.
 
* 배열로 만들어진 트리: 배열로 만들면 메모리상에 연속적으로 빽빽하게 모여있어서 지역성 이득을 크게 볼 수 있다. 대신 중간 삽입이 불가능하고 회전을 통한 균형을 잡을 수 없다. 때문에 탐색할 때 순회를 돌아야한다.

우선순위 큐 구현에 사용할 힙은 **배열**로 만들 예정이다. 노드 기반으로도 만들 수는 있지만 연속적인 메모리에서 부모랑 스왑 하는 방법으로 최대 최소 값을 맞추고 루트만 뽑아 쓰는 용도로 사용하겠다.

```cpp
/*
    템플릿이라서 대소관계 기준이 모호한 객체는 비교연산들을 오버로딩해야 쓸 수 있음.
    
    템플릿에서 반환값 결정을 못하겠음;; 실패했을 때 throw를 하고 싶진 않은데 -1 반환도 불가능함; 그래서 bool로 반환하고 top과 pop을 분리하나봄.
*/
#include <iostream>

template <class T, size_t MAX_SIZE>
class MaxHeap 
{
private:
    T heap[MAX_SIZE];
    size_t size = 0;

    size_t parent(size_t i) { return (i - 1) / 2; }
    size_t leftChild(size_t i) { return 2 * i + 1; }
    size_t rightChild(size_t i) { return 2 * i + 2; }
    void nodeSwap(size_t a, size_t b)
    {
        T temp = heap[a];
        heap[a] = heap[b];
        heap[b] = temp;
    }

public:

    const T& top() const 
    {
        if (size == 0) throw std::out_of_range("Heap is empty");
        return heap[0];
    }

    bool empty() const { return size == 0; }
    size_t getSize() const { return size; }

    int push(const T& value) 
    {
        if (size >= MAX_SIZE) 
        {
            return -1;
        }

        size_t current = size;
        heap[current] = value;
        size++;

        // 부모와 비교하고 스왑을 루트까지 반복
        while (current > 0 && heap[current] > heap[parent(current)]) 
        {
            nodeSwap(current, parent(current));
            current = parent(current);
        }
        return 0;
    }

    int pop()
    {
        if (size == 0) return -1;

        // 맨 끝과 루트 교체하고 사이즈 감소
        heap[0] = heap[size - 1];
        size--;

        size_t current = 0;

        // 자식과 비교하며 내려가기
        while (leftChild(current) < size)
        {
            size_t left = leftChild(current);
            size_t right = rightChild(current);
            size_t largest = current;

            if (left < size && heap[left] > heap[largest])
                largest = left;
            if (right < size && heap[right] > heap[largest])
                largest = right;

            if (largest == current) break;

            nodeSwap(current, largest);
            current = largest;
        }
    }
};

int main()
{
    // 최대 100개까지 담을 수 있는 정적 힙
    MaxHeap<int, 100> maxHeap;

    maxHeap.push(30);
    maxHeap.push(10);
    maxHeap.push(50);
    maxHeap.push(20);
    maxHeap.push(40);

    std::cout << "최댓값 (Top): " << maxHeap.top() << "\n"; // 50

    maxHeap.pop();
    std::cout << "pop 후 최댓값 (Top): " << maxHeap.top() << "\n"; // 40

    return 0;
}

```