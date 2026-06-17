# Effective C++
---
## 1. C++에 왔으면 C++의 법에 따라라.
### 1.1. 사용자 정의 타입 생성자는 explicit(명백한) 붙여보기
* 이렇게 선언된 생성자는 암시적인 타입 변환을 수행하는데 쓰이지 않는다.

* 예상하지도 못한 타입 변환을 막아준다.

### 1.2. 선처리(#define)보다 const, enum, inline을 쓰자
* define하면 상수로 대체되어 컴파일러의 기호 테이블에 들어가지 않는다. 소스 코드에는 기호처럼 쓰여있지만 에러메시지 등에는 숫자 상수가 쓰여있어 시간을 허비할 일이 생긴다. **const를 사용하면 기호 테이블에 등록된다.**

* 상수 포인터를 정의하려거든 포인터와 포인터대상 둘 다 const를 붙여야 한다. 상수는 대개 헤더 파일에 넣기 때문에 다른 소스 파일도 이것을 include할 수 있다.
* 문자열 상수를 쓰려거든 그냥 const std::string이 사용하기 괜찮다. 
* 클래스 멤버로 상수를 정의하려거든 구현 파일(cpp)에 둔다. 
* 멤버에 enum {Num = 5}; 처럼 열거형을 상수처럼 써버리면 주소를 얻지 못하게 할 수 있다. 또한 #define처럼 쓸데없는 메모리 할당도 없다. 많은 코드들이 이 기법을 쓰고 있으며, 템플릿 메타프로그래밍의 핵심이라고도 한다.
* 매크로 함수에 괄호를 잘 씌운다고 끝난게 아니다.
```cpp
#define CALL_WITH_MAX (a, b) f((a) > (b) ? (a) : (b) )

int q = 5, w = 0;
CALL_WITH_MAX(++q, w); // q가 두 번 증가
CALL_WITH_MAX(++q, b+10) // q가 한 번 증가
```
* f가 호출 되기 전에 q가 증가하는 횟수가 달라지는 모습이다.
인라인 함수 템플릿을 준비하면 매크로의 효율과 정규함수의 모든 동작 방식 및 타입 안정성까지 취할 수 있다.
``` cpp
template<typename T>
inline void callWithMax(const T& a, const T& b) 
{ f(a > b ? a : b);}
```
* 이 함수는 템플릿이기 떄문에 동일 계열 함수군을 만들어낸다. 동일한 객체 두 개를 인자로 받고 둘 중 큰 것을 f에 넘겨 호출한다. 함수 본문에 괄호칠을 할 필요 없고, 인자를 여러번 평가할 가능성도 사라진다. 그뿐 아니라 진짜 함수이기 때문에 유효 범위 및 접근 규칙을 그대로 따라간다.
* 그래도 선처리를 뿌리뽑긴 어렵다. #include는 뺄 수 없고,  #ifdef/#ifndef도 잘 쓰이고 있다.

### 1.3. const 사용처
+ const는 소스 코드 수준에서 제약 *(const가 붙은 객체는 외부 변경을 불가능하게 한다.)* 을 붙이고, 컴파일러가 이 제약을 단단히 지켜준다. 또한 불변이어야 한다는 의도를 전할 수 있다.

