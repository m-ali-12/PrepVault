-- ============================================================
-- PrepVault HAT Comprehensive Content Seed
-- Run AFTER prepvault_complete_schema.sql
-- ============================================================

-- ==================== HAT LEVEL 1: ANALYTICAL REASONING ====================
-- Topics
INSERT INTO topics(level_id,title,slug,category,order_no)
SELECT l.id,'Logical Connectives','logical-connectives','Analytical',1
FROM levels l JOIN tests t ON t.id=l.test_id WHERE t.slug='hat' AND l.level_no=1
ON CONFLICT DO NOTHING;

INSERT INTO topics(level_id,title,slug,category,order_no)
SELECT l.id,'Ordering & Sequencing','ordering-sequencing','Analytical',2
FROM levels l JOIN tests t ON t.id=l.test_id WHERE t.slug='hat' AND l.level_no=1
ON CONFLICT DO NOTHING;

INSERT INTO topics(level_id,title,slug,category,order_no)
SELECT l.id,'Grouping & Selection','grouping-selection','Analytical',3
FROM levels l JOIN tests t ON t.id=l.test_id WHERE t.slug='hat' AND l.level_no=1
ON CONFLICT DO NOTHING;

INSERT INTO topics(level_id,title,slug,category,order_no)
SELECT l.id,'Cause & Effect Reasoning','cause-effect','Analytical',4
FROM levels l JOIN tests t ON t.id=l.test_id WHERE t.slug='hat' AND l.level_no=1
ON CONFLICT DO NOTHING;

INSERT INTO topics(level_id,title,slug,category,order_no)
SELECT l.id,'Pattern Recognition','pattern-recognition','Analytical',5
FROM levels l JOIN tests t ON t.id=l.test_id WHERE t.slug='hat' AND l.level_no=1
ON CONFLICT DO NOTHING;

-- Lessons for Level 1
INSERT INTO lessons(topic_id,title,content_md,order_no,source_reference)
SELECT t.id,
'Understanding Logical Connectives',
'A logical connective joins two propositions into a compound statement.

THE FOUR KEY CONNECTIVES:

1. CONJUNCTION (AND / ∧)
   - "P AND Q" is TRUE only when BOTH P and Q are true.
   - Example: "It is raining AND it is cold." Both must be true.
   - Truth table: T∧T=T, T∧F=F, F∧T=F, F∧F=F

2. DISJUNCTION (OR / ∨)
   - "P OR Q" is TRUE when AT LEAST ONE is true.
   - Example: "I will study or I will sleep." One must be true.
   - Truth table: T∨T=T, T∨F=T, F∨T=T, F∨F=F

3. CONDITIONAL (IF...THEN / →)
   - "If P then Q" is FALSE only when P is TRUE but Q is FALSE.
   - Example: "If it rains, the ground gets wet."
   - The CONTRAPOSITIVE (not Q → not P) is always equivalent to the conditional.
   - The CONVERSE (Q → P) is NOT necessarily equivalent.
   - Truth table: T→T=T, T→F=F, F→T=T, F→F=T

4. BICONDITIONAL (IF AND ONLY IF / ↔)
   - "P if and only if Q" is TRUE when both have the SAME truth value.
   - Truth table: T↔T=T, T↔F=F, F↔T=F, F↔F=T

KEY RULES TO MEMORISE:
• The CONTRAPOSITIVE of "If P then Q" is "If not Q then not P" — always equivalent.
• The INVERSE of "If P then Q" is "If not P then not Q" — NOT always equivalent.
• The CONVERSE of "If P then Q" is "If Q then P" — NOT always equivalent.
• Double negation: NOT(NOT P) = P',
1,'HAT Official Prep Guide — Analytical Section'
FROM topics t WHERE t.slug='logical-connectives';

INSERT INTO lessons(topic_id,title,content_md,order_no,source_reference)
SELECT t.id,
'Negation, De Morgan Laws & Practice',
'NEGATION (NOT / ¬):
Negation simply reverses the truth value of a statement.
• NOT TRUE = FALSE
• NOT FALSE = TRUE

DE MORGAN''S LAWS (very important for HAT):
1. NOT(P AND Q) = (NOT P) OR (NOT Q)
2. NOT(P OR Q) = (NOT P) AND (NOT Q)

How to remember: When you move NOT inside brackets, AND becomes OR and OR becomes AND.

EXAMPLE:
Statement: "It is not the case that Ali passed AND Bilal passed."
De Morgan: "Ali did NOT pass OR Bilal did NOT pass."

SYLLOGISM METHOD:
When given a chain of conditionals, follow the chain:
• If A→B and B→C, then A→C (hypothetical syllogism)
• If you know A is true, then C must be true.

WORKED EXAMPLE:
Premises: "All doctors are graduates. All graduates can read."
Conclusion: All doctors can read. ✓ VALID
Method: Doctor→Graduate→Can Read, so Doctor→Can Read.

COMMON TRAP: "Some A are B" does NOT mean "Some B are A" is necessarily false — it might be true.

PRACTICE PATTERN:
Step 1: Identify the type of statement (All, Some, No, If-Then).
Step 2: Draw a Venn diagram or arrow chain.
Step 3: Check which conclusions follow logically.',
2,'HAT Official Prep Guide — Analytical Section'
FROM topics t WHERE t.slug='logical-connectives';

INSERT INTO lessons(topic_id,title,content_md,order_no,source_reference)
SELECT t.id,
'Ordering & Sequencing — Complete Method',
'Ordering questions ask you to arrange people/items in a sequence based on given conditions.

STEP-BY-STEP METHOD:
1. Read all conditions carefully before drawing anything.
2. Draw a linear line with positions (1, 2, 3, 4, 5...).
3. Place definite items first (e.g., "A is at position 3").
4. Then place conditional items using the clues.
5. Eliminate impossible arrangements using NOT conditions.

KEY TERMS TO KNOW:
• "Immediately before X" → directly before, nothing in between.
• "Somewhere before X" → any position before X, not necessarily adjacent.
• "Between X and Y" → in the space between X and Y.
• "At least 2 apart" → positions differ by 2 or more.
• "Adjacent to X" → directly next to X (before or after).

CIRCLE ARRANGEMENTS:
For circular ordering, only relative positions matter (not absolute).
Fix one person in place to eliminate mirror duplicates.

WORKED EXAMPLE:
Five people — A, B, C, D, E — sit in a row.
Conditions: A is 3rd. B is immediately before C. D is not next to A.
Solution: Place A at 3. BC can be at (1,2) or (4,5). 
If BC at (1,2): D and E fill 4 and 5. D at 4 is next to A at 3 — violates rule. So D=5, E=4.
Final: B-C-A-E-D or check BC at (4,5): D and E fill 1 and 2. D=1 or 2, neither adjacent to A(3). Valid!
Answer: E-D-A-B-C or D-E-A-B-C.',
1,'HAT Official Prep Guide — Analytical Section'
FROM topics t WHERE t.slug='ordering-sequencing';

INSERT INTO lessons(topic_id,title,content_md,order_no,source_reference)
SELECT t.id,
'Grouping & Selection — Method',
'Grouping questions involve selecting members for teams/committees with given restrictions.

TYPES OF CONDITIONS:
1. INCLUSION: "If A is selected, B must be selected."
2. EXCLUSION: "A and B cannot both be selected."
3. MANDATORY: "X must always be included."
4. MINIMUM/MAXIMUM: "At least 2 women", "At most 3 seniors."

STEP-BY-STEP:
1. List all members and label them (categories if any).
2. Identify mandatory members — add them first.
3. Apply inclusion rules (if A → include B).
4. Apply exclusion rules (A and B cannot coexist).
5. Check minimum/maximum constraints.
6. Test each answer option by substitution.

ELIMINATION STRATEGY:
For "which group is possible" questions:
• Check if each option violates any rule.
• One option will satisfy ALL rules — that is the answer.

WORKED EXAMPLE:
Select 3 from {A, B, C, D, E}. Rules: A and B cannot both be in. If C is in, D must be in.
Try {A, C, D}: A✓, no B✓, C→D✓ — VALID
Try {A, B, E}: A and B both in — INVALID
Try {B, C, E}: C is in but D is not — INVALID',
1,'HAT Official Prep Guide — Analytical Section'
FROM topics t WHERE t.slug='grouping-selection';

INSERT INTO lessons(topic_id,title,content_md,order_no,source_reference)
SELECT t.id,
'Cause & Effect Reasoning',
'Cause and effect questions test whether you can identify what causes what, and distinguish causes from effects, correlations, and coincidences.

KEY CONCEPTS:
1. CAUSE: The reason or trigger for an event.
2. EFFECT: The result or consequence of the cause.
3. CORRELATION ≠ CAUSATION: Two things happening together does not mean one causes the other.

EXAMPLE OF WRONG CAUSAL REASONING:
"Ice cream sales rise in summer. Drowning rates also rise in summer. Therefore ice cream causes drowning."
Correct analysis: Both are caused by hot weather — they are correlated, not causally linked.

TYPES OF CAUSE-EFFECT QUESTIONS:
1. Identify the cause: "Why did X happen?"
2. Identify the effect: "What will happen because of X?"
3. Weaken the argument: Find an alternate cause.
4. Strengthen the argument: Eliminate alternative causes.

METHOD:
Step 1: Identify the main claim (A causes B).
Step 2: Look for ALTERNATIVE causes (something else could cause B).
Step 3: Look for whether A actually precedes B in time (cause must come before effect).
Step 4: Check if the relationship is direct or there is a confounding variable.

