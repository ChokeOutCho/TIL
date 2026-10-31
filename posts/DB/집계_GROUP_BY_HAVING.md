- [1. 집계 함수](#1-집계-함수)
- [2. GROUP BY](#2-group-by)
- [3. WHERE, HAVING](#3-where-having)
- [4. 팬아웃: JOIN 후 집계하면 값이 부풀려진다!!!](#4-팬아웃-join-후-집계하면-값이-부풀려진다)
- [5. 게임 서버에서는](#5-게임-서버에서는)
- [6. 질문](#6-질문)


## 1. 집계 함수
여러 행을 하나의 값으로 줄인다.

|함수|의미|NULL 처리|
|---|---|---|
|COUNT(*)|행 수|행 자체를 셈, NULL 상관 없음|
|COUNT(컬럼)| 그 컬럼이 NULL이 아닌 행 수| NULL 제외|
|COUNT(DISTINCT 컬럼)| 서로 다른 값의 수|NULL제외|
|SUM, AVG, MIN, MAX| 합계, 평균, 최소, 최대|NULL 제외|

- AVG는 NULL을 0으로 치지 않고 아예 뺀다. 0으로 치고 싶다면 `AVG(COALESCE(gold, 0))`
- 행이 하나도 없으면 SUM은 0이 아니라 NULL이다. 서버 코드에서 0을 기대했다면 버그이다. `COALESCE(SUM(gold), 0)`
- COUNT(*)와 COUNT(1)은 MySQL에서 똑같다. "COUNT(1)이 더 빠르다"는 오래된 속설이다.

## 2. GROUP BY
같은 값끼리 묶어서 그룹마다 집계한다.

```sql
SELECT class, COUNT(*) AS cnt, AVG(level) AS avg_level
FROM characters
GROUP BY class;
```
SELECT에는 GROUP BY한 컬럼이나 집계 함수만 올 수 있다.

```sql
SELECT class, name, COUNT(*) FROM characters GROUP BY class;   -- ✗ 에러
```

Warrior 그룹에 캐릭터가 셋인데, name은 그 중 누구 이름을 보여 줘야 할지 정할 수 없다.
> MySQL 5.7부터 기본으로 켜진 `ONLY_FULL_GROUP_BY`모드가 이걸 에어로 막는다. 이전엔 아무 값이나 골라 보여줬다.

예외: PK로 묶으면 그 행의 다른 컬럼은 값이 하나로 정해지므로 허용된다.

여러 컬럼으로도 묶을 수 있다. `GROUP BY class, level`은 (직업, 레벨) 조합마다 한 그룹이다.

## 3. WHERE, HAVING
```
FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT
```

| |	WHERE|	HAVING|
|---|---|---|
|시점|	그룹을 만들기 전|	그룹을 만든 후|
|거르는 대상|	행	|그룹|
|집계 함수|	못 씀 (아직 집계 전)|	씀|

```sql
SELECT a.login_id, COUNT(*) AS char_cnt
FROM account a
JOIN characters c ON c.account_id = a.account_id
WHERE a.is_banned = 0            -- 행 조건: 정지 계정 제외
GROUP BY a.account_id, a.login_id
HAVING COUNT(*) >= 2;            -- 그룹 조건: 캐릭터 2개 이상
```

## 4. 팬아웃: JOIN 후 집계하면 값이 부풀려진다!!!
예를 들면, 1:N JOIN 을 한 후 SUM을 하면 같은 값이 여러 번 더해진다.

```sql
SELECT a.login_id, SUM(c.gold), COUNT(i.inventory_id)
FROM account a
JOIN characters c ON c.account_id = a.account_id
JOIN inventory i ON i.character_id = c.character_id
GROUP BY a.account_id, a.login_id;
```
JOIN 결과에 따라 캐릭터 행이 여러 개 나오고, 골드가 여러 번 더해진다.

**해결**
- 따로 집계한 뒤 붙인다. 인벤토리 수는 캐릭터별로 먼저 세고, 그 결과를 JOIN한다(서브쿼리).
- `COUNT(DISTINCT ...)`는 개수에는 쓸 수 있지만, `SUM(DISTINCT gold)`는 오답이다. 서로 다른 캐릭터의 골드가 우연히 같으면 하나로 합쳐진다.

## 5. 게임 서버에서는
- 경제 모니터링: 서버 전체 골드 총량, 아이템별 총 보유량을 매일 집계해서 인플레이션이나 복사 버그를 감시한다.
- 직업별 평균 레벨, 클래스 밸런스 통계
- 이런 집계는 라이브 DB에 부담을 주므로 보통 읽기 전용 복제 DB나 새벽 배치에서 돌린다.

## 6. 질문
- COUNT(*)와 COUNT(컬럼)의 차이는?
- WHERE와 HAVING의 차이는?
- GROUP BY 하지 않은 컬럼을 SELECT하면 왜 에러가 나나?
- JOIN한 뒤 SUM을 했더니 값이 이상하게 크다. 원인은?
