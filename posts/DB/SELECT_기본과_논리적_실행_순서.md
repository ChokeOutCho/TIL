## 목차
- [목차](#목차)
- [1. SELECT 기본 구조](#1-select-기본-구조)
- [2. WHERE 조건](#2-where-조건)
  - [AND/OR 우선순위](#andor-우선순위)
- [3. 논리적 실행 순서](#3-논리적-실행-순서)
  - [WHERE에서는 SELECT 별칭(as)을 못쓴다.](#where에서는-select-별칭as을-못쓴다)
- [4. ORDER BY](#4-order-by)
- [5. DISTINCT와 GROUP BY](#5-distinct와-group-by)
- [6. SELECT \* 는 피하자](#6-select--는-피하자)


## 1. SELECT 기본 구조

```sql
SELECT name, class, level          -- 어떤 컬럼을
FROM characters                    -- 어느 테이블에서
WHERE level >= 40                  -- 어떤 행만
ORDER BY level DESC                -- 어떤 순서로
LIMIT 3;                           -- 몇 개까지
```

## 2. WHERE 조건

|조건|예|메모|
|---|---|---|
|비교	|level >= 50, class <> 'Mage'	|<>와 !=는 같음|
|범위	|level BETWEEN 30 AND 50	|양 끝 포함|
|목록	|class IN ('Warrior', 'Mage')	|OR 여러 개를 줄인 것|
|패턴	|name LIKE '찬%'	|%는 0글자 이상, _는 정확히 1글자|
|NULL	|guild_id IS NULL	|= NULL은 항상 UNKNOWN (1일 차)|

### AND/OR 우선순위
C++의 &&, ||처럼 AND가 OR보다 먼저 묶인다.
```sql
-- 괄호 없음: Warrior 전부 + (레벨 50 이상인 Mage)
WHERE class = 'Warrior' OR class = 'Mage' AND level >= 50
-- 괄호 있음: (Warrior 또는 Mage) 중 레벨 50 이상
WHERE (class = 'Warrior' OR class = 'Mage') AND level >= 50
```
- 괄호가 없다면 OR가 먼저 묶여 레벨이 50미만인 Warrior가 끼어든다.
- `IN`을 사용하면 OR를 사용하지 않기 때문에 이런 함정 자체가 생기지 않는다. `WHERE class IN ('Warrior', Mage') AND level >= 50`

## 3. 논리적 실행 순서

```
작성 순서:  SELECT → FROM → WHERE → GROUP BY → HAVING → ORDER BY → LIMIT
```
```
실행 순서:  FROM → WHERE → GROUP BY → HAVING → SELECT → DISTINCT → ORDER BY → LIMIT
```

|단계	|하는 일|
|---|---|
|FROM	|테이블을 정함 (JOIN도 여기서)|
|WHERE	|조건에 맞는 행을 거름|
|GROUP BY	|특정 컬럼 값마다 묶음|
|HAVING	|조건에 맞는 그룹을 거름|
|SELECT	|출력할 컬럼과 계산식을 만듦 (별칭이 여기서 생김)|
|DISTINCT	|중복 행 제거|
|ORDER BY	|정렬|
|LIMIT	|자르기|

### WHERE에서는 SELECT 별칭(as)을 못쓴다.
ㅇㅇ 못쓴다.
- ORDER BY에서는 쓸 수 있겠다.
- 옵티마이저가 인덱스를 써서 정렬을 건너뛰는 등 실제로 다르게 실행할 수는 있지만, 결과는 이 순서로 처리한 것과 같다고 보장된다.

## 4. ORDER BY
정렬 기준이 같은 행끼리의 순서는 보장되지 않는다.

랭킹을 만든다고 하면 다음과 같은 규칙이 필요할 수 있다.
- 1) 레벨 높은 순
- 2) 같으면 그 레벨에 먼저 도달한 사람 우선
- 3) 그래도 같다면 PK로

## 5. DISTINCT와 GROUP BY
- `SELECT DISTINCT item_id FROM inventory` -> 중복 제거
> GROUP BY로 같은 효과를 내려고 한 적이 있었다. 
> PK는 중복이 없어서 의미 없다.

## 6. SELECT * 는 피하자
- 필요없는 컬럼은 최대한 걸러 주자. (전송 용량 커짐)
- 커버링 인덱스를 쓸 수 없다.
- 컬럼이 추가되면 서버 코드에서 컬럼 위치로 읽던 코드가 어긋날 수 있다.