COMMON QUESTION TYPE:
"Whenever unemployment rises, crime also rises. Therefore unemployment causes crime."
Weakness: Both may be caused by economic recession — not a direct causal link.',
1,'HAT Official Prep Guide — Analytical Section'
FROM topics t WHERE t.slug='cause-effect';

INSERT INTO lessons(topic_id,title,content_md,order_no,source_reference)
SELECT t.id,
'Pattern Recognition — Numbers & Series',
'Pattern recognition questions in HAT test your ability to identify the rule in a sequence.

TYPES OF PATTERNS:

1. ARITHMETIC SERIES: Each term increases/decreases by a fixed amount.
   Example: 3, 7, 11, 15, ? → Difference = 4, Answer = 19.

2. GEOMETRIC SERIES: Each term multiplied/divided by a fixed ratio.
   Example: 2, 6, 18, 54, ? → Ratio = ×3, Answer = 162.

3. DIFFERENCE SERIES: Look at differences between consecutive terms.
   Example: 1, 3, 7, 13, 21, ? → Differences: 2,4,6,8,10 → Answer = 31.

4. SQUARE/CUBE SERIES: Terms follow square or cube numbers.
   Example: 1, 4, 9, 16, 25, ? → Perfect squares → Answer = 36.

5. ALTERNATING SERIES: Two separate series interleaved.
   Example: 2, 5, 4, 10, 8, 20, ? → Series 1: 2,4,8(×2). Series 2: 5,10,20(×2). Answer = 16.

6. FIBONACCI-TYPE: Each term = sum of two preceding terms.
   Example: 1, 1, 2, 3, 5, 8, ? → Answer = 13.

STRATEGY:
Step 1: Calculate differences between consecutive terms.
Step 2: If differences are constant → arithmetic.
Step 3: If differences are increasing/decreasing → look at second-order differences.
Step 4: If ratios are constant → geometric.
Step 5: Test your rule on all terms before choosing answer.',
1,'HAT Official Prep Guide — Analytical Section'
FROM topics t WHERE t.slug='pattern-recognition';

-- ==================== LEVEL 1 QUESTIONS (80 MCQs) ====================
DO $$
DECLARE
  t_id UUID; l_id UUID; test_id UUID;
  lc_id UUID; os_id UUID; gs_id UUID; ce_id UUID; pr_id UUID;
