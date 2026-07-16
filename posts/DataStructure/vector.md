# std::vector
- [std::vector](#stdvector)
  - [1. `push_back`](#1-push_back)
    - [1.1. 복사, 이동 버전 `push_back`](#11-복사-이동-버전-push_back)
    - [1.2. emplace\_back호출: `_emplace_one_at_back`](#12-emplace_back호출-_emplace_one_at_back)
    - [1.3. 공간 있음: `_Emplace_back_with_unused_capacity`](#13-공간-있음-_emplace_back_with_unused_capacity)
    - [1.4. 공간 없음: `_Emplace_reallocate`](#14-공간-없음-_emplace_reallocate)
  - [삭제](#삭제)

## 1. `push_back`
```
┌─────────────┐            ┌──────────────┐
│  push_back  │ ─ ─ ─ ─ →  │ emplace_back │
└─────────────┘            └──────┬───────┘
                                  │
                                  ▼
                        ┌──────────────────┐
                        │ capacity enough? │
                        └────────┬─────────┘
                                 │
                 ┌───────────────┴───────────────┐
                 │                               │
                NO                              YES
                 │                               │
                 ▼                               │
        ┌──────────────────┐                     │
        │      realloc     │                     │
        └────────┬─────────┘                     │
                 │                               │
                 ▼                               │
        ┌──────────────────┐                     │
        │elements copy/move│                     │
        └────────┬─────────┘                     │
                 │                               │
                 └───────────────┬───────────────┘ 
                                 │
                                 ▼
                       ┌──────────────────┐
                       │  placement new   │ 
                       └──────────────────┘
```

### 1.1. 복사, 이동 버전 `push_back`
```cpp
// std::vector에서 발췌

    template <class... _Valty>
    _CONSTEXPR20 decltype(auto) emplace_back(_Valty&&... _Val) {
        // insert by perfectly forwarding into element at end, provide strong guarantee
        _Ty& _Result = _Emplace_one_at_back(_STD forward<_Valty>(_Val)...);
#if _HAS_CXX17
        return _Result;
#else // ^^^ _HAS_CXX17 / !_HAS_CXX17 vvv
        (void) _Result;
#endif // ^^^ !_HAS_CXX17 ^^^
    }

    _CONSTEXPR20 void push_back(const _Ty& _Val) { // insert element at end, provide strong guarantee
        _Emplace_one_at_back(_Val);
    }

    _CONSTEXPR20 void push_back(_Ty&& _Val) {
        // insert by moving into element at end, provide strong guarantee
        _Emplace_one_at_back(_STD move(_Val));
    }
```
`push_back`은 범용 생성 로직인 `emplace_back`의 래핑 함수이다. `push_back`은 결국 이미 존재하는 객체를 벡터에 넣는 행위로, 이미 범용 생성 로직이 존재하는데 `push_back`을 위해 복잡한 재할당/생성 로직을 짜는 것보다 `emplace_back`의 인자로 넘겨 완성하는 편이 코드 중복이나 유지보수 측면에서 좋아보인다. 이 흐름에는 재할당, 메모리 생성, `size_` 증가 등의 핵심 로직이 포함된다.

***const _Ty&*** 버전은 원본을 건드릴 수 없기 때문에 복사 생성을 유도한다.

***_Ty&&*** 버전은 원본이 임시 객체이거나 더 이상 안쓸 객체이다. 때문에 `emplace_back(std::move(val))`을 호출하여 복사 대신 이동 생성을 유도한다.
>> 이동 생성자가 존재하지 않는 객체는 복사생성자
이후 `_emplace_one_at_back`을 호출한다.



### 1.2. emplace_back호출: `_emplace_one_at_back`
>> 내부 함수들에서 왜 굳이 참조자로 반환하는걸까?
```cpp
    template <class... _Valty>
    _CONSTEXPR20 _Ty& _Emplace_one_at_back(_Valty&&... _Val) {
        // insert by perfectly forwarding into element at end, provide strong guarantee
        // 강한 예외 보장. 이 함수 실행 중 예외가 발생하면 벡터는 원래 상태를 유지한다.
        auto& _My_data   = _Mypair._Myval2;
        pointer& _Mylast = _My_data._Mylast;

        // 공간 있음. 이상적인 경로.
        if (_Mylast != _My_data._Myend) {
            return _Emplace_back_with_unused_capacity(_STD forward<_Valty>(_Val)...);
        }

        // 공간 없음. realloc.
        return *_Emplace_reallocate(_Mylast, _STD forward<_Valty>(_Val)...);
    }
```

### 1.3. 공간 있음: `_Emplace_back_with_unused_capacity`

```cpp
    template <class... _Valty>
    _CONSTEXPR20 _Ty& _Emplace_back_with_unused_capacity(_Valty&&... _Val) {
        // insert by perfectly forwarding into element at end, provide strong guarantee
        auto& _My_data   = _Mypair._Myval2;
        pointer& _Mylast = _My_data._Mylast;
        _STL_INTERNAL_CHECK(_Mylast != _My_data._Myend); // check that we have unused capacity
        // if 이 객체를 생성할 때 절대 예외를 던지지 않는가?(noexcept) & 기본 할당자를 사용하는가?
        if constexpr (conjunction_v<is_nothrow_constructible<_Ty, _Valty...>,
                          _Uses_default_construct<_Alloc, _Ty*, _Valty...>>) {
            _ASAN_VECTOR_MODIFY(1);
            _Construct_in_place(*_Mylast, _STD forward<_Valty>(_Val)...);
        } else {
            _ASAN_VECTOR_EXTEND_GUARD(static_cast<size_type>(_Mylast - _My_data._Myfirst) + 1);
            _Alty_traits::construct(_Getal(), _Unfancy(_Mylast), _STD forward<_Valty>(_Val)...);
            _ASAN_VECTOR_RELEASE_GUARD;
        }

        _Orphan_range(_Mylast, _Mylast);
        _Ty& _Result = *_Mylast;
        ++_Mylast;

        return _Result;
    }
```
* `if constexpr (conjunction_v<is_nothrow_constructible<_Ty, _Valty...>,
                          _Uses_default_construct<_Alloc, _Ty*, _Valty...>>)`
이 객체를 생성할 때 절대 예외를 던지지 않는가?(noexcept) & 기본 할당자를 사용하는가?
    * **참인 경우**: 예외 걱정이 없기 때문에 placement new를 래핑한 함수 `_Construct_in_place`를 호출하여 빠르게 메모리에 객체를 생성한다.
    * **거짓인 경우**: 생성자가 예외를 던질 위험이 있다면 벡터의 상태를 보호할 로직들을 수행한다.
* 공통 정리로직
  * `_Orphan_range(_Mylast, _Mylast)`: 이 영역이 이제 유효한 데이터가 되었음을 벡터의 반복자(Iterator)들에게 알린다. (디버깅 모드에서 무효화된 반복자를 체크하는 용도)

  * `_Ty& _Result = *_Mylast;`: 생성된 객체의 참조를 반환한다.

  * `++_Mylast;`: 실제 벡터의 마지막 지점(Last) 포인터를 다음 칸으로 한 칸 이동시킨다.
### 1.4. 공간 없음: `_Emplace_reallocate`
**①** 더 큰 메모리를 잡는다.
**②** 새로 들어올 데이터를 먼저 생성한다. (예외 대비)
**③** 나머지 데이터들을 이동 혹은 복사한다. (noexcept 여부에 따라 속도 결정)
**④** 모든 게 성공하면 기존 메모리를 버리고 새 메모리로 교체한다.
**⑤** 중간에 실패하면 싹 다 정리하고 원래 상태를 유지한다.
```cpp
template <class... _Valty>
_CONSTEXPR20 pointer _Emplace_reallocate(const pointer _Whereptr, _Valty&&... _Val) {
    // reallocate and insert by perfectly forwarding _Val at _Whereptr
    _Alty& _Al        = _Getal();
    auto& _My_data    = _Mypair._Myval2;
    pointer& _Myfirst = _My_data._Myfirst;
    pointer& _Mylast  = _My_data._Mylast;

    _STL_INTERNAL_CHECK(_Mylast == _My_data._Myend); // check that we have no unused capacity

    const auto _Whereoff = static_cast<size_type>(_Whereptr - _Myfirst);
    const auto _Oldsize  = static_cast<size_type>(_Mylast - _Myfirst);

    if (_Oldsize == max_size()) {
        _Xlength();
    }

    // 현재 크기(_Oldsize)에 1을 더한 _Newsize를 기준으로 _Calculate_growth를 통해 새로운 용량 계산
    const size_type _Newsize = _Oldsize + 1;
    size_type _Newcapacity   = _Calculate_growth(_Newsize);

    // 새로운 메모리 영역 할당 (아직 기존 데이터 옮기지 않음)
    const pointer _Newvec           = _Allocate_at_least_helper(_Al, _Newcapacity);
    const pointer _Constructed_last = _Newvec + _Whereoff + 1;
    pointer _Constructed_first      = _Constructed_last;

    _TRY_BEGIN
    // 다른 기존 데이터들을 옮기기 전에, 새로 들어올 데이터(_Val)를 새 메모리 공간의 삽입 위치(_Whereoff)에 먼저 생성한다.
    _Alty_traits::construct(_Al, _Unfancy(_Newvec + _Whereoff), _STD forward<_Valty>(_Val)...);
    _Constructed_first = _Newvec + _Whereoff;

    if (_Whereptr == _Mylast) { // at back, provide strong guarantee // 맨 뒤에 삽입하는 경우
    // 이동 생성자가 noexcept라면 move를 사용해 주소값만 뺏고(매우 빠름)
    // 그렇지 않으면 어쩔 수 없이 copy한다.
        if constexpr (is_nothrow_move_constructible_v<_Ty> || !is_copy_constructible_v<_Ty>) {
            _Uninitialized_move(_Myfirst, _Mylast, _Newvec, _Al);
        } else {
            _Uninitialized_copy(_Myfirst, _Mylast, _Newvec, _Al);
        }
    } else { // provide basic guarantee // 중간에 삽입하는 경우
        _Uninitialized_move(_Myfirst, _Whereptr, _Newvec, _Al);
        _Constructed_first = _Newvec;
        _Uninitialized_move(_Whereptr, _Mylast, _Newvec + _Whereoff + 1, _Al);
    }
    // 이동/복사 과정에서 예외가 발생하면
    _CATCH_ALL
    // 새로 만든 객체들을 모두 파괴하고
    _Destroy_range(_Constructed_first, _Constructed_last, _Al);
    // 새로 할당한 메모리도 반납한 뒤
    _Al.deallocate(_Newvec, _Newcapacity);
    // 예외를 다시 던진다.
    _RERAISE;
    _CATCH_END

    // 모든 과정이 성공했다면 이제 벡터의 포인터들(_Myfist, _Mylast 등)을 새로운 메모리 주소를 가리키도록 갱신한다. 기존 메모리는 여기서 해제한다.
    _Change_array(_Newvec, _Newsize, _Newcapacity);
    return _Newvec + _Whereoff;
}
```
* `    _Alty_traits::construct(_Al, _Unfancy(_Newvec + _Whereoff), _STD forward<_Valty>(_Val)...);` 
  * 다른 기존 데이터들을 옮기기 전에, 새로 들어올 데이터(_Val)를 새 메모리 공간의 삽입 위치(_Whereoff)에 먼저 생성한다.
  * 기존 데이터를 모두 옮긴 후에 삽입하다 생성 중 예외가 발생하면, 기존 데이터의 상태가 망가질 수 있기 때문이다.
* **Strong Guarantee** 의 의미 `_CATCH_ALL`
  * 이동/복사 과정에서 예외가 발생하면 새로 만든 객체들을 모두 파괴하고 새로 할당한 메모리도 반납한 뒤 예외를 다시 던진다. 즉, 벡터의 상태를 예외가 터지기 전으로 완벽하게 되돌린다.
## 삭제
