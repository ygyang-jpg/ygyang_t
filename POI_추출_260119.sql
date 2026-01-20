SELECT
    A.POI_ID, -- DB내부 ID
    REPLACE(A.FNAME,'/','') AS '대표명칭', -- 브랜드명
    REPLACE(A.CNAME,'/','') AS '지점명칭', -- 매장명
    '' AS '추가1',
    '' AS '추가2',
    A.ADDR AS '지번주소_동리',
    A.PRIMARY_BUN AS '지번주소_본번',
    A.SECONDARY_BUN AS '지번주소_부번',
    A.SAN_BUN AS '지번주소_산',
    A.IFLOOR AS 'POI_층수_저층_고층',
    A.TELE_A AS '전화번호_지역번호_첫2~4자리',
    A.TELE_B AS '전화번호_중간번호_3~4자리',
    A.TELE_C AS '전화번호_끝번호_4자리',
    C.ADDRESS AS '도로명주소_도로명',
    CASE
        WHEN C.BULD_SLNO IS NULL OR C.BULD_SLNO = '' THEN CAST(C.BULD_MNNM AS VARCHAR)
        ELSE CAST(C.BULD_MNNM AS VARCHAR) + '-' + CAST(C.BULD_SLNO AS VARCHAR)
    END AS '도로명주소_건물번호',
    '' AS '도로명주소_상세주소',
    '' AS '층수',
    D.PARKING_YN AS '주차유무',

    -- [E 테이블] 휴무일 합치기
    (SELECT STRING_AGG(CONVERT(VARCHAR, E.DATE, 23), ', ')
     FROM PTN_OFFDAY_DATE E
     WHERE E.POI_ID = A.POI_ID
       AND E.DATE >= '2025-12-01'
       AND E.DATE <= '2026-01-19') AS '휴무일',

    -- [F 테이블] 영업시간 합치기 (00:00 형식 적용)
(
    SELECT STRING_AGG(
        CASE F.WEEKDAY
            WHEN 1   THEN '월'
            WHEN 2   THEN '화'
            WHEN 4   THEN '수'
            WHEN 5   THEN '월수'
            WHEN 6   THEN '화수'
            WHEN 7   THEN '월화수'
            WHEN 8   THEN '목'
            WHEN 9   THEN '금'
            WHEN 10  THEN '화목'
            WHEN 11  THEN '월화목'
            WHEN 12  THEN '수목'
            WHEN 13  THEN '월수목'
            WHEN 14  THEN '화수목'
            WHEN 15  THEN '월화수목'
            WHEN 16  THEN '금'
            WHEN 17  THEN '월금'
            WHEN 18  THEN '화금'
            WHEN 20  THEN '수금'
            WHEN 21  THEN '월수금'
            WHEN 23  THEN '월화수금'
            WHEN 24  THEN '목금'
            WHEN 26  THEN '화목금'
            WHEN 27  THEN '월화목금'
            WHEN 29  THEN '월수목금'
            WHEN 30  THEN '화수목금'
            WHEN 31  THEN '월화수목금'
            WHEN 32  THEN '토'
            WHEN 42  THEN '화목토'
            WHEN 47  THEN '월화수목토'
            WHEN 48  THEN '금토'
            WHEN 55  THEN '월화수금토'
            WHEN 59  THEN '월화목금토'
            WHEN 62  THEN '화수목금토'
            WHEN 63  THEN '월화수목금토'
            WHEN 64  THEN '일'
            WHEN 79  THEN '월화수목일'
            WHEN 93  THEN '월수목금일'
            WHEN 95  THEN '월화수목금일'
            WHEN 96  THEN '토일'
            WHEN 112 THEN '금토일'
            WHEN 117 THEN '월수금토일'
            WHEN 119 THEN '월화수금토일'
            WHEN 121 THEN '월목금토일'
            WHEN 123 THEN '월화목금토일'
            WHEN 124 THEN '수목금토일'
            WHEN 125 THEN '월수목금토일'
            WHEN 126 THEN '화수목금토일'
            WHEN 127 THEN '월화수목금토일'
            ELSE '기타'
        END
        + ' '
        + RIGHT('00' + CAST(F.ST_HOUR AS VARCHAR(2)), 2)
        + ':' +
        RIGHT('00' + CAST(F.ST_MIN AS VARCHAR(2)), 2)
        + ' ~ '
        + RIGHT('00' + CAST(F.ED_HOUR AS VARCHAR(2)), 2)
        + ':' +
        RIGHT('00' + CAST(F.ED_MIN AS VARCHAR(2)), 2),
        ', '
    )
    FROM PTN_WORK_HOUR_REGULAR F
    WHERE F.POI_ID = A.POI_ID
) AS '영업시간'

FROM vPOI_I_COMMON_ALL_GRS A
JOIN POI_MAIN_ETC..[22y_2150_INDEX_220401] B ON LEFT(A.TILE_ID, 4) = B.MAP_ID
LEFT JOIN PTN_ROAD_ADDR C ON A.POI_ID = C.POI_ID
LEFT JOIN PTN_PARKING D ON A.POI_ID = D.POI_ID
WHERE B.관할업체 = '티아이랩'
  AND REPLACE(A.FNAME, '/', '') IN (
    '60계치킨', 'AK플라자', 'BHC치킨', 'CGV', 'CU', 'GS25', 'KFC', 'NC백화점', '갤러리아백화점', '공임나라', '공차', '굽네치킨',
    '기아오토큐', '기아', '나인블럭', '노브랜드버거', '다이소', '달콤커피', '던킨', '도미노피자', '뚜레쥬르', '롯데리아', '롯데마트', '롯데백화점', '롯데시네마',
    '롯데아울렛', '마일레오토서비스', '만도플라자', '맘스터치', '맥도날드', '메가박스', '메가MGC커피', '미스터피자', '바나프레소', '배스킨라빈스31', '현대블루핸즈', '빕스',
    '빽다방', '상무초밥', '샤브20', '샤브마니아', '세븐일레븐', '소담촌', '쉐이크쉑', '스타벅스', '스피드메이트', '신세계백화점', '쌍교숯불갈비', '써브웨이', '씨스페이스',
    '아웃백스테이크하우스', '아파트지인', '엔제리너스커피', '오봉집', '오토오아시스', '이디야', '이마트', '이마트24', '이마트에브리데이', '이차돌', '제주은희네해장국',
    '짬뽕지존', '채선당', '초중고', '카페베네', '커피빈', '컴포즈커피', '코스트코홀세일', '탐앤탐스', '투썸플레이스', '트레이더스홀세일클럽', '파리바게뜨', '파스쿠찌',
    '폴바셋', '프랭크버거', '피자헛', '하나로마트', '할리스커피', '현대백화점', '현대프리미엄아울렛', '현대자동차', '홈플러스', '홈플러스익스프레스'
  )
ORDER BY A.POI_ID;