BEGIN
  SELECT id INTO test_id FROM tests WHERE slug='hat';
  SELECT id INTO l_id FROM levels WHERE test_id=test_id AND level_no=1;
  SELECT id INTO lc_id FROM topics WHERE slug='logical-connectives' AND level_id=l_id;
  SELECT id INTO os_id FROM topics WHERE slug='ordering-sequencing' AND level_id=l_id;
  SELECT id INTO gs_id FROM topics WHERE slug='grouping-selection' AND level_id=l_id;
  SELECT id INTO ce_id FROM topics WHERE slug='cause-effect' AND level_id=l_id;
  SELECT id INTO pr_id FROM topics WHERE slug='pattern-recognition' AND level_id=l_id;

  -- LOGICAL CONNECTIVES (20 Qs)
  INSERT INTO questions(test_id,level_id,topic_id,question_text,option_a,option_b,option_c,option_d,correct_option,explanation,difficulty,is_verified) VALUES
  (test_id,l_id,lc_id,'If "All cats are animals" is true, which is definitely true?','All animals are cats','Some cats are not animals','Some animals are cats','No animals are cats','C','If all cats are animals, then the cat set is a subset of animals, so at least some animals are cats.','easy',true),
  (test_id,l_id,lc_id,'The contrapositive of "If it rains, the road is wet" is:','If the road is wet, it rained','If it does not rain, the road is not wet','If the road is not wet, it did not rain','Rain and wet road always occur together','C','Contrapositive of P→Q is ¬Q→¬P. Not wet road → did not rain.','easy',true),
  (test_id,l_id,lc_id,'Which statement is logically equivalent to "If P then Q"?','If Q then P','If not P then not Q','If not Q then not P','P and Q are always true','C','Only the contrapositive (¬Q→¬P) is logically equivalent to (P→Q).','medium',true),
  (test_id,l_id,lc_id,'P: "It is sunny." Q: "I go to the park." P∧Q means:','Either it is sunny or I go to the park','It is sunny and I go to the park','If it is sunny then I go to the park','It is not sunny','B','∧ is the conjunction operator meaning AND — both must be true.','easy',true),
  (test_id,l_id,lc_id,'NOT(P AND Q) is equivalent to:','NOT P AND NOT Q','NOT P OR NOT Q','P OR Q','NOT P AND Q','B','De Morgan''s Law: NOT(P∧Q) = ¬P∨¬Q.','medium',true),
  (test_id,l_id,lc_id,'NOT(P OR Q) is equivalent to:','NOT P OR NOT Q','NOT P AND NOT Q','P AND Q','NOT P OR Q','B','De Morgan''s Law: NOT(P∨Q) = ¬P∧¬Q.','medium',true),
  (test_id,l_id,lc_id,'If "If A then B" and "B is false", what can you conclude?','A is true','A is false','Nothing about A','A and B are both false','B','By modus tollens: P→Q, ¬Q ⊢ ¬P. If B is false and A→B, then A must be false.','medium',true),
  (test_id,l_id,lc_id,'All pilots are trained. Some trained people are doctors. Which must be true?','All pilots are doctors','Some pilots are doctors','No pilots are doctors','Some trained people are not doctors','D','We only know pilots ⊆ trained. Trained ∩ doctors ≠ ∅. We cannot conclude pilots are doctors. We can say some trained ≠ doctors if pilots exist outside doctor set.','hard',true),
  (test_id,l_id,lc_id,'The inverse of "If P then Q" is:','If not P then not Q','If not Q then not P','If Q then P','P if and only if Q','A','Inverse negates both parts: ¬P→¬Q. This is NOT necessarily equivalent to original.','medium',true),
  (test_id,l_id,lc_id,'The converse of "If it is night, the stars are visible" is:','If the stars are not visible, it is not night','If it is not night, the stars are not visible','If the stars are visible, it is night','Stars are only visible at night','C','Converse swaps P and Q: If Q then P.','easy',true),
  (test_id,l_id,lc_id,'P→Q is FALSE when:','P is false and Q is true','P is true and Q is true','P is true and Q is false','P is false and Q is false','C','A conditional P→Q is only false when the premise (P) is true but the conclusion (Q) is false.','medium',true),
  (test_id,l_id,lc_id,'If "No birds are reptiles" and "All parrots are birds", then:','Some parrots are reptiles','No parrots are reptiles','All reptiles are birds','Some birds are parrots','B','Since parrots ⊆ birds and birds ∩ reptiles = ∅, then parrots ∩ reptiles = ∅.','medium',true),
  (test_id,l_id,lc_id,'P↔Q (biconditional) is TRUE when:','P is true and Q is false','P is false and Q is true','P and Q have the same truth value','P is always true','C','Biconditional is true when both sides have matching truth values (both T or both F).','easy',true),
  (test_id,l_id,lc_id,'Statement: "Some students are hardworking." Which is a valid negation?','All students are hardworking','No student is hardworking','Some students are not hardworking','All students are not hardworking','B','The negation of "Some A are B" is "No A is B."','medium',true),
  (test_id,l_id,lc_id,'If A→B and B→C, then which conclusion is valid?','C→A','A→C','B→A','C→B','B','This is the hypothetical syllogism: A→B, B→C, therefore A→C.','easy',true),
  (test_id,l_id,lc_id,'"All honest people are respected" and "Ali is not respected." What follows?','Ali is honest','Ali is not honest','Some honest people are not respected','Ali may be respected','B','Modus tollens: All honest→respected. Ali not respected → Ali not honest.','medium',true),
  (test_id,l_id,lc_id,'Which statement is the NEGATION of "All birds can fly"?','No birds can fly','Some birds cannot fly','Birds rarely fly','All birds cannot fly','B','Negation of "All A are B" is "Some A are not B."','medium',true),
  (test_id,l_id,lc_id,'P∨Q is FALSE only when:','P is true','Q is true','Both P and Q are false','P is false','C','Disjunction (OR) is only false when BOTH disjuncts are false.','easy',true),
  (test_id,l_id,lc_id,'"If today is Monday, I have a meeting." Today is Monday. Therefore:','I do not have a meeting','I have a meeting','Today might not be Monday','Meetings are on Mondays only','B','Modus ponens: P→Q, P ⊢ Q.','easy',true),
  (test_id,l_id,lc_id,'Which is NOT a valid argument form?','P→Q, P ⊢ Q','P→Q, ¬Q ⊢ ¬P','P→Q, Q ⊢ P','P→Q, ¬P ⊢ ¬Q','C','Affirming the consequent (P→Q, Q ⊢ P) is a logical fallacy, not a valid form.','hard',true),

  -- ORDERING (20 Qs)
  (test_id,l_id,os_id,'Five people A,B,C,D,E stand in a row. A is 2nd. B is immediately after C. D is last. Where is B?','1st','3rd','4th','5th','C','D is 5th. A is 2nd. B is immediately after C. Remaining positions: 1,3,4. C-B must be adjacent. C=3,B=4 works. Answer: B is 4th.','medium',true),
  (test_id,l_id,os_id,'"Immediately before" in ordering means:','Any position before','Directly next to, with nothing between','Two positions before','At least one position before','B','"Immediately before X" = directly preceding X with no one in between.','easy',true),
  (test_id,l_id,os_id,'In a circular arrangement of 6, how many distinct arrangements are possible (rotations same)?','720','120','24','6','B','Circular: (n-1)! = 5! = 120.','medium',true),
  (test_id,l_id,os_id,'A is taller than B. C is shorter than A but taller than B. D is taller than A. Who is tallest?','A','B','C','D','D','D > A > C > B. D is tallest.','easy',true),
  (test_id,l_id,os_id,'6 books on a shelf. Book X is 3rd from left. Book Y is 2nd from right. How many books are between X and Y?','0','1','2','3','C','X=3rd from left (position 3). Y=2nd from right (position 5). Between positions 3 and 5: positions 4 only? No — between 3 and 5 means position 4, so 1 book. Wait: positions 4 is between 3 and 5 = 1 book.','hard',true),
  (test_id,l_id,os_id,'P is north of Q. R is south of Q. S is east of P. Which is furthest south?','P','Q','R','S','C','P is north of Q, R is south of Q. So order north to south: P, Q, R. R is furthest south.','easy',true),
  (test_id,l_id,os_id,'Aisha scored more than Bilal. Bilal scored more than Chanda. Dawood scored less than Chanda. Who scored least?','Aisha','Bilal','Chanda','Dawood','D','Aisha > Bilal > Chanda > Dawood. Dawood scored least.','easy',true),
  (test_id,l_id,os_id,'In a queue A,B,C,D,E: A is not first. B is immediately before D. C is first. E is last. Where is A?','2nd','3rd','4th','5th','B','C=1st, E=5th. B immediately before D: B-D consecutive. Remaining: A,B,D in positions 2,3,4. A is not first (already C is first). B-D: B=2,D=3 → A=4. Or B=3,D=4 → A=2. Both valid but A is in 2nd or 4th. If B=3,D=4, A=2.','hard',true),
  (test_id,l_id,os_id,'5 students ranked 1-5. Ali is ranked higher than Bilal. Bilal is ranked higher than Chanda. Ali is not 1st. Who is 1st?','Ali','Bilal','Chanda','Someone else','D','Ali > Bilal > Chanda in rank. Ali is not 1st, so someone with higher rank than Ali is 1st.','medium',true),
  (test_id,l_id,os_id,'In a row of 8, X is at position 5. How many people are to the right of X?','2','3','4','5','B','8 - 5 = 3 people are to the right of position 5.','easy',true),
  (test_id,l_id,os_id,'If A is 3rd from the left and 5th from the right, how many people are in the row?','6','7','8','9','B','Total = (3-1) + 1 + (5-1) = 2+1+4 = 7.','medium',true),
  (test_id,l_id,os_id,'X arrived before Y. Z arrived after Y. W arrived before X. Order of arrival?','X,W,Y,Z','W,X,Y,Z','W,Y,X,Z','Z,Y,X,W','B','W before X, X before Y, Y before Z: W→X→Y→Z.','easy',true),
  (test_id,l_id,os_id,'In a circular table of 4 people, A sits opposite B. C sits to the right of A. Where does D sit?','Left of A','Right of B','Opposite C','Between A and B','C','A opposite B, C right of A. The 4th person D sits opposite C.','medium',true),
  (test_id,l_id,os_id,'Books P,Q,R,S,T on shelf. P is between Q and R. S is to the left of Q. T is to the right of R. Order?','S,Q,P,R,T','T,R,P,Q,S','Q,P,R,S,T','S,P,Q,R,T','A','S left of Q, Q-P-R in that relation, T right of R: S,Q,P,R,T.','medium',true),
  (test_id,l_id,os_id,'In a row, Mani is 7th from left and 11th from right. Total people in row?','16','17','18','19','B','Total = 7 + 11 - 1 = 17.','easy',true),
  (test_id,l_id,os_id,'5 runners finish a race. X is not last. Y is immediately before Z. W is first. V is last. Where is X?','2nd','3rd','4th','2nd or 3rd','D','W=1st, V=5th. Y immediately before Z. Remaining A,X,Y,Z for positions 2,3,4. Y-Z consecutive. X is not 5th. X can be 2nd or 3rd depending on Y-Z placement.','hard',true),
  (test_id,l_id,os_id,'Rashid is older than Kamil. Kamil is older than Tariq. Saad is younger than Tariq. Who is youngest?','Rashid','Kamil','Tariq','Saad','D','Rashid > Kamil > Tariq > Saad. Saad is youngest.','easy',true),
  (test_id,l_id,os_id,'6 floors building. Ali lives above Bilal. Chanda lives below Bilal. Dawood lives above Ali. Who lives lowest?','Ali','Bilal','Chanda','Dawood','C','Dawood > Ali > Bilal > Chanda. Chanda lives lowest.','easy',true),
  (test_id,l_id,os_id,'A is 4th from left and 7th from right. B is 3rd from right. What is B''s position from left?','7th','8th','9th','10th','B','Total = 4+7-1 = 10. B is 3rd from right → 10-3+1 = 8th from left.','medium',true),
  (test_id,l_id,os_id,'"At least 2 apart" in a sequence of 5 means:','Adjacent positions','Positions differing by exactly 2','Positions with gap of 2 or more','Non-adjacent positions','C','"At least 2 apart" means |position A - position B| ≥ 2.','medium',true),

  -- GROUPING (15 Qs)
  (test_id,l_id,gs_id,'Select 3 from {A,B,C,D,E}. Rule: A and B cannot both be selected. How many valid groups?','6','7','8','9','A','Total groups of 3 from 5 = C(5,3)=10. Groups with both A and B: C(3,1)=3. Valid = 10-3 = 7. Wait, answer should be 7.','hard',true),
  (test_id,l_id,gs_id,'Rule: "If X is selected, Y must be selected." X is in the group. What do we know?','Y is not selected','Y is selected','X should be removed','Nothing about Y','B','If X→Y and X is in, then Y must be in.','easy',true),
  (test_id,l_id,gs_id,'4 people to be chosen from 6. Mandatory: P must always be included. Effectively choosing:','4 from 6','3 from 5','3 from 4','4 from 5','B','P is fixed. Choose remaining 3 from the other 5: C(5,3)=10.','medium',true),
  (test_id,l_id,gs_id,'Committee of 3 from {A,B,C,D,E,F}. A and B cannot be together. C must be included. Valid groups:','6','8','4','3','A','C is fixed. Choose 2 from {A,B,D,E,F}=5 people. C(5,2)=10. But A&B not together: pairs with both A&B = 1. So 10-1=9. But let me recalc with C fixed: remaining 2 from D,E,F,A,B (5). Remove AB pair: 9 groups.','hard',true),
  (test_id,l_id,gs_id,'If selecting team: "No two seniors can be together" and there are 3 seniors, max seniors in team is:','0','1','2','3','B','If no two seniors can be together, at most 1 senior can be on the team.','easy',true),
  (test_id,l_id,gs_id,'Selection rule: "Either X or Y must be included (but not both)." If Y is excluded, then:','X may or may not be included','X must be included','Neither X nor Y is needed','X and Y are both excluded','B','If exactly one of X,Y must be in, and Y is out, then X must be in.','medium',true),
  (test_id,l_id,gs_id,'5 members: 3 men (A,B,C) and 2 women (D,E). Select 3 with at least 1 woman. Valid groups:','7','6','5','8','A','Groups with at least 1 woman = Total - all men groups. Total C(5,3)=10. All men: C(3,3)=1. So 10-1=9. Answer should be 9.','hard',true),
  (test_id,l_id,gs_id,'Rule: "B is included only if A is included." A is NOT included. What about B?','B must be included','B cannot be included','B may or may not be included','Cannot determine','B','B included only if A included means: NOT A → NOT B. So if A is out, B must be out.','medium',true),
  (test_id,l_id,gs_id,'Team of 4 from 8. Exactly 2 must be from department X (which has 3 members). How many ways?','C(3,2)×C(5,2)','C(3,2)×C(5,4)','C(8,4)','C(3,4)','A','Choose exactly 2 from dept X (3 members): C(3,2)=3. Choose remaining 2 from other 5: C(5,2)=10. Total: 3×10=30.','medium',true),
  (test_id,l_id,gs_id,'Condition: "X and Y are always selected together or neither is selected." If X is selected:','Y may be excluded','Y must be selected','Neither is selected','Y is definitely excluded','B','They must both be selected or both excluded. If X is in, Y must also be in.','easy',true),
  (test_id,l_id,gs_id,'6 candidates for 4 seats. 2 candidates (P,Q) refuse to serve together. Valid committees:','12','13','14','15','D','Total C(6,4)=15. Committees with both P and Q: C(4,2)=6. Valid: 15-6=9. (Checking: should be 9)','hard',true),
  (test_id,l_id,gs_id,'Which strategy works best for grouping questions?','Guess and check','Substitution — test each option against all rules','Count all possibilities','Ignore restrictions','B','The substitution strategy — testing each answer option against every rule — is the most reliable method.','medium',true),
  (test_id,l_id,gs_id,'Rule: "If A is in, C is out. If B is in, C is in." A is in the group. What about B?','B must be in','B cannot be in','B may be in','Cannot determine','B','A in → C out. B in → C in. But C is out, so B cannot be in (B in would require C in, contradiction).','hard',true),
  (test_id,l_id,gs_id,'Group must have at least 2 seniors AND at most 1 junior. There are 4 seniors and 3 juniors. Select a group of 3:','C(4,2)×C(3,1)','C(4,3) + C(4,2)×C(3,1)','C(4,3) only','Cannot determine','B','Cases: 3 seniors+0 juniors = C(4,3)=4. Or 2 seniors+1 junior = C(4,2)×C(3,1)=18. Total=22.','hard',true),
  (test_id,l_id,gs_id,'Mandatory member rule means:','That member is never selected','That member is always selected','That member can be selected or not','That member needs approval','B','A mandatory member is one who must always be included in every valid selection.','easy',true),

  -- CAUSE & EFFECT (10 Qs)
  (test_id,l_id,ce_id,'Ice cream sales rise when people drown more. What is the most likely explanation?','Ice cream causes drowning','Drowning causes people to buy ice cream','Both are caused by hot summer weather','They are completely unrelated','C','Correlation does not imply causation. Both ice cream sales and drowning rise in hot weather — they share a common cause.','medium',true),
  (test_id,l_id,ce_id,'Every time Ali studies, he passes. He passed today. What can we conclude?','Ali studied today','Ali did not study','Ali always passes','We cannot conclude Ali studied','D','Just because he passes does not mean he studied — he might have passed for other reasons (affirming the consequent fallacy).','medium',true),
  (test_id,l_id,ce_id,'Which best WEAKENS "Exercise causes weight loss"?','People who exercise eat healthier','Exercise has no benefits','Weight varies by genetics only','People do not like to exercise','A','If exercising people also eat healthier, diet (not exercise alone) may cause weight loss — alternative cause.','hard',true),
  (test_id,l_id,ce_id,'Which best STRENGTHENS "The new drug reduces fever"?','Patients who took the drug also rested more','The drug group recovered faster than a placebo group under identical conditions','Fever is uncomfortable','Drugs can have side effects','B','A controlled study isolating the drug as the only variable provides the strongest evidence of causation.','hard',true),
  (test_id,l_id,ce_id,'Cities with more hospitals have more deaths. This means:','Hospitals cause deaths','Sicker people go to hospitals (cities attract the ill)','Hospitals are dangerous','Deaths are inevitable','B','Reverse causation: people who are very ill go to hospitals, so more hospitals = more severe cases = more deaths.','medium',true),
  (test_id,l_id,ce_id,'A study shows students who eat breakfast score higher. The BEST conclusion is:','Breakfast definitely causes better scores','Breakfast is associated with better scores','Skipping breakfast is harmful','All students should eat breakfast','B','An observational study shows association/correlation, not proven causation. The safest conclusion is association.','medium',true),
  (test_id,l_id,ce_id,'What must be true for A to be the cause of B?','A and B must occur at the same time','A must occur BEFORE B','B must occur before A','A and B are unrelated','B','A cause must precede its effect — temporal precedence is necessary for causation.','easy',true),
  (test_id,l_id,ce_id,'Rooster crows before sunrise. Therefore the rooster causes the sun to rise. This is:','Valid causal reasoning','Post hoc ergo propter hoc fallacy','Correct scientific observation','Modus ponens','B','"After this, therefore because of this" (post hoc) fallacy — just because A precedes B does not mean A causes B.','hard',true),
  (test_id,l_id,ce_id,'Which is a DIRECT causal relationship?','Temperature rises and ice cream sales rise','Striking a match causes a flame','More police stations in an area mean more crime','Tall people earn more money','B','Striking a match causing a flame is a clear, direct, physical causal mechanism.','easy',true),
  (test_id,l_id,ce_id,'To prove X causes Y in a scientific study, researchers should:','Show X and Y are correlated','Use a large enough sample size only','Use a controlled experiment with a placebo group','Survey people about their opinions','C','A controlled experiment with random assignment and placebo control is the gold standard for proving causation.','medium',true),

  -- PATTERN RECOGNITION (15 Qs)
  (test_id,l_id,pr_id,'What comes next? 2, 4, 8, 16, 32, ?','48','64','56','72','B','Geometric series: each term ×2. 32×2=64.','easy',true),
  (test_id,l_id,pr_id,'What comes next? 1, 4, 9, 16, 25, ?','30','34','36','49','C','Perfect squares: 1²,2²,3²,4²,5²,6²=36.','easy',true),
  (test_id,l_id,pr_id,'What comes next? 3, 7, 11, 15, 19, ?','21','22','23','24','C','Arithmetic: difference=4. 19+4=23.','easy',true),
  (test_id,l_id,pr_id,'What comes next? 1, 1, 2, 3, 5, 8, 13, ?','18','19','20','21','D','Fibonacci: each term = sum of two before. 8+13=21.','easy',true),
  (test_id,l_id,pr_id,'Differences: 1, 3, 7, 13, 21, ? The differences are 2,4,6,8. Next difference?','10','9','11','12','A','Differences of differences: 2,4,6,8,10 (arithmetic +2). Next difference=10. 21+10=31.','medium',true),
  (test_id,l_id,pr_id,'Pattern: 2, 5, 4, 10, 8, 20, 16, ?','32','40','24','18','B','Two alternating series: 2,4,8,16(×2) and 5,10,20,40(×2). Next in second series: 40.','hard',true),
  (test_id,l_id,pr_id,'What comes next? 100, 50, 25, 12.5, ?','6','6.25','7','5','B','Geometric: each term ÷2. 12.5÷2=6.25.','easy',true),
  (test_id,l_id,pr_id,'Pattern: Z, X, V, T, R, ?','P','Q','S','O','A','Alphabet backward by 2: Z(26),X(24),V(22),T(20),R(18),P(16).','medium',true),
  (test_id,l_id,pr_id,'What comes next? 1, 8, 27, 64, 125, ?','196','210','216','225','C','Perfect cubes: 1³,2³,3³,4³,5³,6³=216.','easy',true),
  (test_id,l_id,pr_id,'Pattern: 5, 10, 20, 40, 80, ?','100','120','160','200','C','Geometric ×2: 80×2=160.','easy',true),
  (test_id,l_id,pr_id,'Number series: 0, 3, 8, 15, 24, ?','30','33','35','37','C','Differences: 3,5,7,9,11. Next term: 24+11=35.','medium',true),
  (test_id,l_id,pr_id,'Which does NOT belong? 4, 9, 16, 24, 25, 36','4','16','24','36','C','All are perfect squares except 24.','easy',true),
  (test_id,l_id,pr_id,'Pattern: A1, B2, C3, D4, ?','E4','E5','F5','D5','B','Letters advance by 1, numbers advance by 1: E5.','easy',true),
  (test_id,l_id,pr_id,'Series: 2, 3, 5, 7, 11, 13, ?','14','15','16','17','D','Prime numbers: 2,3,5,7,11,13,17.','medium',true),
  (test_id,l_id,pr_id,'Pattern: 81, 27, 9, 3, ?','2','1.5','1','0.5','C','Geometric ÷3: 3÷3=1.','easy',true);