+ **반복자(iterator)는 포인터를 본뜬 것**이기 때문에, 기본적인 동작 원리가 T* 포인터와 흡사하다. 즉, 반복자를 const로 선언하는 일은 포인터를 상수로 선언하는 것(const *T)과 같다. 반복자는 자신이 가리키는 대상이 아닌것을 가리키는 대상이 아닌 것을 가리키는 경우는 허용되지 않지만, 가리키는 대상 자체는 변경이 가능하다. 변경이 불가능한 객체를 가리키는 반복자가 필요하다면 const_iterator를 쓰면 된다.
``` cpp
std::vector<int> vec;
const std::vector<int>::iterator iter = vec.begin();
*iter = 10; // OK, iter가 가리키는 대상 변경.
++iter;      // ERROR! iter는 const임.

std::vector<int>::const_iterator cIter = vec.begin();
*iter = 10; // ERROR! *cIter가 상수임.
++iter;      // OK, cIter를 변경하기 때문.
```
+ 함수에 쓸때 정말 강력하다. 함수 선언문에 있어서 const는 함수 반환값, 매개변수, 멤버 함수 앞에 붙을 수 있고, 함수 전체에 대해 const의 성질을 붙일 수 있다.
```cpp
// 반환값에 const를 붙이면 착한 성격을 지킬 수 있다 !
class Rational(...);
const Rational operator* (const Rational& lhs, const Rational* rhs);
if(a * b = c) ... // ERROR! 비교(==)하려고 했는데 실수 !
```
* 훌륭한 사용자 정의 타입의 특징 중 하나는 기본 타입과의 쓸데없는 비호환성을 피한다는 것이다. 위처럼 두 수의 곱에 대입 연산이 되도록 놓아주는 것이 **쓸데없는** 경우다. operator*의 반환 값을 const로 정해 놓으면 이런 경우를 미연에 방지할 수 있다.

* const매개변수는 const타입의 지역 객체와 특성이 똑같다. 그리고 이것 역시 가능한 항상 사용하는 것이 좋다. 매개 변수 혹은 지역 객체를 수정할 수 없게 하는 것이 목적이라면 반드시 const로 선언하도록 하자.

#### 1.3.1. 상수 멤버 함수
**[목적 1]** 이 멤버 함수를 통해 객체를 변경할 수 있는지, 없는지 알린다.

**[목적 2]** 실행 성능을 높인다. C++ 프로그램의 실행 성능을 높이는 핵심 기법 중 하나가 객체 전달을 **상수 객체에 대한 참조자**로 진행하는 것이다. 이 기법이 사용되려면 상수 상태로 전달된 객체를 조작할 수 있는 const 멤버 함수, 즉 상수 멤버 함수가 준비되어 있어야 한다.



**[const 멤버 함수의 의미]**

**비트수준 상수성(bitwise constness, 또는 물리적 상수성physical
constness)**: 

어떤 멤버 함수가 그 객체의 어떤 데이터 멤버도 건드리지 않아야 한다(정적 멤버 제외). 다만 다음의 경우에는 const를 사용한 의도에는 벗어나지만 비트수준 상수성을 통과한다.
``` cpp
class CTextBlock{
    public:
    ...
    // 내부 데이터 참조자를 반환하게 됨.
    // 멤버 객체를 이 함수에서는 변경하진 않아서 컴파일 에러는 안뜸.
    char& operator[](std::size_t position) const
    { return pText[position];} // 참조자 리턴받은걸로 외부에서 변경 가능.
    
    private:
    char* pText;
}
```
**개념적/논리적 상수성(logical constness)**: 

비트수준 상수성이 위의 경우를 잡지 못하는 경우를 보완하기 위한 개념이다. 상수 멤버 함수라고 해도 사용자 측에서 변경을 알아채지 못한다면 상수 멤버의 자격이 있다는 것이다.
```cpp
class CTextBlock{
    public: ...
    std::size_t length() const;
    private:
    char *pText;
    mutable std::size_t textlength;    // mutable이 붙은 멤버들은
    mutable bool length lengthIsValid; // 어떤 순간에도 수정 가능.
    }
std::size_t CTextBlock::length() const
{
    if(!lengthIsValid){
        textLength = std::strlen(pText); // const 멤버 함수지만
        lengthIsValid = true;            // mutable멤버를 변경해도
    }                                    // 사용자는 알 수 없음.
    return textlength;
}
```

**상수/비상수 멤버 함수에서 코드 중복 피하기**

캐스팅을 활용하면 비상수 멤버 함수가 상수 버전을 호출하도록 할 수 있다. 물론 캐스팅이 좋은 아이디어는 아니지만, 코드 중복으로 야기되는 컴파일 시간, 유지보수, 코드 크기 부풀림 등은 감당하기 힘들다.
```cpp
class TextBlock(){
    public: ...
    const char& operator[](std::size_t position) const
    {... return text[position];}

    // 비상수 []가 상수 버전을 호출하도록.
    char& operator[](std::size_t position)
    {
        return
        // 2: 반환 값에서 const 제거
        const_cast<char&>( 
        // 1: *this에 const 붙여서 상수 버전 호출 유도
            static_cast<const textBlock&>(*this)[position]
        );
    }
}
```

