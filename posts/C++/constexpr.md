# constexpr
`constexpr`은 결과값이 컴파일 도중에 결정이 됐으면 좋겠다는 의도이다. 해당 변수나 함수의 값을 가능한 경우 컴파일 타임에 계산하여 성능을 최적화하고, 컴파일 타임 상수가 필요한 문맥(배열 크기, 템플릿 인자)에서 사용할 수 있게 해주는 키워드이다.

## 느낀점
간단하고 많이 호출될 유틸리티 연산에는 모두 붙여보는게 좋겠다. 그래도 복잡하거나 재귀가 필요한 경우에는 컴파일 타임이 늘어날테니 신경써야할 것 같다.

## const와의 차이
* `const` 는 초기화가 런타임까지 지연될 수 있지만, `constexpr`은 컴파일 시간에 초기화되어야 한다.
* `constexpr`이 붙은 변수는 `const`를 보장한다.

## 템플릿과의 차이
constexpr은 템플릿보다 유연하다. 진짜 함수처럼 실행 중에 결정이 될 수도 있고, 컴파일 중에 결정이 될 수도 있다. 
* 인자들이 모두 컴파일 타임 상수라면 컴파일 타임에 미리 계산되어 박힌다.
* 인자 중 하나라도 런타임 변수라면 일반 함수처럼 런타임에 실행된다.

## 컴파일타임에 결정 안되면 에러내기
반환받을 변수에 constexpr을 붙이면 컴파일 타임에서 결과가 결정되지 않았을 때 컴파일 에러를 낼 수 있다.

```cpp
#include <iostream>

// 1. constexpr 함수 선언
// 인자가 컴파일 타임 상수면 컴파일 타임에 계산되고, 
// 런타임 변수면 런타임에 실행된다.

constexpr int multiply(int a, int b)
{
    return a * b;
}

int main() 
{
    // [케이스 1] 컴파일 타임 계산 (0 코스트 최적화)
    // 3과 5 모두 상수이므로, 컴파일러가 빌드할 때 미리 15로 계산해서 박아넣는다.
    // (실행 파일에는 multiply 함수 호출 코드가 아예 사라지고 그냥 숫자 15만 남는다.)
    constexpr int compile_time_result = multiply(3, 5);
    
    // 배열 크기(템플릿/컴파일 타임 상수 Context)에 당당히 사용 가능. const니까 !!!!
    int arr[compile_time_result]; 
    std::cout << "배열 크기: " << compile_time_result << "\n";

    // [케이스 2] 런타임 계산
    // 사용자로부터 입력을 받는 등 런타임에 결정되는 값이 들어가면?
    int user_input;
    std::cout << "숫자를 입력하세요: ";
    std::cin >> user_input;

    // 이 multiply는 일반 함수처럼 실행 중에 계산된다.
    int runtime_result = multiply(user_input, 2);
    std::cout << "런타임 결과: " << runtime_result << "\n";

    // [케이스 3] 컴파일 타임 강제
    // 받는 변수에도 constexpr을 붙이기.
    constexpr int forced_compile_time = multiply(10, 20); // 성공! (상수 대 상수)
    constexpr int error_case = multiply(user_input, 2);  // 에러 (런타임 값 들어감)

    return 0;
}
```