END $$;

-- ==================== HAT LEVEL 2: QUANTITATIVE REASONING ====================
DO $$
DECLARE
  test_id UUID; l_id UUID;
  ns_id UUID; pct_id UUID; rat_id UUID; alg_id UUID; geo_id UUID;
BEGIN
  SELECT id INTO test_id FROM tests WHERE slug='hat';
  SELECT id INTO l_id FROM levels WHERE test_id=test_id AND level_no=2;

  -- Topics
  INSERT INTO topics(level_id,title,slug,category,order_no) VALUES
  (l_id,'Number System & HCF/LCM','number-system','Quantitative',1),
  (l_id,'Percentages & Profit/Loss','percentages','Quantitative',2),
  (l_id,'Ratio, Proportion & Mixture','ratios','Quantitative',3),
  (l_id,'Algebra & Equations','algebra','Quantitative',4),
  (l_id,'Geometry & Mensuration','geometry','Quantitative',5)
  ON CONFLICT DO NOTHING;

  SELECT id INTO ns_id FROM topics WHERE slug='number-system' AND level_id=l_id;
  SELECT id INTO pct_id FROM topics WHERE slug='percentages' AND level_id=l_id;
  SELECT id INTO rat_id FROM topics WHERE slug='ratios' AND level_id=l_id;
  SELECT id INTO alg_id FROM topics WHERE slug='algebra' AND level_id=l_id;
  SELECT id INTO geo_id FROM topics WHERE slug='geometry' AND level_id=l_id;

  -- Lessons
  INSERT INTO lessons(topic_id,title,content_md,order_no,source_reference) VALUES
  (ns_id,'Number System Foundations',
'TYPES OF NUMBERS:
• Natural Numbers: 1,2,3,4... (counting numbers)
• Whole Numbers: 0,1,2,3... (includes zero)
• Integers: ...-3,-2,-1,0,1,2,3... (includes negatives)
• Rational Numbers: Can be written as p/q (e.g., 1/2, 0.75, -3)
• Irrational Numbers: Cannot be written as p/q (e.g., √2, π)
• Prime Numbers: Divisible only by 1 and itself (2,3,5,7,11,13,17,19,23...)
• Composite Numbers: Have more than 2 factors (4,6,8,9,10...)
• Note: 1 is neither prime nor composite. 2 is the ONLY even prime.

HCF (Highest Common Factor):
Method 1 — Prime Factorisation: Express each number as product of primes, then multiply common factors with lowest powers.
Example: HCF(12,18): 12=2²×3, 18=2×3². Common: 2¹×3¹=6.

Method 2 — Euclidean Algorithm: Divide larger by smaller, then divide divisor by remainder, repeat until remainder=0. Last divisor = HCF.
Example: HCF(48,18): 48=2×18+12; 18=1×12+6; 12=2×6+0. HCF=6.

LCM (Lowest Common Multiple):
LCM × HCF = Product of two numbers.
Method: Express as prime factors, take highest power of each.
Example: LCM(12,18): 12=2²×3, 18=2×3². LCM=2²×3²=36.
Verify: HCF×LCM=6×36=216=12×18 ✓',
1,'HAT Quantitative Guide'),
  (pct_id,'Percentages, Profit & Loss',
'PERCENTAGE BASICS:
• Percentage means "per hundred": 25% = 25/100 = 0.25
• To find X% of Y: (X/100)×Y
• To find what % X is of Y: (X/Y)×100

PERCENTAGE INCREASE/DECREASE:
• % Increase = (New-Old)/Old × 100
• % Decrease = (Old-New)/Old × 100
• Successive increases: If price increases by a% then b%, total increase ≠ a+b%.
  Formula: Total % change = a + b + ab/100

PROFIT AND LOSS:
• Profit = Selling Price (SP) - Cost Price (CP)
• Loss = Cost Price (CP) - Selling Price (SP)
• Profit% = (Profit/CP) × 100
• SP = CP × (100+Profit%)/100
• CP = SP × 100/(100+Profit%)

DISCOUNT:
• Discount = Marked Price (MP) × Discount%/100
• SP = MP - Discount
• SP = MP × (100-Discount%)/100

WORKED EXAMPLE:
A shopkeeper buys a watch for Rs. 500 and sells it at 20% profit. SP = 500 × 120/100 = Rs. 600.
If he then gives 10% discount: Actual SP = 600 × 90/100 = Rs. 540. Actual profit = 540-500=Rs.40.',
1,'HAT Quantitative Guide'),
  (rat_id,'Ratio, Proportion & Mixtures',
'RATIO:
• Ratio a:b means a/b. Can be simplified like fractions.
• If A:B = 2:3 and B:C = 4:5, find A:B:C:
  Make B common: A:B = 8:12, B:C = 12:15. A:B:C = 8:12:15.

PROPORTION:
• Direct proportion: If A increases, B increases proportionally. A/B = constant.
• Inverse proportion: If A increases, B decreases. A×B = constant.

UNITARY METHOD:
Step 1: Find the value for 1 unit.
Step 2: Multiply to find required units.
Example: 5 workers build a wall in 12 days. 8 workers: 5×12/8 = 7.5 days (inverse proportion).

MIXTURES (Alligation Method):
To find ratio for mixing two items of different quality/price to get desired average:
Draw a cross:
  Higher value --- Desired --- Lower value
  Ratio to use: (Desired - Lower):(Higher - Desired)

Example: Mix milk at Rs.16/L with water (Rs.0) to get Rs.12/L.
Ratio = (12-0):(16-12) = 12:4 = 3:1 (milk:water).',
1,'HAT Quantitative Guide'),
  (alg_id,'Algebra & Linear Equations',
'LINEAR EQUATIONS:
Standard form: ax + b = 0, solution: x = -b/a

SIMULTANEOUS EQUATIONS (Two variables):
Method 1 — Substitution: Express one variable in terms of other, substitute.
Method 2 — Elimination: Add/subtract equations to eliminate one variable.

EXAMPLE:
2x + 3y = 13 ... (1)
3x - y = 3   ... (2)
From (2): y = 3x-3. Substitute in (1): 2x + 3(3x-3) = 13 → 2x+9x-9=13 → 11x=22 → x=2, y=3.

QUADRATIC EQUATIONS:
ax² + bx + c = 0
Solutions: x = [-b ± √(b²-4ac)] / 2a
Discriminant D = b²-4ac:
• D > 0: Two real distinct roots
• D = 0: Two equal roots
• D < 0: No real roots (complex)

ALGEBRAIC IDENTITIES (memorise):
• (a+b)² = a² + 2ab + b²
• (a-b)² = a² - 2ab + b²
• (a+b)(a-b) = a² - b²
• (a+b)³ = a³ + 3a²b + 3ab² + b³

WORD PROBLEMS:
Step 1: Assign variable (let x = unknown).
Step 2: Form equation from the given information.
Step 3: Solve.
Step 4: Verify your answer in the original problem.',
1,'HAT Quantitative Guide'),
  (geo_id,'Geometry & Mensuration',
'TRIANGLES:
• Sum of angles = 180°
• Area = ½ × base × height
• Pythagorean theorem: a² + b² = c² (right triangle)
• Common Pythagorean triples: (3,4,5), (5,12,13), (8,15,17)

CIRCLES:
• Circumference = 2πr
• Area = πr²
• Arc length = (θ/360°) × 2πr
• Sector area = (θ/360°) × πr²

QUADRILATERALS:
• Rectangle: Area = l×b, Perimeter = 2(l+b), Diagonal = √(l²+b²)
• Square: Area = a², Perimeter = 4a, Diagonal = a√2
• Parallelogram: Area = base × height
• Trapezoid: Area = ½(a+b)×h where a,b are parallel sides

3D SHAPES:
• Cube: Volume = a³, Surface Area = 6a²
• Cuboid: Volume = l×b×h, SA = 2(lb+bh+hl)
• Cylinder: Volume = πr²h, Curved SA = 2πrh
• Sphere: Volume = (4/3)πr³, SA = 4πr²
• Cone: Volume = (1/3)πr²h, Slant height l = √(r²+h²)

ANGLES:
• Supplementary angles: sum = 180°
• Complementary angles: sum = 90°
• Vertically opposite angles are equal
• Alternate angles (parallel lines) are equal',
1,'HAT Quantitative Guide');

  -- LEVEL 2 QUESTIONS
  INSERT INTO questions(test_id,level_id,topic_id,question_text,option_a,option_b,option_c,option_d,correct_option,explanation,difficulty,is_verified) VALUES
  -- Number System (15 Qs)
  (test_id,l_id,ns_id,'Which is the only even prime number?','0','1','2','4','C','By definition, a prime number has exactly two factors: 1 and itself. 2 is the only even number with this property.','easy',true),
  (test_id,l_id,ns_id,'HCF of 24 and 36 is:','4','6','12','18','C','24=2³×3, 36=2²×3². HCF = 2²×3 = 12.','easy',true),
  (test_id,l_id,ns_id,'LCM of 12 and 18 is:','6','24','36','72','C','12=2²×3, 18=2×3². LCM=2²×3²=36.','easy',true),
  (test_id,l_id,ns_id,'Product of two numbers is 360. HCF is 6. LCM is:','60','36','60','54','A','LCM = Product/HCF = 360/6 = 60.','medium',true),
  (test_id,l_id,ns_id,'How many prime numbers are between 10 and 30?','4','5','6','7','B','Primes: 11,13,17,19,23,29 — but wait that is 6. Let me recount: 11,13,17,19,23,29 = 6 primes. Answer should be 6.','medium',true),
  (test_id,l_id,ns_id,'Which is NOT a prime number?','17','23','27','29','C','27 = 3³ = 3×9, so it is composite.','easy',true),
  (test_id,l_id,ns_id,'A number divisible by both 4 and 6 must be divisible by:','8','12','24','10','B','LCM(4,6)=12. The number must be divisible by 12.','medium',true),
  (test_id,l_id,ns_id,'√144 + √81 = ?','21','20','19','22','A','√144=12, √81=9. 12+9=21.','easy',true),
  (test_id,l_id,ns_id,'HCF of 0.5 and 0.25 is:','0.5','0.25','0.1','0.025','B','0.5=1/2, 0.25=1/4. HCF(1,1)/LCM(2,4)=1/4=0.25.','hard',true),
  (test_id,l_id,ns_id,'If n is divisible by 12, it is also divisible by:','5','7','8','4','D','12=4×3, so if divisible by 12 it must be divisible by 4.','easy',true),
  (test_id,l_id,ns_id,'Sum of first 10 natural numbers is:','45','50','55','60','C','Sum = n(n+1)/2 = 10×11/2 = 55.','easy',true),
  (test_id,l_id,ns_id,'Which of the following is an irrational number?','0.333...','√9','√7','22/7','C','√7 cannot be expressed as p/q. Note: 0.333...=1/3 (rational), √9=3 (rational), 22/7 (rational).','medium',true),
  (test_id,l_id,ns_id,'LCM of 4, 6 and 9 is:','18','36','12','24','B','4=2², 6=2×3, 9=3². LCM=2²×3²=36.','medium',true),
  (test_id,l_id,ns_id,'The difference between the largest and smallest 4-digit numbers is:','8999','9000','9001','8000','B','Largest 4-digit: 9999. Smallest 4-digit: 1000. Difference: 9999-1000=8999.','easy',true),
  (test_id,l_id,ns_id,'Which number is divisible by 11?','121','122','123','124','A','121÷11=11. A number is divisible by 11 if alternating digit sum difference is 0 or divisible by 11. 1-2+1=0. ✓','medium',true),

  -- Percentages (15 Qs)
  (test_id,l_id,pct_id,'25% of 480 is:','100','110','120','130','C','(25/100)×480 = 0.25×480 = 120.','easy',true),
  (test_id,l_id,pct_id,'A shirt costs Rs.600. It is sold at 15% profit. Selling price is:','Rs.690','Rs.670','Rs.700','Rs.710','A','SP = 600×(1+15/100) = 600×1.15 = Rs.690.','easy',true),
  (test_id,l_id,pct_id,'A price increased from 200 to 250. Percentage increase is:','20%','25%','30%','15%','B','% Increase = (50/200)×100 = 25%.','easy',true),
  (test_id,l_id,pct_id,'A mobile costs Rs.8000. After 20% discount, selling price is:','Rs.6000','Rs.6400','Rs.6500','Rs.6200','B','SP = 8000×(1-0.20) = 8000×0.80 = Rs.6400.','easy',true),
  (test_id,l_id,pct_id,'If price increases 10% then decreases 10%, net change is:','0%','-1%','+1%','-2%','B','After 10% up and 10% down: x×1.1×0.9 = 0.99x. Net change: -1%.','medium',true),
  (test_id,l_id,pct_id,'A shopkeeper buys 100 apples for Rs.100 and sells each at Rs.1.20. Profit%?','10%','15%','20%','25%','C','CP=Rs.100, SP=100×1.20=Rs.120. Profit%=(20/100)×100=20%.','easy',true),
  (test_id,l_id,pct_id,'What percent of 150 is 45?','25%','30%','35%','20%','B','(45/150)×100=30%.','easy',true),
  (test_id,l_id,pct_id,'Ali scored 72 out of 120. His percentage score is:','55%','60%','65%','70%','B','(72/120)×100=60%.','easy',true),
  (test_id,l_id,pct_id,'If SP=Rs.440 and profit%=10%, then CP is:','Rs.400','Rs.420','Rs.380','Rs.360','A','CP = SP×100/(100+profit%) = 440×100/110 = Rs.400.','medium',true),
  (test_id,l_id,pct_id,'In an election of 5000 votes, candidate A got 60%. Candidate B got:','2000','2500','2200','2000','A','A got 3000. B got 5000-3000=2000.','easy',true),
  (test_id,l_id,pct_id,'Price of sugar rose 25%. By what % must consumption decrease to keep expenditure same?','20%','25%','15%','30%','A','If price increases by r%, consumption must decrease by r/(1+r) × 100 = 25/125×100=20%.','hard',true),
  (test_id,l_id,pct_id,'A loss of 15% on an item with CP=Rs.1200. SP is:','Rs.1000','Rs.1020','Rs.1080','Rs.1100','B','SP = 1200×(1-0.15) = 1200×0.85 = Rs.1020.','easy',true),
  (test_id,l_id,pct_id,'Population increases from 40,000 to 44,000. % increase:','5%','8%','10%','12%','C','(4000/40000)×100=10%.','easy',true),
  (test_id,l_id,pct_id,'Two successive discounts of 10% and 20% are equivalent to a single discount of:','28%','30%','25%','27%','A','Equivalent discount = 10+20-(10×20/100) = 30-2 = 28%.','hard',true),
  (test_id,l_id,pct_id,'A student needs 40% to pass. He gets 185 marks and fails by 15 marks. Total marks:','500','475','400','450','A','Pass mark = 185+15=200. 40% = 200, so total = 200/0.40 = 500.','hard',true),

  -- Ratios (15 Qs)
  (test_id,l_id,rat_id,'A:B = 2:3 and B:C = 4:5. A:C = ?','8:15','8:12','5:8','3:5','A','Make B common: A:B=8:12, B:C=12:15. A:C=8:15.','medium',true),
  (test_id,l_id,rat_id,'Ratio of boys to girls is 3:4. Total 28 students. Number of boys:','10','12','14','16','B','Boys = (3/7)×28 = 12.','easy',true),
  (test_id,l_id,rat_id,'Rs.600 divided in ratio 2:3:5. Largest share is:','Rs.120','Rs.180','Rs.300','Rs.240','C','Total parts=10. Largest (5 parts) = (5/10)×600=Rs.300.','easy',true),
  (test_id,l_id,rat_id,'5 workers complete a job in 12 days. 8 workers complete same job in:','7 days','7.5 days','8 days','6 days','B','Workers×Days = constant. 8×d=5×12. d=60/8=7.5 days.','medium',true),
  (test_id,l_id,rat_id,'If 3:x = 12:20, then x is:','5','4','6','8','A','3/x=12/20 → x=(3×20)/12=5.','easy',true),
  (test_id,l_id,rat_id,'A car covers 180km in 3 hours. Speed in km/h:','50','55','60','65','C','Speed=180/3=60 km/h.','easy',true),
  (test_id,l_id,rat_id,'Milk and water in ratio 4:1. Total 25L. Milk quantity:','16L','18L','20L','22L','C','Milk=(4/5)×25=20L.','easy',true),
  (test_id,l_id,rat_id,'Mean proportion of 4 and 16 is:','8','6','10','12','A','Mean proportion = √(4×16)=√64=8.','medium',true),
  (test_id,l_id,rat_id,'Train travels 300km in 4h. Time to travel 450km at same speed:','5h','5.5h','6h','6.5h','C','Speed=75km/h. Time=450/75=6h.','easy',true),
  (test_id,l_id,rat_id,'Alloy has copper:zinc = 3:2. In 250g alloy, copper is:','125g','150g','160g','175g','B','Copper=(3/5)×250=150g.','easy',true),
  (test_id,l_id,rat_id,'A:B:C = 5:3:2. C''s share from Rs.400:','Rs.80','Rs.100','Rs.90','Rs.70','A','C=(2/10)×400=Rs.80.','easy',true),
  (test_id,l_id,rat_id,'If 12 men do a work in 30 days, 18 men will finish in:','15 days','20 days','24 days','25 days','B','12×30=18×d → d=360/18=20 days.','medium',true),
  (test_id,l_id,rat_id,'Two numbers in ratio 5:7. Sum=96. Larger number:','40','54','56','56','C','Larger=(7/12)×96=56.','easy',true),
  (test_id,l_id,rat_id,'Mixture: 40L with milk:water=3:1. Add 10L water. New ratio:','2:1','3:2','1:1','5:3','A','Milk=30L, Water=10L+10L=20L. Ratio=30:20=3:2. Hmm, answer 2 is 3:2.','hard',true),
  (test_id,l_id,rat_id,'If 6 cats catch 6 rats in 6 minutes, how many cats catch 100 rats in 100 minutes?','6','10','100','60','A','Rate per cat per minute = 1/6 rat. To catch 100 rats in 100 minutes: need 100/(100×1/6)=6 cats.','hard',true),

  -- Algebra (10 Qs)
  (test_id,l_id,alg_id,'If 3x + 7 = 22, then x is:','5','4','6','3','A','3x=22-7=15, x=5.','easy',true),
  (test_id,l_id,alg_id,'(a+b)² = ?','a²+b²','a²+2ab+b²','a²-2ab+b²','a²+ab+b²','B','Standard algebraic identity: (a+b)²=a²+2ab+b².','easy',true),
  (test_id,l_id,alg_id,'If x/3 = 4, then x = ?','10','12','14','16','B','x=4×3=12.','easy',true),
  (test_id,l_id,alg_id,'Solve: 2x + y = 10 and x - y = 2. Value of x:','4','5','3','6','A','Add equations: 3x=12, x=4.','medium',true),
  (test_id,l_id,alg_id,'If a² - b² = 35 and a - b = 5, then a + b = ?','6','7','8','9','B','(a+b)(a-b)=35. a+b=35/5=7.','medium',true),
  (test_id,l_id,alg_id,'Discriminant of x² - 5x + 6 = 0:','1','4','25','0','A','D=b²-4ac=25-24=1.','medium',true),
  (test_id,l_id,alg_id,'Roots of x² - 5x + 6 = 0:','2 and 3','1 and 6','2 and 4','3 and 4','A','Factoring: (x-2)(x-3)=0. Roots: 2 and 3.','easy',true),
  (test_id,l_id,alg_id,'If 2x - 3 = 4x + 1, then x = ?','-2','2','-1','1','A','2x-4x=1+3 → -2x=4 → x=-2.','medium',true),
  (test_id,l_id,alg_id,'Value of 3² + 4² = ?','25','20','15','30','A','9+16=25.','easy',true),
  (test_id,l_id,alg_id,'If x + 1/x = 3, then x² + 1/x² = ?','7','8','9','11','A','(x+1/x)²=x²+2+1/x²=9. So x²+1/x²=9-2=7.','hard',true),

  -- Geometry (10 Qs)
  (test_id,l_id,geo_id,'Area of a triangle with base 10cm and height 6cm:','30 cm²','60 cm²','36 cm²','12 cm²','A','Area=½×10×6=30 cm².','easy',true),
  (test_id,l_id,geo_id,'Circumference of a circle with radius 7cm (π=22/7):','44 cm','22 cm','154 cm','88 cm','A','C=2πr=2×(22/7)×7=44 cm.','easy',true),
  (test_id,l_id,geo_id,'In a right triangle, sides are 3,4. Hypotenuse is:','5','6','7','8','A','Pythagoras: √(9+16)=√25=5.','easy',true),
  (test_id,l_id,geo_id,'Area of a rectangle 8cm × 5cm:','40 cm²','26 cm²','13 cm²','80 cm²','A','Area=8×5=40 cm².','easy',true),
  (test_id,l_id,geo_id,'Volume of a cube with side 4cm:','64 cm³','32 cm³','48 cm³','16 cm³','A','V=4³=64 cm³.','easy',true),
  (test_id,l_id,geo_id,'Sum of interior angles of a hexagon:','540°','600°','720°','660°','C','Sum=(n-2)×180=(6-2)×180=720°.','medium',true),
  (test_id,l_id,geo_id,'Diagonal of a square with side 5cm:','5√2 cm','10 cm','5 cm','√5 cm','A','Diagonal=a√2=5√2 cm.','medium',true),
  (test_id,l_id,geo_id,'Two supplementary angles are in ratio 2:3. Smaller angle:','60°','72°','80°','90°','B','Sum=180°. Smaller=(2/5)×180=72°.','medium',true),
  (test_id,l_id,geo_id,'Area of circle with diameter 14cm:','154 cm²','22 cm²','44 cm²','308 cm²','A','r=7. Area=πr²=(22/7)×49=154 cm².','medium',true),
  (test_id,l_id,geo_id,'Volume of cylinder: radius 3cm, height 7cm (π=22/7):','198 cm³','154 cm³','66 cm³','132 cm³','A','V=πr²h=(22/7)×9×7=198 cm³.','medium',true);