### 1.4. 객체의 초기화
* 초기화 리스트에서 가능한 모든 것을 초기화하는 습관을 들여라.
* 클래스는 보통 여러 생성자를 갖는데, 늘어진 초기화 리스트가 보기 싫다면 별도의 함수에서 대입 연산을 몰아놓고 호출하는 것도 나쁘지 않다. 멤버의 초기값을 파일이나 DB에서 읽어오는 경우 유용하다.
* 멤버 객체들은 선언 순으로 초기화 되기 때문에 초기화 리스트에서도 순서를 맞춰두는 편이 좋다.
* 예전엔 다른 파일(다른 번역 단위)의 비지역 정적 변수가 초기화 되지 않아서 ~~전역 정적 변수 초기화 순서가 꼬여서~~ 문제가 발생하던 경우도 있는 것 같다. 때문에 지역 정적 싱글톤으로 참조해서 초기화 문제를 해결한 방법을 설명한다. 멀티스레드에선 시동단계에서 전부 초기화하라고 한다. 더블체킹(락)과 싱글에서 전부 초기화 중 택1하면 되겠다.

---

## 2. 생성자, 소멸자 및 대입 연산자

### 2.1. C++에서 암시적으로 생성되는 함수들
```cpp
class Empty(); // 이런 클래스를 만들었다면
class Empty(){ // 컴파일러가 훑었을 때 필요에 따라 이것과 같다.
    public:
    // 아래는 모두 inline함수
    Empty(){...} // 기본 생성자
    Empty(const Empty& rhs){...} // 기본 복사 생성자
    ~Empty(){...}  // 소멸자
    Empty& operator=(const Empty& rhs){...} // 복사 대입
}
```
* 클래스에 생성자가 이미 있다면(인자 없는 버전이 아니더라도) 기본 생성자는 만들어지지 않는다.
* 참조자를 멤버로 가지고 있는 클래스에 대입 연산을 지원하려면 직접 복사 대입 연산자를 정의해야한다.

### 2.2. 암시적 생성 함수가 필요없다면 사용을 금하기
* private에 넣어도 좋지만 멤버 함수나 friend가 호출할 수 있는 허점이 있다.
* private으로 넣되 선언만 한다면 사용자가 복사를 시도했을때 컴파일러가 막고(외부접근불가), 내가 멤버나 friend로 복사하면 링커에서 막힌다.
```cpp
class Home{
    public: ...
    private: ...
    Home(const Home&);
    Home& operator=(const Home&);
}
// 또는 아래 클래스 상속
class Uncopyable{
protected:
Uncopyable(){} // 생성과 소멸 허용
~Uncopyable(){}
private:
Uncopyable (const Uncopyable&); // 그러나 복사는 방지
Uncopyable& operator=(const rhs&);
}
class Home_Ver2: private Uncopyable {
...
}
```
* 위 코드의 Uncopyable은 public일 필요가 없으며 소멸자는 virtual일 필요가 없다.
* Uncopyable은 다중 상속으로 갈 가능성이 크다. 다중 상속 시에는 공백 기본 클래스 최적화가 돌아가지 못할 때가 종종 있다.
* Boost 라이브러리에는 Uncopyable과 같은 역할의 클래스가 있다.

