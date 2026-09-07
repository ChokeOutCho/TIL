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
    
    템플릿에서 반환값 결정을 못하겠음;; 실패했을 때 throw를 하고 싶진 않음; 
    그래서 반환값은 성공 실패 여부로 하고 [out]인자로 결과를 주는게 좋을듯.
*/
#include <iostream>

template <class T>
class PriorityQueue
{
private:
	size_t size;
	size_t capacity;
	T* arr;
public:
	explicit PriorityQueue(size_t capacity)
	{
		this->capacity = capacity;
		arr = new T[capacity];
		size = 0;
	}
	~PriorityQueue()
	{
		delete[] arr;
	}
	void push(T value)
	{
		if (capacity <= size) return;
		int cur = size;
		size++;
		arr[cur] = value;
		while (cur > 0)
		{
			// 지금은 최대힙
			int p = parent(cur);
			if (arr[p] >= arr[cur])
				break;

			swap(p, cur);
			cur = p;
		}
	}

	T top() const
	{
		return arr[0];
	}

	void pop()
	{
		if (size == 0) return;

		// 마지막 원소를 루트로 세팅하고 재정렬
		// l과 r 비교하고 내 자리로 세팅.
		arr[0] = arr[--size];
		int cur = 0;
		while (left(cur) < size)
		{
			int l = left(cur);
			int r = right(cur);
			int t = l;
			// r < size: 오른쪽 자식이 존재한다.
			if (r < size && arr[r] > arr[l])
				t = r;

			if (arr[cur] >= arr[t])
				break;

			swap(cur, t);
			cur = t;
		}
	}
private:
	int parent(int i) const
	{
		return (i - 1) / 2;
	}
	int left(int i) const
	{
		return (i * 2) + 1;
	}
	int right(int i) const
	{
		return (i * 2) + 2;
	}
	

	void swap(int a, int b)
	{
		T temp = arr[a];
		arr[a] = arr[b];
		arr[b] = temp;
	}
};

int main()
{
	PriorityQueue<int> q(100);
	q.push(30);
	q.push(10);
	q.push(50);
	q.push(20);
	q.push(40);
	std::cout << "최댓값 (Top): " << q.top() << "\n"; // 50

	q.pop();
	std::cout << "pop 후 최댓값 (Top): " << q.top() << "\n"; // 40

	return 0;
}


```