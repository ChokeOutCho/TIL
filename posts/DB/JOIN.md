## 목차
- [목차](#목차)
- [1. 왜 필요할까?](#1-왜-필요할까)
- [2. INNER JOIN: 양쪽에 짝이 있는 행만](#2-inner-join-양쪽에-짝이-있는-행만)
- [3. 행이 불어난다! (1:N)](#3-행이-불어난다-1n)
- [4. LEFT JOIN: 왼쪽은 전부 남긴다](#4-left-join-왼쪽은-전부-남긴다)
  - ["없는 것 찾기" 패턴](#없는-것-찾기-패턴)


## 1. 왜 필요할까?
데이터를 중복을 없애기 위해 계정, 캐릭터, 인벤토리, 아이템 원본을 테이블로 나눠 저장했다고 치면, "한 유저의 인벤토리를 아이템 이름과 함께 볼 때" 여러 테이블에 흩어진 정보를 다시 합칠 방법이 필요하다. 

즉, JOIN은 **키 값으로 이어진 관계를 따라가는 도구**이다.

## 2. INNER JOIN: 양쪽에 짝이 있는 행만

```sql
SELECT c.name, a.login_id
FROM characters c
JOIN account a ON c.account_id = a.account_id;
```
- `c`와 `a`는 별칭이다. 테이블이 여러 개라면 어느 테이블의 컬럼인지 밝혀야 해서 필수에 가깝다.
- `JOIN`만 사용하면 `INNER JOIN`이다.
- 짝이 없는 행은 양쪽 모두에서 빠진다.


## 3. 행이 불어난다! (1:N)
계정 하나에 캐릭터가 2개라면, 계정과 캐릭터를 JOIN했을 때 계정 하나에 두 줄이 나온다. JOIN의 결과 행 수는 N쪽 기준이다.

JOIN한 뒤 SUM을 하면 값이 부풀려지는 사고가 날 수 있다.

## 4. LEFT JOIN: 왼쪽은 전부 남긴다
```sql
SELECT a.login_id, c.name
FROM account a
LEFT JOIN characters c ON c.account_id = a.account_id;
```
- 왼쪽(account)의 행은 짝이 없어도 모두 남고, 오른쪽 컬럼은 NULL로 채워진다.
- 캐릭터가 없는 account는 name=NULL로 나온다.
> `RIGHT JOIN`은 방향만 반대이고, 테이블 순서를 바꿔 LEFT JOIN으로 쓰는 게 읽기 쉬워 실무에서는 거의 안쓴다고 한다.


### "없는 것 찾기" 패턴
```sql
SELECT a.login_id
FROM account a
LEFT JOIN characters c ON c.account_id = a.account_id
WHERE c.character_id IS NULL -- 짝이 없었던 행만
```
"캐릭터가 하나도 없는 계정", "아무도 안 가진 아이템"처럼 존재하지 않음을 찾을 때 쓴다.




