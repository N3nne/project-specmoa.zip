DELETE FROM questions;
DELETE FROM reviews;

INSERT INTO questions (
  user_id,
  qualification_code,
  title,
  content,
  like_count,
  comment_count,
  view_count,
  is_popular
) VALUES
(
  'ecce50e8-50dc-41db-8bdf-1d065f5b33da',
  '1320',
  '정보처리기사 비전공자도 필기 합격 가능할까요?',
  '비전공자 기준으로 정보처리기사 필기를 준비하고 있습니다. 개념을 어느 정도까지 이해해야 하는지, 기출 위주로 공부해도 되는지 궁금합니다.',
  42,
  18,
  236,
  true
),
(
  'ecce50e8-50dc-41db-8bdf-1d065f5b33da',
  '9750',
  '청소년지도사 면접은 어떤 식으로 준비하면 좋을까요?',
  '면접 경험이 많지 않아서 답변 구조를 어떻게 잡아야 할지 고민입니다. 실제 질문 유형이나 준비 팁이 있다면 공유 부탁드립니다.',
  17,
  6,
  88,
  true
);

INSERT INTO reviews (
  user_id,
  qualification_code,
  title,
  content,
  study_period_text,
  tip_summary,
  like_count,
  view_count,
  is_featured
) VALUES
(
  'ecce50e8-50dc-41db-8bdf-1d065f5b33da',
  '1320',
  '정보처리기사 2개월 합격 후기',
  '처음 한 달은 개념 정리에 집중하고, 이후 한 달은 기출문제를 반복해서 풀었습니다. 특히 데이터베이스와 운영체제 파트는 오답노트를 따로 만들어 자주 복습한 것이 도움이 됐습니다.',
  '2개월',
  '기출문제 반복과 오답노트 정리가 가장 효과적이었습니다.',
  53,
  412,
  true
),
(
  'ecce50e8-50dc-41db-8bdf-1d065f5b33da',
  '9750',
  '청소년지도사 필기부터 면접까지 준비 후기',
  '필기는 요약서와 기출문제를 병행했고, 면접은 스터디를 만들어 실제처럼 답변 연습을 했습니다. 청소년 관련 정책과 현장 사례를 함께 정리해두면 답변할 때 훨씬 수월합니다.',
  '6주',
  '스터디를 통해 말로 풀어보는 연습을 꾸준히 한 것이 큰 도움이 됐습니다.',
  21,
  167,
  true
);