### 2.3. 다형성을 가진 기본 클래스에서는 소멸자를 가상 소멸자로 선언하기
* C++ 규정에서는 기본 클래스 포인터(부모)를 통해 파생 클래스 객체(자식)이 삭제된 때 그 기본 클래스에 비가상 소멸자가 있으면 정의되지 않은 동작이 발생한다고 명시한다.
* 가상 함수를 하나라도 가진 클래스는 가상 소멸자를 가져야 하는게 대부분이다.
* 가상 소멸자를 갖고 있지 않은 클래스는 기본 클래스로 사용될 의지가 없다는 의미로 받아들인다.
```cpp
class SpecialString: public std::string // string에는 가상 소멸자가 없음
{...};
// 이러한 경우는 가상 소멸자가 없는 클래스라면 전부 문제
```
* 어느 경우를 막론하고 소멸자를 virtual로 선언하는건 좋지않다. 만약 64비트 크기의 클래스에 대해 소멸자를 가상으로 선언하면 vptr이 끼어들어 64비트 레지스터에 딱 맞게 적재될 기회가 소멸한다.
* 경우에 따라 추상 클래스를 만들 때 마땅히 넣을 순수 가상 함수가 없다면 순수 가상 소멸자를 만들기도 한다.
```cpp
class AWOV{
public:
virtual ~AWOV() = 0;
}
AWOV::~AWOV(){} // 순수 가상 소멸자의 정의
                // 소멸자라서 결국 기본 클래스의 소멸자를 호출하기 위해
                // 컴파일러가 ~AWOV()의 호출 코드를 만듦.
                // 이때 본문이 없다면 링커 에러 발생
```

### 2.4. 예외가 소멸자를 떠나지 못하도록 잡아두기
* 소멸자에서 예외가 빠져나가면 안된다. 만약 소멸자 안에서 호출된 함수가 예외를 던질 가능성이 있다면, 어떤 예외이든지 소멸지에서 모두 받아낸 후에 삼키든지 프로그램을 종료시켜야한다.
* 어떤 클래스의 연산이 진해되다 던진 예외에 대해 사용자가 반응할 필요가 있다면 해당 연산을 제공하는 함수는 반드시 보통의 함수(소멸자가 아닌)이어야 한다.
``` cpp
class DBConnection{
    public:
    ...
    static DBConnection create(); // 매개변수 생략. DB연결정보들일듯
    void close(); // 연결 닫기.
                  // 실패하면 예외 던지기.
};

class DBConn{
    public:
    ...
    void close() // 사용자가 호출해서 연결을 닫을수도 있음
    {
        db.close();
        closed = true;
    }

    ~DBConn()
    {
        if(!closed) // 사용자가 닫지 않았다면 자동 닫기
        try{
        db.close(); // <- 예외가 발생할 수 있는 함수 !!
                    // 하지만 소멸자에서 비롯되는 예외는 아님
    }
        catch(...){
            // close 호출 실패 로그
            // !!! 여기서 바로 종료할지 이어서 실행할지 결정 필요 !!!
        }
    }

    private:
    DBConnection db;
    bool closed;
};
```
* 예외 삼키기를 선택한 경우 발생한 예외를 무시한 뒤라도 프로그램이 신뢰성 있게 실행을 지속할 수 있어야 한다. 정말 중요.

### 2.5. 객체 생성 및 소멸 과정 중 가상 함수를 호출하지 말자
* 기본 클래스 부분이 생성되는 동안은 그 객체의 타입은 기본 클래스이다. 호출되는 가상 함수는 물론, RTTI(이를테면 dynamic_cast)를 사용한다 해도 모두 기본 클래스 타입의 객체로 취급한다.
* 생성 및 소멸 과정에서 가상 함수를 호출할 필요가 있다면 비가상 멤버 함수로 바꾸고 필요한 로그 정보를 기본 클래스의 생성자로 넘기는 규칙을 만들어 해결할 수 있다. (많은 방법 중 하나)
```cpp
class TransactionP{
    public:
    explicit Transaction(const std::string& logInfo);
    // 기존 가상 함수 -> 비가상 멤버 함수로 변경
    void logTransaction(const std::string& logInfo) const; 
};

Transaction::Transaction(const std::string& logInfo)
{
    ...
    logTransaction(logInfo); // 이제는 비가상함수를 호출함.
}

class BuyTransaction: public Transaction{
    public:
    // 초기화리스트 늘어지는걸 함수로 만든 사례
    BuyTransaction(params..)
        : Transaction(createLogString(params..)){...}
    ...
    private:
    // 정적 멤버 함수기 때문에 파생 객체의 미초기화된 멤버를 건드릴 수 없음. (this를 안씀)
    static std::string createLogString(params..);
};
```

