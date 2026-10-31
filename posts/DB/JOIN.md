## 목차
- [목차](#목차)
- [1. 왜 필요할까?](#1-왜-필요할까)
- [2. INNER JOIN: 양쪽에 짝이 있는 행만](#2-inner-join-양쪽에-짝이-있는-행만)
- [3. 행이 불어난다! (1:N)](#3-행이-불어난다-1n)
- [4. LEFT JOIN: 왼쪽은 전부 남긴다](#4-left-join-왼쪽은-전부-남긴다)
  - ["없는 것 찾기" 패턴](#없는-것-찾기-패턴)
- [5. LEFT JOIN의 함정: ON과 WHERE](#5-left-join의-함정-on과-where)
- [6. 여러 테이블 JOIN과 N:M](#6-여러-테이블-join과-nm)
- [7. SELF JOIN: 같은 테이블끼리](#7-self-join-같은-테이블끼리)
- [8. CROSS JOIN: 모든 조합](#8-cross-join-모든-조합)
- [9. JOIN의 내부 동작](#9-join의-내부-동작)
- [10. 게임에서?](#10-게임에서)
- [11. 질문](#11-질문)


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


## 5. LEFT JOIN의 함정: ON과 WHERE
```sql
-- ✗ 무기 없는 캐릭터가 사라짐
SELECT c.name, t.name
FROM characters c
LEFT JOIN inventory i     ON i.character_id = c.character_id
LEFT JOIN item_template t ON t.item_id = i.item_id
WHERE t.type = 'Weapon';
```

JOIN(FROM)이 끝난 뒤 WHERE가 실행된다. 무기가 없는 캐릭터는 `t.type`이 NULL인데, `NULL = 'Weapon`은 UNKNOWN이라 WHERE에서 걸러진다. 결국 LEFT JOIN이 INNER JOIN처럼 동작한다.

## 6. 여러 테이블 JOIN과 N:M

```sql
SELECT c.name, i.slot, t.name, i.count
FROM characters c
JOIN inventory i     ON i.character_id = c.character_id
JOIN item_template t ON t.item_id = i.item_id;
```
캐릭터와 아이템 원본은 N:M이라 중간 테이블(inventory)을 거쳐 두 번 JOIN한다.

## 7. SELF JOIN: 같은 테이블끼리
```sql
SELECT me.name, fr.name AS friend_name
FROM friend f
JOIN characters me ON me.character_id = f.character_id
JOIN characters fr ON fr.character_id = f.friend_character_id;
```
friend에는 ID만 있어서 이름을 보려면 characters를 두 번, 서로 다른 별칭으로 붙여서 JOIN했다.

## 8. CROSS JOIN: 모든 조합
ON 없이 붙이면 모든 행 * 모든 행이 된다. ON을 빠뜨린 실수에서 볼 수 있다. 캐릭터 8 * 인벤토리 19 = 152행 같은 상황이 나오면 의심해보자.

## 9. JOIN의 내부 동작
MySQL의 기본은 Nested Loop Join이다.
```
for (캐릭터 c : characters)               // 바깥 테이블 (드라이빙)
    for (인벤토리 i : c와 짝이 맞는 행)     // 안쪽 테이블
        결과에 추가
```
안쪽 루프에서 짝을 찾을 때 조인 컬럼에 인덱스가 있으면 바로 찾고, 없으면 매번 전체를 훑는다. 때문에 **조인 컬럼에는 인덱스가 필수**이다.

인덱스가 없을 때 Hash Join도 쓴다.

## 10. 게임에서?
접속 중인 캐릭터의 데이터는 로그인할 때 몇 번의 쿼리로 메모리에 올려놓고 쓰는 게 일반적이다. 그래서 무거운 JOIN은 실시간 처리 경로보다 로그인 로딩, 운영 툴, 통계에서 주로 쓴다.

## 11. 질문

- INNER JOIN과 LEFT JOIN의 차이는?
- LEFT JOIN 후 WHERE에 오른쪽 테이블 조건을 걸면 어떻게 되나?
- JOIN은 어떻게 동작하고, 왜 조인 컬럼에 인덱스가 필요한가?
- "한 번도 구매되지 않은 아이템"을 찾는 쿼리는?