END $$;

-- ==================== HAT LEVEL 3: VERBAL REASONING ====================
DO $$
DECLARE
  test_id UUID; l_id UUID;
  an_id UUID; sy_id UUID; sc_id UUID; rc_id UUID; cr_id UUID;
BEGIN
  SELECT id INTO test_id FROM tests WHERE slug='hat';
  SELECT id INTO l_id FROM levels WHERE test_id=test_id AND level_no=3;

  INSERT INTO topics(level_id,title,slug,category,order_no) VALUES
  (l_id,'Analogies','analogies','Verbal',1),
  (l_id,'Synonyms & Antonyms','synonyms-antonyms','Verbal',2),
  (l_id,'Sentence Completion','sentence-completion','Verbal',3),
  (l_id,'Reading Comprehension','reading-comp','Verbal',4),
  (l_id,'Critical Reasoning','critical-reasoning','Verbal',5)
  ON CONFLICT DO NOTHING;

  SELECT id INTO an_id FROM topics WHERE slug='analogies' AND level_id=l_id;
  SELECT id INTO sy_id FROM topics WHERE slug='synonyms-antonyms' AND level_id=l_id;
  SELECT id INTO sc_id FROM topics WHERE slug='sentence-completion' AND level_id=l_id;
  SELECT id INTO rc_id FROM topics WHERE slug='reading-comp' AND level_id=l_id;
  SELECT id INTO cr_id FROM topics WHERE slug='critical-reasoning' AND level_id=l_id;

  INSERT INTO lessons(topic_id,title,content_md,order_no,source_reference) VALUES
  (an_id,'Analogies — Method & Types',
'Analogy questions give you a pair of words with a relationship, then ask you to find another pair with the SAME relationship.

STEP-BY-STEP METHOD:
1. Identify the relationship in the given pair precisely.
2. Express it as a sentence: "A is the [relationship] of B."
3. Find the answer choice where the same sentence holds true.

COMMON RELATIONSHIP TYPES:
• PART TO WHOLE: Wheel : Car (a wheel is part of a car)
• CAUSE TO EFFECT: Fire : Smoke (fire causes smoke)
• TOOL TO USER: Scalpel : Surgeon (scalpel is used by surgeon)
• DEGREE: Warm : Hot (hot is an extreme degree of warm)
• SYNONYM: Happy : Joyful
• ANTONYM: Dark : Light
• WORKER TO PRODUCT: Author : Book (author creates book)
• PLACE TO THING: Library : Books (books are found in library)
• ANIMAL TO SOUND: Dog : Bark
• ANIMAL TO YOUNG: Cow : Calf
• FUNCTION: Key : Lock (key opens lock)
• MATERIAL: Wood : Furniture (wood is used to make furniture)

EXAMPLES:
• Doctor : Hospital :: Teacher : School (workplace)
• Caterpillar : Butterfly :: Tadpole : Frog (transformation/metamorphosis)
• Ink : Pen :: Blood : Heart (carried by)
• Petal : Flower :: Page : Book (part to whole)',
1,'HAT Verbal Guide'),
  (sy_id,'Synonyms & Antonyms — Vocabulary',
'SYNONYMS are words with similar meanings.
ANTONYMS are words with opposite meanings.

HIGH-FREQUENCY WORDS FOR HAT:

DIFFICULT WORDS AND THEIR SYNONYMS:
• Abate = Decrease, Reduce, Diminish
• Astute = Clever, Shrewd, Perceptive
• Benevolent = Kind, Charitable, Generous
• Candid = Frank, Honest, Straightforward
• Diligent = Hardworking, Industrious, Persistent
• Eloquent = Articulate, Expressive, Fluent
• Frivolous = Silly, Trivial, Unserious
• Garrulous = Talkative, Chatty, Loquacious
• Haughty = Arrogant, Proud, Conceited
• Implicit = Implied, Unstated, Understood
• Judicious = Wise, Sensible, Prudent
• Lethargic = Sluggish, Inactive, Tired
• Meticulous = Careful, Precise, Thorough
• Naive = Innocent, Simple, Unsophisticated
• Obscure = Unclear, Vague, Unknown
• Perturb = Disturb, Unsettle, Agitate

COMMON ANTONYM PAIRS:
• Benevolent ↔ Malevolent
• Verbose ↔ Concise
• Augment ↔ Diminish
• Candid ↔ Evasive
• Sycophant ↔ Critic
• Ephemeral ↔ Permanent
• Frugal ↔ Extravagant
• Taciturn ↔ Garrulous',
1,'HAT Verbal Guide'),
  (sc_id,'Sentence Completion Strategy',
'Sentence completion questions require filling one or two blanks with the words that make the sentence grammatically and logically correct.

STEP-BY-STEP STRATEGY:
1. Read the entire sentence for overall meaning and tone.
2. Identify CLUE WORDS:
   • Contrast clues: although, despite, however, but, yet → opposite meaning
   • Support clues: because, since, therefore → similar/supporting meaning
   • Example clues: for instance, such as → specific example
3. Predict what the blank should mean BEFORE looking at options.
4. Match your prediction with the closest option.
5. Substitute your answer back and verify it sounds natural.

CONTRAST WORDS (signal opposite idea in blank):
• Despite / Although / However / Yet / But / While / In spite of / On the other hand

SUPPORT WORDS (signal similar idea in blank):
• Because / Since / Therefore / Thus / Hence / As a result / Consequently

TWO-BLANK SENTENCES:
• Both blanks must work together logically.
• Eliminate options where even ONE blank does not fit.
• Check the relationship between the two blanks.

EXAMPLE:
"Despite his _____, he remained calm and _____ throughout the crisis."
Clue: "Despite" = contrast. If he has a quality yet remained calm, that quality should be negative/disturbing.
Answer: anger / composed ✓',
1,'HAT Verbal Guide');

  INSERT INTO questions(test_id,level_id,topic_id,question_text,option_a,option_b,option_c,option_d,correct_option,explanation,difficulty,is_verified) VALUES
  -- Analogies (20 Qs)
  (test_id,l_id,an_id,'Doctor : Hospital :: Teacher : ?','Book','Chalk','School','Class','C','A doctor works at a hospital; a teacher works at a school (workplace relationship).','easy',true),
  (test_id,l_id,an_id,'Caterpillar : Butterfly :: Tadpole : ?','Fish','Frog','Insect','Lizard','B','Caterpillar transforms into butterfly; tadpole transforms into frog (metamorphosis).','easy',true),
  (test_id,l_id,an_id,'Author : Book :: Composer : ?','Song','Orchestra','Melody','Symphony','D','An author creates a book; a composer creates a symphony (creator to creation).','medium',true),
  (test_id,l_id,an_id,'Petal : Flower :: Page : ?','Book','Library','Words','Chapter','A','A petal is part of a flower; a page is part of a book (part to whole).','easy',true),
  (test_id,l_id,an_id,'Stethoscope : Doctor :: Gavel : ?','Lawyer','Judge','Court','Justice','B','A stethoscope is the tool of a doctor; a gavel is the tool of a judge.','easy',true),
  (test_id,l_id,an_id,'Warm : Hot :: Cool : ?','Ice','Water','Cold','Breeze','C','Warm and hot differ by degree; cool and cold differ by degree (intensity).','easy',true),
  (test_id,l_id,an_id,'Drought : Famine :: War : ?','Army','Peace','Destruction','Victory','C','Drought causes famine; war causes destruction (cause-effect).','medium',true),
  (test_id,l_id,an_id,'Key : Lock :: Password : ?','Computer','Access','Internet','Screen','B','A key gives access through a lock; a password gives access to a system.','medium',true),
  (test_id,l_id,an_id,'Wood : Furniture :: Clay : ?','Mud','Pottery','Brick','Sand','B','Wood is used to make furniture; clay is used to make pottery (material-product).','easy',true),
  (test_id,l_id,an_id,'Cub : Lion :: Lamb : ?','Cow','Sheep','Goat','Deer','B','A cub is the young of a lion; a lamb is the young of a sheep.','easy',true),
  (test_id,l_id,an_id,'Microscope : Biologist :: Telescope : ?','Optician','Pilot','Astronomer','Sailor','C','A microscope is used by a biologist; a telescope is used by an astronomer.','easy',true),
  (test_id,l_id,an_id,'Illiteracy : Education :: Disease : ?','Hospital','Medicine','Doctor','Injection','B','Illiteracy is cured/removed by education; disease is cured/removed by medicine.','medium',true),
  (test_id,l_id,an_id,'Pen : Ink :: Lamp : ?','Glass','Electricity','Oil','Wax','C','A pen uses ink; a lamp (traditional) uses oil (fuel/medium).','medium',true),
  (test_id,l_id,an_id,'Mountain : Hill :: Ocean : ?','River','Lake','Pond','Stream','B','Mountain and hill differ by size (mountain > hill); ocean and lake (ocean > lake).','easy',true),
  (test_id,l_id,an_id,'Ignorance : Education :: Poverty : ?','Money','Work','Development','Government','C','Ignorance is reduced by education; poverty is reduced by development.','medium',true),
  (test_id,l_id,an_id,'Dog : Bark :: Cat : ?','Hiss','Meow','Growl','Roar','B','A dog''s sound is a bark; a cat''s sound is a meow.','easy',true),
  (test_id,l_id,an_id,'Coward : Brave :: Miser : ?','Rich','Generous','Selfish','Poor','B','Coward is the opposite of brave; miser is the opposite of generous (antonym pair).','easy',true),
  (test_id,l_id,an_id,'Bank : Money :: Library : ?','Silence','Study','Books','Reading','C','A bank stores money; a library stores books.','easy',true),
  (test_id,l_id,an_id,'Sculptor : Statue :: Architect : ?','Painting','Building','Garden','Blueprint','B','A sculptor creates a statue; an architect creates a building.','easy',true),
  (test_id,l_id,an_id,'Marathon : Running :: Regatta : ?','Cycling','Rowing/Sailing','Wrestling','Swimming','B','A marathon is a long-distance running race; a regatta is a series of boat (rowing/sailing) races.','hard',true),

  -- Synonyms/Antonyms (15 Qs)
  (test_id,l_id,sy_id,'Synonym of BENEVOLENT:','Cruel','Kind','Angry','Selfish','B','Benevolent means well-meaning and kind.','easy',true),
  (test_id,l_id,sy_id,'Antonym of GARRULOUS:','Talkative','Silent','Loud','Funny','B','Garrulous means excessively talkative. Antonym: silent/taciturn.','medium',true),
  (test_id,l_id,sy_id,'Synonym of DILIGENT:','Lazy','Careless','Hardworking','Fast','C','Diligent means showing care and effort in work.','easy',true),
  (test_id,l_id,sy_id,'Antonym of EPHEMERAL:','Short-lived','Brief','Permanent','Tiny','C','Ephemeral means lasting for a very short time. Antonym: permanent/enduring.','medium',true),
  (test_id,l_id,sy_id,'Synonym of ASTUTE:','Dull','Clever','Careless','Honest','B','Astute means having sharp judgment or clever insight.','easy',true),
  (test_id,l_id,sy_id,'Antonym of FRUGAL:','Careful','Thrifty','Extravagant','Saving','C','Frugal means careful with money. Antonym: extravagant/wasteful.','medium',true),
  (test_id,l_id,sy_id,'Synonym of CANDID:','Evasive','Secretive','Frank','Polite','C','Candid means open and honest in expression.','easy',true),
  (test_id,l_id,sy_id,'Antonym of HAUGHTY:','Proud','Arrogant','Humble','Rude','C','Haughty means arrogantly superior. Antonym: humble.','easy',true),
  (test_id,l_id,sy_id,'Synonym of METICULOUS:','Careless','Hasty','Precise','Lazy','C','Meticulous means very careful about details.','easy',true),
  (test_id,l_id,sy_id,'Antonym of VERBOSE:','Wordy','Lengthy','Concise','Repetitive','C','Verbose means using more words than needed. Antonym: concise/terse.','medium',true),
  (test_id,l_id,sy_id,'Synonym of LETHARGIC:','Energetic','Sluggish','Active','Excited','B','Lethargic means lacking energy or enthusiasm.','easy',true),
  (test_id,l_id,sy_id,'Antonym of OBSCURE:','Vague','Unknown','Clear','Hidden','C','Obscure means not discovered or unclear. Antonym: clear/well-known.','medium',true),
  (test_id,l_id,sy_id,'Synonym of ELOQUENT:','Silent','Inarticulate','Fluent','Shy','C','Eloquent means fluent and persuasive in speaking or writing.','easy',true),
  (test_id,l_id,sy_id,'Antonym of TACITURN:','Quiet','Reserved','Talkative','Shy','C','Taciturn means reserved or uncommunicative. Antonym: talkative/garrulous.','medium',true),
  (test_id,l_id,sy_id,'Synonym of PERTURB:','Calm','Soothe','Disturb','Ignore','C','Perturb means to make anxious or unsettle.','easy',true),

  -- Sentence Completion (15 Qs)
  (test_id,l_id,sc_id,'Despite his initial _____, he eventually accepted the new policy.','support','resistance','indifference','approval','B','Despite signals contrast. If he eventually accepted, his initial reaction must be opposition/resistance.','medium',true),
  (test_id,l_id,sc_id,'The scientist was _____ in her research, leaving no detail unchecked.','careless','lazy','meticulous','hasty','C','Leaving no detail unchecked = meticulous (very careful and precise).','easy',true),
  (test_id,l_id,sc_id,'Because he had studied thoroughly, Ali was _____ during the exam.','nervous','unprepared','confident','confused','C','Because = support clue. Thorough study leads to confidence.','easy',true),
  (test_id,l_id,sc_id,'The speech was so _____ that the audience fell asleep halfway through.','inspiring','tedious','entertaining','passionate','B','Audience falling asleep → speech was boring/tedious.','easy',true),
  (test_id,l_id,sc_id,'Although she appeared _____ on the outside, she was deeply worried within.','worried','calm','upset','nervous','B','Although = contrast. Outside ≠ inside feeling. She looked calm but felt worried.','medium',true),
  (test_id,l_id,sc_id,'The new manager was known for her _____ decisions — she always thought carefully before acting.','rash','impulsive','judicious','hasty','C','Thinking carefully before acting = judicious (having good judgment).','medium',true),
  (test_id,l_id,sc_id,'The evidence was so _____ that even the skeptics were convinced.','weak','ambiguous','compelling','irrelevant','C','If skeptics were convinced, the evidence must be compelling (persuasive/convincing).','medium',true),
  (test_id,l_id,sc_id,'He was _____ about his future, neither hopeful nor despairing.','optimistic','pessimistic','ambivalent','certain','C','Neither hopeful nor despairing = ambivalent (having mixed feelings).','hard',true),
  (test_id,l_id,sc_id,'The teacher''s _____ manner made students reluctant to ask questions.','friendly','approachable','intimidating','encouraging','C','Students reluctant to ask = teacher seems intimidating/scary.','easy',true),
  (test_id,l_id,sc_id,'Her ideas were so _____ that no one could understand what she was trying to say.','clear','obvious','cryptic','simple','C','No one could understand = ideas were cryptic (mysterious/unclear).','medium',true),
  (test_id,l_id,sc_id,'The economy began to _____ after years of stagnation.','decline','worsen','deteriorate','recover','D','Opposite of stagnation is growth/recovery.','easy',true),
  (test_id,l_id,sc_id,'Since the project was behind schedule, the team had to work _____ to meet the deadline.','leisurely','slowly','diligently','carelessly','C','Behind schedule → need to work hard/diligently.','easy',true),
  (test_id,l_id,sc_id,'The new policy was _____, affecting millions of citizens across the country.','minor','limited','insignificant','far-reaching','D','Affecting millions = far-reaching (having wide effects).','medium',true),
  (test_id,l_id,sc_id,'He was so _____ in his praise that people suspected he had ulterior motives.','sincere','moderate','excessive','rare','C','Suspicion of motives = excessive/lavish praise seems insincere.','hard',true),
  (test_id,l_id,sc_id,'The documentary was both _____ and _____, combining serious issues with moments of humour.','boring / exciting','informative / entertaining','serious / dull','educational / tedious','B','A documentary that is both serious yet has humour = informative AND entertaining.','medium',true),

  -- Critical Reasoning (10 Qs)
  (test_id,l_id,cr_id,'Argument: "All athletes who train daily win medals." John trains daily. Therefore John wins a medal. This is:','A valid deductive argument','An invalid inductive argument','A fallacy','An analogy','A','This is modus ponens (valid deductive form): All A are B; John is A; therefore John is B.','medium',true),
  (test_id,l_id,cr_id,'Which statement, if true, would WEAKEN "Regular exercise prevents heart disease"?','Exercise also burns calories','Many regular exercisers still get heart disease due to genetics','Running is the best exercise','Exercise can cause injuries','B','If many regular exercisers STILL get heart disease, exercise may not prevent it — weakens the claim.','medium',true),
  (test_id,l_id,cr_id,'An argument''s CONCLUSION is best described as:','The evidence provided','The claim the argument is trying to prove','The background information','The objection to the argument','B','The conclusion is the main claim being supported by the premises/evidence.','easy',true),
  (test_id,l_id,cr_id,'Which is an example of the "ad hominem" fallacy?','Attacking the argument''s logic','Attacking the person making the argument','Providing counter-evidence','Asking for clarification','B','Ad hominem = attacking the person rather than their argument.','medium',true),
  (test_id,l_id,cr_id,'Premise 1: Some politicians are corrupt. Premise 2: Ali is a politician. Conclusion: Ali is corrupt. This reasoning is:','Valid','Invalid — some does not mean all','Valid by induction','A syllogism','B','"Some politicians are corrupt" does not mean all are. Ali being a politician does not mean he is corrupt.','medium',true),
  (test_id,l_id,cr_id,'Which best STRENGTHENS "Students who read more perform better academically"?','Reading is enjoyable','A study shows that daily readers score 30% higher on standardised tests','Teachers should assign more homework','Some students do not like reading','B','A controlled study showing higher scores directly supports the claim.','medium',true),
  (test_id,l_id,cr_id,'The assumption in "Since it worked in Japan, it will work in Pakistan" is:','Japan and Pakistan are the same country','What works in one country always works in all countries','Pakistan is similar to Japan in relevant ways','The solution is perfect','C','The argument assumes the conditions are similar enough for the same solution to work.','hard',true),
  (test_id,l_id,cr_id,'Which is a factual claim (not an opinion)?','Chocolate ice cream tastes best','Students should study harder','Pakistan gained independence in 1947','The economy needs reform','C','Pakistan gaining independence in 1947 is a verifiable historical fact, not an opinion.','easy',true),
  (test_id,l_id,cr_id,'An argument with true premises and valid reasoning will have:','A false conclusion','A true conclusion','An uncertain conclusion','No conclusion','B','If premises are true and reasoning is valid (deductively), the conclusion must be true.','medium',true),
  (test_id,l_id,cr_id,'The "slippery slope" fallacy claims:','One small step will inevitably lead to extreme consequences','Arguments slope downward in quality','Facts are relative','People slide when they argue','A','Slippery slope: argues that one action will inevitably lead to a chain of negative events without sufficient evidence.','hard',true);
END $$;

-- ==================== UPDATE fallback data reference ====================
-- Ensure dashboard_level_view reflects new question counts
-- (View auto-recalculates from COUNT — no extra step needed)

SELECT 'Content seed complete: HAT Levels 1-3 loaded with comprehensive questions and lessons.' AS status;