### 2.6. 대입 연산자는 *this의 참조자를 반환하게 하자
* C++의 대입 연산은 여러 개가 사슬처럼 얽힐 수 있게 만들어졌다(x = y = z = 15;). 이 동작이 가능하려면 대입 연산자가 좌변 인자에 대한 참조자를 반환하도록 구현됐을 것이다. 이는 일종의 관례인데, 대입 연산자를 정의하려면 이 관례를 지키는 것이 좋다.
* 관례기 때문에 지키지않으면 컴파일이 되지 않는건 아니지만 모든 기본타입 또는 라이브러리에 속한 타입(string, vector, complex, tr1::shared_ptr 등)에서도 따르고 있다.
```cpp
class Widget{
    public:
    ...
    Widget& operate+=(const Widget& rhs) // +=, -=, *=등도 예외는 아님
    {
        ...
        return *this;
    }
    Widget& operator=(const Widget& rhs)
    {
        ...
        return *this;
    }
    Widget& operator=(int rhs) // 대입연산자의 매개변수가
    {                          // 일반적이지 않은 경우도 동일
        ...
        return *this;
    }
}
```
### 2.7. operator=에 자기대입에 대한 처리를 빠뜨리지 말자
가끔 아래와 같은 중복참조 때문에 자기대입이 생긴다.
```cpp
Widget w;
w = w;
a[i] = a[j]; // i와 j가 같을 경우
*px = *py; // 같은 주소를 가리킬 경우
```

그래서 COW같은 동작으로 해결하자고 한다.
```cpp
Widget& Widget::operator=(const Widget& rhs)
{
    Bitmap *pOrig = pb; // pb는 멤버 포인터 객체
    pb = new Bitmap(*rhs.pb); // 어차피 new는 써야하는듯
    delete pOrig;
    return *this; // Copy And Swap
}
```
위 코드는 자기대입 현상을 완벽히 처리하고 있다. 성능이 걱정되서 그냥 상단에`if(this == &rhs)`를 붙이고 싶지만 프로그램에서 자기대입이 애초에 많이 일어나지 않고, `if`도 분기를 만들어서 실행 시간이 떨어지고 CPU 명령어 선행인출, 캐시, 파이프라이닝의 효과도 떨어뜨릴 수 있다.


### 2.8. 객체의 모든 부분을 빠짐없이 복사하자
객체 복사 함수(복사 생성자, 복사 대입 연산자)를 사용자 정의하면 대놓고 잘못되도 컴파일러는 경고를 거의 띄워주지 않는다. 사용자는 새로운 멤버를 추가할 때마다 복사 함수에서 새 멤버를 신경써야하고, 이는 상속관계에서 문제를 발생시킨다.

파생 클래스에 대한 복사 함수를 만든다고 하면 기본 클래스 부분의 복사를 빠뜨리지 않도록 각별히 주의해야 한다. 물론 기본 클래스의 멤버는 private일 가능성이 높으므로 파생 클래스의 복사 함수 내에서 기본 클래스의 복사 함수(에 대응되는)를 호출하도록 만들면 된다.

```cpp
// 기본 클래스의 복사 생성자 호출
PriorityCustomer::PriorityCustomer(const PriorityCustomer& rhs): Customer(rhs),priority(rhs.priority)
{
    ...
}
PriorityCustomer& PriorityCustomer::operator=(const PriorityCustomer& rhs)
{
    ...
    Custommer::operator=(rhs); // 기본 클래스 대입
    priority = rhs.priority;
    return *this;
}
```

> ⚠️ 클래스의 복사 생성자와 복사 대입 연산자는 본문이 비슷하게 나오는 경우가 많아서 한쪽에서 다른 쪽을 호출하려고 하는 시도를 하려는 경우가 있는데, 하지 말자.
> 단, 겹치는 부분을 별도의 private 멤버 함수(init어쩌구)로 두고 호출하는건 괜찮다.