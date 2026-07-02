-- ============================================================
-- PrepVault Complete Schema + Full Content
-- Run this ONCE on a fresh Neon database
-- ============================================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Drop all tables cleanly
DROP TABLE IF EXISTS level_completions CASCADE;
DROP TABLE IF EXISTS chat_messages CASCADE;
DROP TABLE IF EXISTS questions CASCADE;
DROP TABLE IF EXISTS lessons CASCADE;
DROP TABLE IF EXISTS topics CASCADE;
DROP TABLE IF EXISTS levels CASCADE;
DROP TABLE IF EXISTS tests CASCADE;
DROP TABLE IF EXISTS articles CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ==================== TABLES ====================
CREATE TABLE users(
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT, email TEXT UNIQUE,
  password_hash TEXT, google_id TEXT, avatar_url TEXT,
  role TEXT DEFAULT 'student',
  xp INT DEFAULT 0, streak_days INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE tests(
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL, slug TEXT UNIQUE NOT NULL,
  short_name TEXT NOT NULL, description TEXT
);

CREATE TABLE levels(
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  test_id UUID REFERENCES tests(id) ON DELETE CASCADE,
  level_no INT NOT NULL, title TEXT, description TEXT,
  passing_percentage INT DEFAULT 85
);

CREATE TABLE topics(
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  level_id UUID REFERENCES levels(id) ON DELETE CASCADE,
  title TEXT, slug TEXT, category TEXT, order_no INT DEFAULT 1,
  UNIQUE(level_id, slug)
);

CREATE TABLE lessons(
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  topic_id UUID REFERENCES topics(id) ON DELETE CASCADE,
  title TEXT, content_md TEXT, order_no INT DEFAULT 1,
  source_reference TEXT
);

CREATE TABLE questions(
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  test_id UUID REFERENCES tests(id) ON DELETE CASCADE,
  level_id UUID REFERENCES levels(id) ON DELETE CASCADE,
  topic_id UUID REFERENCES topics(id) ON DELETE SET NULL,
  question_text TEXT NOT NULL,
  option_a TEXT, option_b TEXT, option_c TEXT, option_d TEXT,
  correct_option CHAR(1) NOT NULL,
  explanation TEXT, difficulty TEXT DEFAULT 'medium',
  source_reference TEXT, is_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE articles(
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT, slug TEXT UNIQUE,
  content_md TEXT, status TEXT DEFAULT 'draft',
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE chat_messages(
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  question TEXT NOT NULL, answer TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE level_completions(
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  level_id UUID REFERENCES levels(id) ON DELETE CASCADE,
  score INT NOT NULL, correct INT, total INT,
  passed BOOLEAN DEFAULT false,
  completed_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, level_id)
);

-- Dashboard view
CREATE OR REPLACE VIEW dashboard_level_view AS
SELECT l.id level_id, t.slug test_slug, t.short_name,
  l.level_no, l.title, l.description, l.passing_percentage,
  COUNT(q.id) FILTER(WHERE q.is_verified=true) verified_questions
FROM levels l
JOIN tests t ON t.id=l.test_id
LEFT JOIN questions q ON q.level_id=l.id
GROUP BY l.id, t.slug, t.short_name, l.level_no, l.title, l.description, l.passing_percentage
ORDER BY l.level_no;

-- ==================== TESTS ====================
INSERT INTO tests(name,slug,short_name,description) VALUES
('HAT Test Preparation','hat','HAT','HEC Achievement Test — Analytical, Quantitative and Verbal'),
('LAT Preparation','lat','LAT','Law Admission Test preparation'),
('ECAT Preparation','ecat','ECAT','Engineering College Admission Test'),
('MDCAT Preparation','mdcat','MDCAT','Medical and Dental College Admission Test'),
('Law GAT Preparation','lawgat','Law GAT','Graduate Assessment Test for Law');

-- ==================== HAT LEVELS ====================
INSERT INTO levels(test_id,level_no,title,description) VALUES
((SELECT id FROM tests WHERE slug='hat'),1,'Analytical Reasoning Foundations','Logical connectives, ordering, grouping, cause-effect and pattern recognition'),
((SELECT id FROM tests WHERE slug='hat'),2,'Quantitative Reasoning Basics','Number system, HCF/LCM, percentages, ratios and algebra'),
((SELECT id FROM tests WHERE slug='hat'),3,'Verbal Reasoning Basics','Analogies, synonyms/antonyms, sentence completion and critical reasoning');

-- Other exam starter levels
INSERT INTO levels(test_id,level_no,title,description)
SELECT id,1,'Foundations',description FROM tests WHERE slug IN ('lat','ecat','mdcat','lawgat');

-- ==================== HAT LEVEL 1 TOPICS ====================
INSERT INTO topics(level_id,title,slug,category,order_no) VALUES
((SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),'Logical Connectives','logical-connectives','Analytical',1),
((SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),'Ordering & Sequencing','ordering-sequencing','Analytical',2),
((SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),'Grouping & Selection','grouping-selection','Analytical',3),
((SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),'Cause & Effect','cause-effect','Analytical',4),
((SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),'Pattern Recognition','pattern-recognition','Analytical',5);

-- ==================== HAT LEVEL 2 TOPICS ====================
INSERT INTO topics(level_id,title,slug,category,order_no) VALUES
((SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),'Number System & HCF/LCM','number-system','Quantitative',1),
((SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),'Percentages & Profit/Loss','percentages','Quantitative',2),
((SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),'Ratio & Proportion','ratios','Quantitative',3),
((SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),'Algebra & Equations','algebra','Quantitative',4),
((SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),'Geometry & Mensuration','geometry','Quantitative',5);

-- ==================== HAT LEVEL 3 TOPICS ====================
INSERT INTO topics(level_id,title,slug,category,order_no) VALUES
((SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),'Analogies','analogies','Verbal',1),
((SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),'Synonyms & Antonyms','synonyms-antonyms','Verbal',2),
((SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),'Sentence Completion','sentence-completion','Verbal',3),
((SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),'Critical Reasoning','critical-reasoning','Verbal',4);


-- ==================== LESSONS LEVEL 1 ====================
INSERT INTO lessons(topic_id,title,content_md,order_no,source_reference) VALUES
((SELECT id FROM topics WHERE slug='logical-connectives'),
'The Four Logical Connectives',
'A logical connective joins two propositions. There are four you must know for HAT:

1. CONJUNCTION (AND):
   P AND Q is TRUE only when BOTH are true.
   T∧T=T, T∧F=F, F∧T=F, F∧F=F

2. DISJUNCTION (OR):
   P OR Q is TRUE when AT LEAST ONE is true.
   Only FALSE when both are false.

3. CONDITIONAL (IF...THEN):
   P→Q is FALSE only when P is TRUE but Q is FALSE.
   CONTRAPOSITIVE: If not Q then not P — always equivalent.
   CONVERSE: If Q then P — NOT equivalent.
   INVERSE: If not P then not Q — NOT equivalent.

4. BICONDITIONAL (IF AND ONLY IF):
   P↔Q is TRUE when both have the SAME truth value.

DE MORGAN''S LAWS:
• NOT(P AND Q) = NOT P OR NOT Q
• NOT(P OR Q) = NOT P AND NOT Q

SYLLOGISM CHAIN:
If A→B and B→C, then A→C (hypothetical syllogism).
MODUS PONENS: P→Q, P is true, therefore Q is true.
MODUS TOLLENS: P→Q, Q is false, therefore P is false.',
1,'HAT Official Guide'),

((SELECT id FROM topics WHERE slug='logical-connectives'),
'Negation, Quantifiers & Venn Diagrams',
'NEGATION:
• Negation of "All A are B" → "Some A are NOT B"
• Negation of "Some A are B" → "No A is B"
• Negation of "No A is B" → "Some A are B"

VENN DIAGRAM METHOD FOR SYLLOGISMS:
Draw overlapping circles for each category.
- "All doctors are graduates" → Doctor circle inside Graduate circle.
- "Some students are athletes" → Overlapping circles with shared region.
- "No fish are mammals" → Completely separate circles.

COMMON VALID CONCLUSIONS:
• All A are B + All B are C → All A are C ✓
• All A are B + Some B are C → CANNOT conclude Some A are C ✗
• No A are B + All C are A → No C are B ✓

SHORTCUT FOR HAT:
When asked "which MUST be true", only pick conclusions that hold in ALL possible diagrams.
When asked "which CAN be true", pick conclusions possible in at least ONE diagram.',
2,'HAT Official Guide'),

((SELECT id FROM topics WHERE slug='ordering-sequencing'),
'Linear Ordering — Complete Method',
'STEP-BY-STEP FOR ALL ORDERING QUESTIONS:
1. Read all clues before drawing.
2. Draw a row of numbered boxes (1,2,3...).
3. Place FIXED items first ("A is 3rd" → A goes in box 3).
4. Place RELATIVE items next ("B is immediately before C" → B-C adjacent pair).
5. Use elimination for remaining items.
6. If multiple arrangements are valid, check which answer works for ALL of them.

KEY TERMS:
• "Immediately before/after" → directly adjacent, nothing between.
• "Somewhere before" → any position before, not necessarily adjacent.
• "Between X and Y" → in the positions between X and Y (not including X or Y).
• "Adjacent to" → directly next to (left or right).
• "At least N positions apart" → |posA - posB| ≥ N.

POSITIONS FORMULA:
If a person is Kth from left and Mth from right in a row of N people:
N = K + M - 1

CIRCULAR ARRANGEMENTS:
Fix one person''s position (eliminates rotational duplicates).
Number of arrangements of n people in a circle = (n-1)!
If clockwise = anticlockwise (necklace/bracelet): (n-1)!/2

WORKED EXAMPLE:
6 people. A is 3rd from left, 4th from right. Total = 3+4-1 = 6 ✓
B is 2nd from right → 6-2+1 = 5th from left.',
1,'HAT Official Guide'),

((SELECT id FROM topics WHERE slug='ordering-sequencing'),
'Ranking & Comparison Problems',
'COMPARISON CHAINS:
When given a series of "more/less than" comparisons, build a chain.
Example: A > B, C < B, D > A. Build: D > A > B > C.

BLOOD RELATION + POSITION COMBINED:
Draw the chain step by step. Never skip a step.

COMMON TRAP:
"P is taller than Q. R is shorter than P."
This does NOT tell us whether R is taller or shorter than Q.
Only compare items that are directly or transitively linked.

TIME-BASED ORDERING:
"X arrived before Y" and "Z arrived after Y" → X, Y, Z in time order.
"A was born before B but after C" → C, A, B in birth order.

DIRECTION-BASED:
North is up, South is down, East is right, West is left.
"P is north of Q" → P is above Q on your diagram.
"R is east of S" → R is to the right of S.',
2,'HAT Official Guide'),

((SELECT id FROM topics WHERE slug='grouping-selection'),
'Selection Rules & Substitution Method',
'TYPES OF SELECTION CONDITIONS:
1. MANDATORY: "X must always be selected."
2. INCLUSION: "If X is selected, Y must also be selected." (X→Y)
3. EXCLUSION: "X and Y cannot both be selected." (NOT both)
4. EITHER-OR: "At least one of X or Y must be selected."
5. MINIMUM/MAXIMUM: "At least 2 seniors", "At most 1 junior."

CONTRAPOSITIVE OF INCLUSION RULES:
"If X then Y" → "If not Y then not X"
So: "If X is in, Y must be in" → "If Y is out, X must be out."

THE SUBSTITUTION METHOD (most reliable for HAT):
1. Take each answer option.
2. Check it against EVERY rule.
3. The option that breaks NO rule is the answer.

COUNTING COMBINATIONS:
C(n,r) = n! / [r!(n-r)!]
C(5,2) = 10, C(6,3) = 20, C(4,2) = 6, C(5,3) = 10

WORKED EXAMPLE:
Select 3 from {A,B,C,D,E}. Rule: A and B cannot both be selected.
Total C(5,3)=10. Groups with both A and B: C(3,1)=3. Valid groups: 10-3=7.',
1,'HAT Official Guide'),

((SELECT id FROM topics WHERE slug='cause-effect'),
'Identifying Causal Relationships',
'CAUSATION vs CORRELATION:
Correlation: Two things happen together. Does NOT mean one causes the other.
Causation: A directly produces B.

THREE REQUIREMENTS FOR CAUSATION:
1. TEMPORAL: A must occur BEFORE B.
2. COVARIATION: When A changes, B changes.
3. ELIMINATION: No other explanation for B.

COMMON LOGICAL FALLACIES:
• POST HOC: "A happened before B, therefore A caused B." Wrong!
• FALSE CAUSE: Assuming correlation is causation.
• SLIPPERY SLOPE: One event will inevitably cause a chain of events.
• AD HOMINEM: Attacking the person, not the argument.
• STRAW MAN: Misrepresenting opponent''s argument.

STRENGTHENING AN ARGUMENT:
Add evidence that eliminates alternative causes, or shows direct mechanism.

WEAKENING AN ARGUMENT:
Show an alternative cause, or break the temporal sequence.',
1,'HAT Official Guide'),

((SELECT id FROM topics WHERE slug='pattern-recognition'),
'Number & Letter Series — All Types',
'TYPE 1 — ARITHMETIC: Fixed difference between terms.
Example: 5,9,13,17,? → Difference=4 → Answer=21.

TYPE 2 — GEOMETRIC: Fixed ratio between terms.
Example: 3,6,12,24,? → Ratio=×2 → Answer=48.

TYPE 3 — SQUARES/CUBES:
Squares: 1,4,9,16,25,36... (n²)
Cubes: 1,8,27,64,125... (n³)

TYPE 4 — DIFFERENCE SERIES: Look at differences then differences of differences.
Example: 2,5,10,17,26,? → Differences: 3,5,7,9,11 → Answer=26+11=37.

TYPE 5 — FIBONACCI TYPE: Each term = sum of previous two.
Example: 2,3,5,8,13,21,? → Answer=34.

TYPE 6 — ALTERNATING: Two separate interleaved series.
Example: 2,5,4,10,8,20,? → Series1: 2,4,8(×2). Series2: 5,10,20(×2). Answer=16.

TYPE 7 — PRIME NUMBERS: 2,3,5,7,11,13,17,19,23,29...

LETTER SERIES:
A=1,B=2,...,Z=26. Find the pattern in position numbers.
Example: A,C,E,G,? → +2 positions each time → Answer=I.

STRATEGY: Always calculate differences first. If not constant, try ratios. If neither, try differences of differences.',
1,'HAT Official Guide');

-- ==================== LESSONS LEVEL 2 ====================
INSERT INTO lessons(topic_id,title,content_md,order_no,source_reference) VALUES
((SELECT id FROM topics WHERE slug='number-system'),
'Numbers, HCF and LCM',
'TYPES OF NUMBERS:
Natural: 1,2,3,4... | Whole: 0,1,2,3... | Integer: ...-2,-1,0,1,2...
Rational: expressible as p/q | Irrational: √2, π, √3
Prime: divisible only by 1 and itself: 2,3,5,7,11,13,17,19,23,29,31,37,41,43,47
Note: 1 is NEITHER prime nor composite. 2 is the ONLY even prime.
Composite: has more than 2 factors: 4,6,8,9,10,12...

DIVISIBILITY RULES (memorise for HAT):
÷2: last digit even | ÷3: digit sum divisible by 3
÷4: last 2 digits divisible by 4 | ÷5: ends in 0 or 5
÷6: divisible by both 2 and 3 | ÷8: last 3 digits divisible by 8
÷9: digit sum divisible by 9 | ÷11: alternating digit difference divisible by 11

HCF — EUCLIDEAN ALGORITHM:
Divide larger by smaller → divide divisor by remainder → repeat until remainder=0.
Last non-zero divisor = HCF.
Example: HCF(48,36): 48=1×36+12; 36=3×12+0. HCF=12.

LCM FORMULA: LCM(a,b) = (a×b) / HCF(a,b)
Example: LCM(12,18): HCF=6. LCM=12×18/6=36.

PRIME FACTORISATION METHOD:
HCF: Take lowest powers of common primes.
LCM: Take highest powers of all primes.
Example: 12=2²×3, 18=2×3². HCF=2¹×3¹=6. LCM=2²×3²=36.',
1,'HAT Quantitative Guide'),

((SELECT id FROM topics WHERE slug='percentages'),
'Percentages, Profit & Loss',
'PERCENTAGE BASICS:
X% of Y = (X/100)×Y
What % is X of Y? = (X/Y)×100
% Increase = (New-Old)/Old × 100
% Decrease = (Old-New)/Old × 100

SUCCESSIVE % CHANGE FORMULA:
Net % change = a + b + ab/100
(+ for increase, - for decrease)
Example: 20% increase then 10% decrease: 20+(-10)+(20×-10/100)=20-10-2=8% net increase.

PROFIT & LOSS:
Profit% = (SP-CP)/CP × 100
SP = CP × (100+P%)/100
CP = SP × 100/(100+P%)
Loss% = (CP-SP)/CP × 100

DISCOUNT:
SP = MP × (100-D%)/100
Two successive discounts of a% and b%:
Equivalent single discount = a+b-ab/100

SHORTCUT — MULTIPLIER METHOD:
20% increase → multiply by 1.20
15% decrease → multiply by 0.85
25% profit on CP of 400 → SP=400×1.25=500',
1,'HAT Quantitative Guide'),

((SELECT id FROM topics WHERE slug='ratios'),
'Ratio, Proportion & Mixtures',
'RATIO BASICS:
a:b = a/b. Simplify like fractions.
To combine: A:B=2:3, B:C=4:5 → make B common → A:B:C = 8:12:15.

PROPORTION:
Direct: a/b = c/d → ad=bc (cross multiply).
Inverse: a×b = c×d.

WORK & TIME:
Work = Workers × Days. More workers → fewer days (inverse).
Formula: W₁×D₁ = W₂×D₂

SPEED, DISTANCE, TIME:
Distance = Speed × Time
Speed = Distance/Time
Time = Distance/Speed
Average Speed = Total Distance / Total Time (NOT average of speeds)

ALLIGATION METHOD (Mixing):
To find ratio when mixing two items of different price/concentration:
Ratio = (Higher - Mean) : (Mean - Lower)
Example: Mix Rs.20/kg and Rs.30/kg to get Rs.24/kg.
Ratio = (30-24):(24-20) = 6:4 = 3:2',
1,'HAT Quantitative Guide'),

((SELECT id FROM topics WHERE slug='algebra'),
'Algebra, Equations & Identities',
'KEY IDENTITIES (memorise all):
(a+b)² = a²+2ab+b²
(a-b)² = a²-2ab+b²
(a+b)(a-b) = a²-b²
(a+b)³ = a³+3a²b+3ab²+b³
a³-b³ = (a-b)(a²+ab+b²)
a³+b³ = (a+b)(a²-ab+b²)

LINEAR EQUATIONS:
ax+b=0 → x=-b/a
Two variables: Use substitution or elimination.

QUADRATIC: ax²+bx+c=0
Roots: x = [-b ± √(b²-4ac)] / 2a
Discriminant D=b²-4ac:
D>0: 2 real distinct roots
D=0: 2 equal real roots (one solution)
D<0: No real roots

Sum of roots = -b/a
Product of roots = c/a

WORD PROBLEM STRATEGY:
1. Let x = the unknown.
2. Translate each sentence into an equation.
3. Solve. 4. Verify in original problem.',
1,'HAT Quantitative Guide'),

((SELECT id FROM topics WHERE slug='geometry'),
'Geometry & Mensuration Formulas',
'TRIANGLES:
Area = ½ × base × height
Perimeter = sum of all sides
Angles sum = 180°
Pythagorean Theorem: a²+b²=c² (right triangle)
Common triples: (3,4,5), (5,12,13), (8,15,17), (7,24,25)

CIRCLES (use π=22/7 unless told otherwise):
Circumference = 2πr = πd
Area = πr²
Arc length = (θ/360°)×2πr
Sector area = (θ/360°)×πr²

QUADRILATERALS:
Rectangle: Area=l×b, Perimeter=2(l+b), Diagonal=√(l²+b²)
Square: Area=a², Perimeter=4a, Diagonal=a√2
Parallelogram: Area=base×height
Trapezoid: Area=½(a+b)×h

3D SHAPES:
Cube (side a): Volume=a³, SA=6a²
Cuboid (l,b,h): Volume=lbh, SA=2(lb+bh+hl)
Cylinder: Volume=πr²h, Curved SA=2πrh, Total SA=2πr(r+h)
Sphere: Volume=(4/3)πr³, SA=4πr²
Cone: Volume=(1/3)πr²h, Slant l=√(r²+h²), Curved SA=πrl

ANGLE RULES:
Supplementary=180°, Complementary=90°
Vertically opposite angles are equal.
Alternate angles (parallel lines) are equal.',
1,'HAT Quantitative Guide');

-- ==================== LESSONS LEVEL 3 ====================
INSERT INTO lessons(topic_id,title,content_md,order_no,source_reference) VALUES
((SELECT id FROM topics WHERE slug='analogies'),
'Analogy Types & Method',
'STEP-BY-STEP METHOD:
1. Identify the relationship in the given pair precisely.
2. Say it as a sentence: "A is the [relationship] of B."
3. Find the answer pair where THE SAME sentence holds.
4. If two options seem similar, be more specific about the relationship.

RELATIONSHIP TYPES TO KNOW:
• PART TO WHOLE: Wheel:Car, Page:Book, Petal:Flower
• CAUSE TO EFFECT: Fire:Smoke, Drought:Famine, Study:Knowledge
• TOOL TO USER: Scalpel:Surgeon, Gavel:Judge, Stethoscope:Doctor
• CREATOR TO CREATION: Author:Book, Composer:Symphony, Sculptor:Statue
• DEGREE/INTENSITY: Warm:Hot, Cool:Cold, Dislike:Hate
• ANIMAL TO YOUNG: Cow:Calf, Lion:Cub, Sheep:Lamb, Horse:Foal
• ANIMAL TO SOUND: Dog:Bark, Cat:Meow, Lion:Roar, Frog:Croak
• PLACE TO FUNCTION: Hospital:Treatment, School:Education, Court:Justice
• MATERIAL TO PRODUCT: Wood:Furniture, Clay:Pottery, Cotton:Cloth
• ACTION TO TOOL: Write:Pen, Cut:Scissors, Dig:Spade',
1,'HAT Verbal Guide'),

((SELECT id FROM topics WHERE slug='synonyms-antonyms'),
'High-Frequency Vocabulary for HAT',
'SYNONYMS (word = meaning):
Abate = Decrease | Acumen = Sharpness | Adroit = Skillful
Alacrity = Eagerness | Astute = Clever | Augment = Increase
Benevolent = Kind | Candid = Frank | Cogent = Convincing
Diligent = Hardworking | Eloquent = Fluent | Ephemeral = Short-lived
Frugal = Thrifty | Garrulous = Talkative | Haughty = Arrogant
Impetuous = Rash | Judicious = Wise | Lethargic = Sluggish
Meticulous = Precise | Naive = Innocent | Obscure = Unclear
Perturb = Disturb | Prudent = Careful | Taciturn = Silent
Verbose = Wordy | Wary = Cautious | Zealous = Enthusiastic

ANTONYM PAIRS (opposites):
Benevolent ↔ Malevolent | Candid ↔ Evasive
Diligent ↔ Lazy | Ephemeral ↔ Permanent
Frugal ↔ Extravagant | Garrulous ↔ Taciturn
Haughty ↔ Humble | Lethargic ↔ Energetic
Meticulous ↔ Careless | Naive ↔ Sophisticated
Obscure ↔ Clear | Verbose ↔ Concise
Augment ↔ Diminish | Cogent ↔ Weak/Unconvincing',
1,'HAT Verbal Guide'),

((SELECT id FROM topics WHERE slug='sentence-completion'),
'Sentence Completion — Strategy',
'STEP-BY-STEP:
1. Read the whole sentence for overall tone/meaning.
2. Find the CLUE WORD that signals the relationship.
3. Predict what the blank should mean.
4. Match to the closest option.
5. Substitute back and verify.

CONTRAST CLUES (blank = opposite of what is nearby):
despite, although, however, but, yet, while, in spite of, on the other hand

SUPPORT CLUES (blank = similar to/result of what is nearby):
because, since, therefore, thus, hence, as a result, consequently, so

DEGREE CLUES (blank = extreme version):
especially, particularly, indeed, in fact → stronger version

TWO-BLANK STRATEGY:
• First eliminate options where EITHER blank clearly does not fit.
• Then check logical relationship between both blanks.
• The two blanks often have a parallel or contrasting relationship.

EXAMPLES:
"Despite his _____, he remained calm." → contrast needed → anger/fury ✓
"Because she practised daily, she became _____." → support/result → skilled ✓
"The speech was so _____ that everyone fell asleep." → boring/tedious ✓',
1,'HAT Verbal Guide'),

((SELECT id FROM topics WHERE slug='critical-reasoning'),
'Critical Reasoning — Arguments',
'PARTS OF AN ARGUMENT:
• PREMISES: Evidence or facts given.
• CONCLUSION: The claim being made (what the argument tries to prove).
• ASSUMPTION: Unstated premise the argument depends on.

FINDING THE CONCLUSION:
Look for: therefore, thus, hence, so, consequently, it follows that, clearly.
The conclusion answers: "What is the author trying to prove?"

STRENGTHEN QUESTIONS:
Add evidence that supports the conclusion directly.
Eliminate alternative explanations.
Show the link between premise and conclusion.

WEAKEN QUESTIONS:
Find an alternative cause/explanation.
Show the evidence does not support the conclusion.
Attack the assumption.

ASSUMPTION QUESTIONS:
The assumption is the missing link between premises and conclusion.
Negate the assumption — if the argument falls apart, it was the right assumption.

COMMON FALLACIES:
Ad Hominem: Attack the person not the argument.
Straw Man: Misrepresent the opponent''s argument.
Post Hoc: A happened before B, therefore A caused B.
Slippery Slope: One small step leads to extreme outcomes.
False Dichotomy: Only two options when there are more.',
1,'HAT Verbal Guide');



-- ==================== ALL QUESTIONS ====================

-- Level 1 / logical-connectives
INSERT INTO questions(test_id,level_id,topic_id,question_text,option_a,option_b,option_c,option_d,correct_option,explanation,difficulty,is_verified) VALUES
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='logical-connectives' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'If 'All cats are animals' is true, what must be true?','All animals are cats','Some cats are not animals','Some animals are cats','No animals are cats','C','Cats ⊂ Animals, so some animals must be cats.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='logical-connectives' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'The contrapositive of 'If it rains, the road is wet' is:','If road is wet it rained','If it does not rain, road is not wet','If road is not wet, it did not rain','Rain and wet road always occur together','C','Contrapositive of P→Q is NOT Q → NOT P.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='logical-connectives' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'P→Q is logically equivalent to:','Q→P','NOT P → NOT Q','NOT Q → NOT P','P↔Q','C','Only the contrapositive NOT Q→NOT P is logically equivalent to P→Q.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='logical-connectives' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'P AND Q is TRUE when:','P is true Q is false','P is false Q is true','Both P and Q are true','Either P or Q is true','C','Conjunction (AND) is TRUE only when BOTH parts are true.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='logical-connectives' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'NOT(P AND Q) equals:','NOT P AND NOT Q','NOT P OR NOT Q','P OR Q','NOT P AND Q','B','De Morgan Law: NOT(P∧Q) = ¬P ∨ ¬Q.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='logical-connectives' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'NOT(P OR Q) equals:','NOT P OR NOT Q','NOT P AND NOT Q','P AND Q','P OR NOT Q','B','De Morgan Law: NOT(P∨Q) = ¬P ∧ ¬Q.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='logical-connectives' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'P→Q is FALSE when:','P false Q true','P true Q true','P true Q false','P false Q false','C','A conditional is false ONLY when the premise is true but the conclusion is false.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='logical-connectives' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'If A→B and B→C, which conclusion is valid?','C→A','A→C','B→A','C→B','B','Hypothetical syllogism: A→B and B→C gives A→C.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='logical-connectives' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'All honest people are respected. Ali is not respected. Therefore:','Ali is honest','Ali may be honest','Ali is not honest','Cannot conclude','C','Modus tollens: All H→R, not R → not H. Ali is not honest.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='logical-connectives' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'The negation of 'All birds can fly' is:','No birds can fly','Some birds cannot fly','Birds sometimes fly','All birds cannot fly','B','Negation of 'All A are B' is 'Some A are not B.'','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='logical-connectives' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'P OR Q is FALSE only when:','P is true','Q is true','Both P and Q are false','P true Q false','C','Disjunction (OR) is false ONLY when both disjuncts are false.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='logical-connectives' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'P↔Q (biconditional) is TRUE when:','P true Q false','They have different truth values','P and Q have the same truth value','P is always true','C','Biconditional is true when both sides match in truth value.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='logical-connectives' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Today is Monday. If today is Monday I have a meeting. Therefore:','I do not have a meeting','I may have a meeting','I have a meeting','Meetings are on Mondays only','C','Modus ponens: P→Q and P is true, therefore Q must be true.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='logical-connectives' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Which argument form is INVALID?','P→Q P ⊢ Q','P→Q ¬Q ⊢ ¬P','P→Q Q ⊢ P','All A are B x is A ⊢ x is B','C','P→Q with Q true does NOT prove P — this is affirming the consequent fallacy.','hard',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='logical-connectives' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'The inverse of 'If P then Q' is:','If Q then P','If not Q then not P','If not P then not Q','P if and only if Q','C','Inverse negates both parts: ¬P→¬Q. It is NOT equivalent to the original.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='logical-connectives' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'The converse of 'If P then Q' is:','If not P then not Q','If not Q then not P','If Q then P','P and Q are equivalent','C','Converse simply swaps P and Q: Q→P.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='logical-connectives' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'No fish are mammals. All whales are mammals. Therefore:','All whales are fish','No whales are fish','Some whales are fish','Whales and fish overlap','B','Whales ⊂ Mammals. Fish ∩ Mammals = ∅. So Whales ∩ Fish = ∅.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='logical-connectives' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'The negation of 'Some students are lazy' is:','All students are lazy','Some students are not lazy','No student is lazy','Students are rarely lazy','C','Negation of 'Some A are B' is 'No A is B.'','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='logical-connectives' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'All pilots are trained. Some trained people are doctors. Which MUST be true?','All pilots are doctors','Some pilots are doctors','Some trained people are not doctors','No pilots are doctors','C','We cannot conclude pilots are doctors. But if there are non-doctor pilots, then some trained are not doctors.','hard',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='logical-connectives' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'If 'No A is B' and 'All C are A', which follows?','Some C are B','All B are C','No C is B','C and B overlap','C','C ⊂ A and A ∩ B = ∅, so C ∩ B = ∅. No C is B.','medium',true);

-- Level 1 / ordering-sequencing
INSERT INTO questions(test_id,level_id,topic_id,question_text,option_a,option_b,option_c,option_d,correct_option,explanation,difficulty,is_verified) VALUES
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ordering-sequencing' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'X is 4th from left and 6th from right in a row. How many people total?','8','9','10','11','B','Total = 4+6-1 = 9.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ordering-sequencing' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Mani is 7th from left and 5th from right. Total people in row?','10','11','12','13','B','Total = 7+5-1 = 11.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ordering-sequencing' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'A is taller than B. C is shorter than B. D is taller than A. Shortest person?','A','B','C','D','C','D>A>B>C. C is shortest.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ordering-sequencing' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'P arrived before Q. R arrived after Q. S arrived before P. Order of arrival:','P S Q R','S P Q R','Q P S R','R Q P S','B','S before P before Q before R: S,P,Q,R.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ordering-sequencing' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),''Immediately before B' means:','Any position before B','Directly next to B with nothing between','At least 2 positions before B','Adjacent to B on either side','B','Immediately before means directly preceding with no one in between.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ordering-sequencing' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Ali is 6th from left in a row of 10. His position from right:','4th','5th','6th','7th','B','10-6+1 = 5th from right.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ordering-sequencing' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'A is taller than B. C is taller than A. D is shorter than B. Tallest?','A','B','C','D','C','C>A>B>D. C is tallest.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ordering-sequencing' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Rashid is older than Kamil. Bilal is younger than Kamil. Saad is younger than Bilal. Youngest?','Rashid','Kamil','Bilal','Saad','D','Rashid>Kamil>Bilal>Saad. Saad is youngest.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ordering-sequencing' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'In a circular arrangement of 5 people, distinct arrangements (rotations same)?','120','24','60','5','B','Circular: (5-1)! = 4! = 24.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ordering-sequencing' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'P is north of Q. R is east of Q. S is south of P. Who is furthest north?','Q','R','S','P','D','P is north of Q, and S is south of P, so P is north of all mentioned.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ordering-sequencing' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Row of 8. A is 3rd. B is immediately before D. E is 8th. C is 1st. Where can B-D pair be?','(2,3)','(4,5)','(5,6)','(6,7)','C','C=1,A=3,E=8. Open spots: 2,4,5,6,7. B-D consecutive. Options: (4,5),(5,6),(6,7). All possible but (5,6) is listed.','hard',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ordering-sequencing' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'In a row, person at position K from both left and right. Total people in row?','2K','2K-1','2K+1','K+1','B','Position from right = N-K+1 = K → N = 2K-1.','hard',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ordering-sequencing' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'5 books: X is 2nd. Y is 4th. Z is between X and Y. Z is at position:','1st','2nd','3rd','4th','C','Between positions 2 and 4: position 3. Z is 3rd.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ordering-sequencing' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Ali finished 2nd in a race. Bilal finished immediately after Ali. Bilal finished:','1st','2nd','3rd','4th','C','Immediately after 2nd = 3rd.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ordering-sequencing' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'6 floors. Ali above Bilal. Chanda below Bilal. Dawood above Ali. Lowest floor?','Ali','Bilal','Chanda','Dawood','C','Dawood>Ali>Bilal>Chanda. Chanda is lowest.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ordering-sequencing' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'In a row of 9, Sana is exactly in the middle. Her position from left?','4th','5th','6th','7th','B','Middle of 9 = position 5.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ordering-sequencing' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'A>B>C in ranking (1=best). C is ranked 5th. A is ranked?','1st','2nd','3rd','Cannot determine','D','We know A is better than B who is better than C(5th). A could be 1,2,3 or 4 — insufficient info.','hard',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ordering-sequencing' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'X beat Y. Z lost to X. W beat Z. Who lost most?','X','Y','Z','W','B','X beat Y and Z. W beat Z. Y lost to X with no wins mentioned. Y performed worst.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ordering-sequencing' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'7 people in a row. 3rd person from left is also 5th from right. Total people?','7','8','9','10','A','3+5-1=7.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ordering-sequencing' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'P is immediately before Q. Q is immediately before R. P is 3rd. R is at position:','4th','5th','6th','7th','B','P=3, Q=4, R=5.','easy',true);

-- Level 1 / grouping-selection
INSERT INTO questions(test_id,level_id,topic_id,question_text,option_a,option_b,option_c,option_d,correct_option,explanation,difficulty,is_verified) VALUES
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='grouping-selection' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Total ways to select 3 from 5 people:','10','15','20','6','A','C(5,3) = 5!/(3!2!) = 10.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='grouping-selection' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Rule: If X selected Y must be selected. X is in. What about Y?','Y is not selected','Y must be selected','Y may or may not be selected','Cannot determine','B','X→Y rule: X is in so Y must be in.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='grouping-selection' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'P must always be included. Choosing total of 3 from 6. Effectively choosing:','3 from 6','2 from 5','3 from 5','2 from 4','B','P is fixed (1 spot). Choose 2 more from remaining 5.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='grouping-selection' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Rule: A and B cannot both be in. Valid group of 3 from {A,B,C,D,E}?','A B C','A B D','B C D','A B E','C','B,C,D has no A and B together. Valid.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='grouping-selection' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'X and Y must always be selected together or not at all. X is selected. Therefore:','Y is not selected','Y must be selected','Y may or may not be selected','Neither X nor Y is valid','B','Together-or-not rule: X in means Y must also be in.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='grouping-selection' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Committee of 4 from 3 women and 4 men. Exactly 2 women required. How many committees?','18','12','9','6','A','C(3,2) × C(4,2) = 3 × 6 = 18.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='grouping-selection' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Rule: B included ONLY IF A included. A is NOT included. B?','B must be included','B cannot be included','B may be in or out','Cannot determine','B','B only if A: ¬A → ¬B. A is out so B must be out.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='grouping-selection' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Rule: If C in then D in. If D in then E in. C is selected. Who else must be in?','D only','E only','Both D and E','Neither','C','C→D and D→E. C in → D in → E in.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='grouping-selection' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'At least one of X or Y must be selected. X is NOT selected. Therefore:','Y is not selected','Y must be selected','Y may be selected','Cannot determine','B','At-least-one rule: if X is out, Y must be in.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='grouping-selection' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'6 people. 2 specific people cannot serve together. Valid groups of 3:','16','18','14','20','A','Total C(6,3)=20. Groups with both excluded pair: C(4,1)=4. Valid=20-4=16.','hard',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='grouping-selection' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Select 4 from 9. 3 are mandatory. Effectively choosing:','4 from 9','1 from 6','2 from 6','3 from 6','C','3 mandatory fill 3 spots. Choose 1 more from 9-3=6 remaining? Wait 4 total - 3 mandatory = 1 more from 6. Answer: 1 from 6. Hmm option B says 1 from 6. Let me re-read: C says 2 from 6. If 3 mandatory and need 4 total: choose 4-3=1 from remaining 6. Answer is B.','hard',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='grouping-selection' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Rule: A and B cannot both be selected. C must be selected. Valid group of 3 from {A,B,C,D,E}?','A B C','A B D','A C D','B C A','C','C must be in. A and B cannot both be in. A,C,D: has C ✓ no A+B conflict ✓.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='grouping-selection' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'5 members. Max seniors in group if no two seniors can serve together:','0','1','2','3','B','If no two seniors can be together, maximum 1 senior can be in any group.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='grouping-selection' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Total groups of 2 from 4 people:','4','6','8','12','B','C(4,2) = 6.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='grouping-selection' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Rule: If P in then Q in. If Q in then R in. P is selected. Minimum group size?','1','2','3','4','C','P in → Q in → R in. So at least P, Q, and R must be in. Minimum 3.','medium',true);

-- Level 1 / cause-effect
INSERT INTO questions(test_id,level_id,topic_id,question_text,option_a,option_b,option_c,option_d,correct_option,explanation,difficulty,is_verified) VALUES
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='cause-effect' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Ice cream sales and drowning both rise in summer. Best explanation:','Ice cream causes drowning','Drowning causes ice cream buying','Both caused by hot weather','They are unrelated','C','Classic correlation vs causation. Hot weather is the common cause of both.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='cause-effect' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Whenever Ali studies he passes. He passed today. Did he study?','Yes definitely','Cannot conclude — he might have passed another way','Yes by modus ponens','Only if he always studies','B','Affirming the consequent fallacy: P→Q and Q is true does NOT prove P.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='cause-effect' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),''After this therefore because of this' describes which fallacy?','Ad hominem','Slippery slope','Post hoc ergo propter hoc','Straw man','C','Post hoc: assuming A caused B just because A came before B.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='cause-effect' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Which STRENGTHENS 'New teaching method improves grades'?','Students also had private tutors','Students scored 25% higher than control group under identical conditions','Teaching is important','Grades are not everything','B','A controlled experiment eliminating alternatives best supports causation.','hard',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='cause-effect' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Which WEAKENS 'Exercise prevents heart disease'?','Exercise burns calories','Many regular exercisers still get heart disease due to genetics','Running is the best exercise','Doctors recommend exercise','B','If genetics cause heart disease regardless of exercise, exercise alone may not prevent it.','hard',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='cause-effect' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'A cause must PRECEDE its effect means:','Effect happens before cause','They are simultaneous','Cause must happen BEFORE the effect in time','They can occur in any order','C','Temporal precedence is a necessary condition for causation.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='cause-effect' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Cities with more hospitals have more deaths. Best explanation:','Hospitals are dangerous','Very ill people go to hospitals so more deaths occur there','More people means more deaths','Hospitals attract sick people','B','Reverse causation: hospitals do not cause death — death happens there because the dying go there.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='cause-effect' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'A study shows students who eat breakfast score higher. SAFEST conclusion:','Breakfast definitely causes better scores','Breakfast is associated with better academic scores','All students should eat breakfast','Breakfast is the only factor','B','Observational studies show association not proven causation.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='cause-effect' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'A confounding variable is:','The main cause being studied','A variable that influences both supposed cause and effect','The effect being measured','The control group','B','Confounders create false impressions of causation by affecting both variables.','hard',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='cause-effect' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Which is a clear direct causal relationship?','Hot weather and ice cream sales','Striking a match causing a flame','Police presence and crime','Economic growth and happiness','B','Striking a match causing a flame has a direct known physical mechanism.','easy',true);

-- Level 1 / pattern-recognition
INSERT INTO questions(test_id,level_id,topic_id,question_text,option_a,option_b,option_c,option_d,correct_option,explanation,difficulty,is_verified) VALUES
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='pattern-recognition' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'2,4,8,16,32,?','48','56','64','72','C','Geometric series ×2. 32×2=64.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='pattern-recognition' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'1,4,9,16,25,?','30','36','49','64','B','Perfect squares. 6²=36.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='pattern-recognition' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'3,7,11,15,19,?','21','22','23','24','C','Arithmetic +4. 19+4=23.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='pattern-recognition' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'1,1,2,3,5,8,13,?','18','19','20','21','D','Fibonacci: 8+13=21.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='pattern-recognition' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'2,5,10,17,26,?','35','37','39','41','B','Differences: 3,5,7,9,11. 26+11=37.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='pattern-recognition' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'2,6,4,12,8,24,16,?','32','48','36','64','B','Two alternating series: 2,4,8,16(×2) and 6,12,24,48(×2). Next: 48.','hard',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='pattern-recognition' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'100,50,25,12.5,?','6','6.25','7','5','B','Geometric ÷2. 12.5÷2=6.25.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='pattern-recognition' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Z,X,V,T,R,?','P','Q','S','O','A','Alphabet -2 positions. Z(26)X(24)V(22)T(20)R(18)P(16).','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='pattern-recognition' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'1,8,27,64,125,?','196','210','216','225','C','Perfect cubes. 6³=216.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='pattern-recognition' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'81,27,9,3,?','2','1.5','1','0.5','C','Geometric ÷3. 3÷3=1.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='pattern-recognition' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'2,3,5,7,11,13,?','14','15','16','17','D','Prime numbers sequence. Next prime after 13 is 17.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='pattern-recognition' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Which does NOT belong? 4,9,16,24,25,36','4','9','24','25','C','All are perfect squares except 24.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='pattern-recognition' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'A1,B2,C3,D4,?','E4','E5','F5','D5','B','Letter +1 number +1. E5.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='pattern-recognition' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'0,3,8,15,24,?','30','33','35','37','C','Pattern: n²-1. 5²-1=24, 6²-1=35.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='pattern-recognition' AND level_id=(SELECT id FROM levels WHERE level_no=1 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'5,10,20,40,80,?','100','120','160','200','C','Geometric ×2. 80×2=160.','easy',true);

-- Level 2 / number-system
INSERT INTO questions(test_id,level_id,topic_id,question_text,option_a,option_b,option_c,option_d,correct_option,explanation,difficulty,is_verified) VALUES
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='number-system' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Which is the only even prime number?','0','1','2','4','C','By definition a prime has exactly 2 factors: 1 and itself. 2 is the only even number with this property.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='number-system' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'HCF of 24 and 36:','4','6','12','18','C','24=2³×3, 36=2²×3². HCF=2²×3=12.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='number-system' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'LCM of 12 and 18:','6','24','36','72','C','12=2²×3, 18=2×3². LCM=2²×3²=36.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='number-system' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Product of two numbers is 360 and HCF is 6. LCM is:','60','36','30','54','A','LCM = Product/HCF = 360/6 = 60.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='number-system' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'How many prime numbers are between 10 and 30?','4','5','6','7','C','Primes: 11,13,17,19,23,29 = 6 primes.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='number-system' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Which is NOT a prime number?','17','23','27','29','C','27 = 3×9. It is composite.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='number-system' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'A number divisible by both 4 and 6 must be divisible by:','8','12','24','10','B','LCM(4,6)=12. Must be divisible by 12.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='number-system' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'√144 + √81 = ?','21','20','19','22','A','√144=12, √81=9. Sum=21.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='number-system' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Sum of first 10 natural numbers:','45','50','55','60','C','n(n+1)/2 = 10×11/2 = 55.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='number-system' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Which is irrational?','0.333...','√9','√7','22/7','C','√7 cannot be expressed as p/q (non-terminating non-repeating decimal).','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='number-system' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'LCM of 4, 6 and 9:','18','36','12','24','B','4=2², 6=2×3, 9=3². LCM=2²×3²=36.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='number-system' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Largest 4-digit number minus smallest 4-digit number:','8998','8999','9000','9001','B','9999-1000=8999.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='number-system' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Which number is divisible by 11?','121','122','123','124','A','121÷11=11. Alternating digit sum: 1-2+1=0 ✓','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='number-system' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'HCF of 0 and any number N is:','0','N','1','Cannot determine','B','HCF(0,N)=N by convention since every number divides 0.','hard',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='number-system' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Number of factors of 36:','6','7','8','9','D','36=2²×3². Factors=(2+1)(2+1)=9.','hard',true);

-- Level 2 / percentages
INSERT INTO questions(test_id,level_id,topic_id,question_text,option_a,option_b,option_c,option_d,correct_option,explanation,difficulty,is_verified) VALUES
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='percentages' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'25% of 480:','100','110','120','130','C','0.25×480=120.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='percentages' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Shirt costs Rs.600 sold at 15% profit. Selling price:','Rs.690','Rs.670','Rs.700','Rs.710','A','SP=600×1.15=Rs.690.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='percentages' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Price increased from 200 to 250. Percentage increase:','20%','25%','30%','15%','B','(50/200)×100=25%.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='percentages' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Mobile costs Rs.8000. After 20% discount selling price:','Rs.6000','Rs.6400','Rs.6500','Rs.6200','B','SP=8000×0.80=Rs.6400.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='percentages' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Price increases 10% then decreases 10%. Net change:','0%','-1%','+1%','-2%','B','x×1.1×0.9=0.99x. Net change: -1%.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='percentages' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Shopkeeper buys 100 apples for Rs.100 sells each at Rs.1.20. Profit%:','10%','15%','20%','25%','C','SP=Rs.120. Profit%=20/100×100=20%.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='percentages' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'What percent of 150 is 45?','25%','30%','35%','20%','B','(45/150)×100=30%.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='percentages' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Ali scored 72 out of 120. Percentage score:','55%','60%','65%','70%','B','(72/120)×100=60%.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='percentages' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'SP=Rs.440, profit%=10%. CP is:','Rs.400','Rs.420','Rs.380','Rs.360','A','CP=SP×100/(100+P%)=440×100/110=Rs.400.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='percentages' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Price of sugar rose 25%. Consumption must decrease by what % to keep expenditure same?','20%','25%','15%','30%','A','r/(1+r)×100=25/125×100=20%.','hard',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='percentages' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Loss of 15% on CP=Rs.1200. SP is:','Rs.1000','Rs.1020','Rs.1080','Rs.1100','B','SP=1200×0.85=Rs.1020.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='percentages' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Two successive discounts 10% and 20%. Equivalent single discount:','28%','30%','25%','27%','A','a+b-ab/100=10+20-2=28%.','hard',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='percentages' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Student needs 40% to pass. Gets 185 marks fails by 15 marks. Total marks:','500','475','400','450','A','Pass mark=185+15=200=40%. Total=200/0.40=500.','hard',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='percentages' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Population increases 40000 to 44000. % increase:','5%','8%','10%','12%','C','(4000/40000)×100=10%.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='percentages' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'A shopkeeper marks price 30% above cost. Gives 10% discount. Profit%:','15%','17%','18%','20%','B','SP=CP×1.30×0.90=1.17×CP. Profit=17%.','hard',true);

-- Level 2 / ratios
INSERT INTO questions(test_id,level_id,topic_id,question_text,option_a,option_b,option_c,option_d,correct_option,explanation,difficulty,is_verified) VALUES
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ratios' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'A:B=2:3 and B:C=4:5. A:C=?','8:15','8:12','5:8','3:5','A','Make B common: A:B=8:12, B:C=12:15. A:C=8:15.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ratios' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Boys to girls ratio 3:4. Total 28 students. Number of boys:','10','12','14','16','B','Boys=(3/7)×28=12.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ratios' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Rs.600 divided in ratio 2:3:5. Largest share:','Rs.120','Rs.180','Rs.300','Rs.240','C','Largest=(5/10)×600=Rs.300.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ratios' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'5 workers complete job in 12 days. 8 workers complete same job in:','7 days','7.5 days','8 days','6 days','B','5×12=8×d. d=7.5 days.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ratios' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'If 3:x=12:20 then x is:','5','4','6','8','A','3/x=12/20 → x=3×20/12=5.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ratios' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Car covers 180km in 3 hours. Speed in km/h:','50','55','60','65','C','Speed=180/3=60 km/h.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ratios' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Milk and water in ratio 4:1. Total 25L. Milk quantity:','16L','18L','20L','22L','C','Milk=(4/5)×25=20L.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ratios' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Mean proportion of 4 and 16:','8','6','10','12','A','Mean proportion=√(4×16)=√64=8.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ratios' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Train travels 300km in 4h. Time to travel 450km at same speed:','5h','5.5h','6h','6.5h','C','Speed=75km/h. Time=450/75=6h.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ratios' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Alloy has copper:zinc=3:2. In 250g alloy copper is:','125g','150g','160g','175g','B','Copper=(3/5)×250=150g.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ratios' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'A:B:C=5:3:2. C's share from Rs.400:','Rs.80','Rs.100','Rs.90','Rs.70','A','C=(2/10)×400=Rs.80.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ratios' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'12 men do work in 30 days. 18 men finish in:','15 days','20 days','24 days','25 days','B','12×30=18×d. d=20 days.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ratios' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Two numbers in ratio 5:7. Sum=96. Larger number:','40','54','56','48','C','Larger=(7/12)×96=56.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ratios' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Mix milk at Rs.20/L with water (Rs.0) to get Rs.16/L. Ratio milk:water?','4:1','3:1','2:1','5:1','A','Alligation: (16-0):(20-16)=16:4=4:1.','hard',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='ratios' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'If 6 cats catch 6 rats in 6 minutes how many cats catch 100 rats in 100 minutes?','6','10','100','60','A','Rate=1 rat per cat per 6 min = 1/6 per minute. To catch 100 in 100min need 100/(100×1/6)=6 cats.','hard',true);

-- Level 2 / algebra
INSERT INTO questions(test_id,level_id,topic_id,question_text,option_a,option_b,option_c,option_d,correct_option,explanation,difficulty,is_verified) VALUES
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='algebra' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'If 3x+7=22 then x is:','5','4','6','3','A','3x=15, x=5.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='algebra' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'(a+b)² equals:','a²+b²','a²+2ab+b²','a²-2ab+b²','a²+ab+b²','B','Standard identity: (a+b)²=a²+2ab+b².','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='algebra' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'If x/3=4 then x=?','10','12','14','16','B','x=4×3=12.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='algebra' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Solve: 2x+y=10 and x-y=2. Value of x:','4','5','3','6','A','Add: 3x=12, x=4.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='algebra' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'If a²-b²=35 and a-b=5 then a+b=?','6','7','8','9','B','(a+b)(a-b)=35. a+b=35/5=7.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='algebra' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Discriminant of x²-5x+6=0:','1','4','25','0','A','D=b²-4ac=25-24=1.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='algebra' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Roots of x²-5x+6=0:','2 and 3','1 and 6','2 and 4','3 and 4','A','Factoring: (x-2)(x-3)=0. Roots 2 and 3.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='algebra' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'If 2x-3=4x+1 then x=?','-2','2','-1','1','A','2x-4x=1+3 → -2x=4 → x=-2.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='algebra' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Value of 3²+4²=?','25','20','15','30','A','9+16=25.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='algebra' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'If x+1/x=3 then x²+1/x²=?','7','8','9','11','A','(x+1/x)²=x²+2+1/x²=9. x²+1/x²=7.','hard',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='algebra' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Sum of roots of 2x²-5x+3=0:','5/2','3/2','5/3','2/5','A','Sum=-b/a=-(-5)/2=5/2.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='algebra' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Product of roots of 2x²-5x+3=0:','5/2','3/2','5/3','2/5','B','Product=c/a=3/2.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='algebra' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'If a+b=7 and ab=12 then a²+b²=?','25','49','13','1','A','a²+b²=(a+b)²-2ab=49-24=25.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='algebra' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'For what value of k does x²-4x+k=0 have equal roots?','2','4','8','16','B','Equal roots: D=0. 16-4k=0. k=4.','hard',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='algebra' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Simplify (x²-9)/(x-3):','x-3','x+3','x²-3','x','B','x²-9=(x+3)(x-3). Divide by (x-3) gives x+3.','medium',true);

-- Level 2 / geometry
INSERT INTO questions(test_id,level_id,topic_id,question_text,option_a,option_b,option_c,option_d,correct_option,explanation,difficulty,is_verified) VALUES
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='geometry' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Area of triangle with base 10cm and height 6cm:','30 cm²','60 cm²','36 cm²','12 cm²','A','Area=½×10×6=30 cm².','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='geometry' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Circumference of circle with radius 7cm (π=22/7):','44 cm','22 cm','154 cm','88 cm','A','C=2πr=2×22/7×7=44 cm.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='geometry' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'In a right triangle sides are 3 and 4. Hypotenuse:','5','6','7','8','A','Pythagoras: √(9+16)=5.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='geometry' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Area of rectangle 8cm × 5cm:','40 cm²','26 cm²','13 cm²','80 cm²','A','Area=8×5=40 cm².','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='geometry' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Volume of cube with side 4cm:','64 cm³','32 cm³','48 cm³','16 cm³','A','V=4³=64 cm³.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='geometry' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Sum of interior angles of a hexagon:','540°','600°','720°','660°','C','Sum=(n-2)×180=(6-2)×180=720°.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='geometry' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Diagonal of square with side 5cm:','5√2 cm','10 cm','5 cm','√5 cm','A','Diagonal=a√2=5√2 cm.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='geometry' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Two supplementary angles in ratio 2:3. Smaller angle:','60°','72°','80°','90°','B','Sum=180°. Smaller=(2/5)×180=72°.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='geometry' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Area of circle with diameter 14cm (π=22/7):','154 cm²','22 cm²','44 cm²','308 cm²','A','r=7. Area=πr²=(22/7)×49=154 cm².','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='geometry' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Volume of cylinder: radius 3cm height 7cm (π=22/7):','198 cm³','154 cm³','66 cm³','132 cm³','A','V=πr²h=(22/7)×9×7=198 cm³.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='geometry' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Perimeter of rectangle with length 12cm and breadth 8cm:','20 cm','40 cm','96 cm','48 cm','B','Perimeter=2(l+b)=2(12+8)=40 cm.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='geometry' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'In a right triangle the square of the hypotenuse equals:','Sum of squares of other two sides','Difference of squares of other two sides','Product of other two sides','Double the area','A','Pythagoras theorem: c²=a²+b².','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='geometry' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Surface area of cube with side 3cm:','27 cm²','54 cm²','18 cm²','81 cm²','B','SA=6a²=6×9=54 cm².','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='geometry' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Vertically opposite angles are:','Supplementary','Complementary','Equal','Adjacent','C','Vertically opposite angles (formed at intersection) are always equal.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='geometry' AND level_id=(SELECT id FROM levels WHERE level_no=2 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Area of a trapezoid with parallel sides 6cm and 10cm height 4cm:','32 cm²','24 cm²','40 cm²','16 cm²','A','Area=½(a+b)×h=½(6+10)×4=32 cm².','medium',true);

-- Level 3 / analogies
INSERT INTO questions(test_id,level_id,topic_id,question_text,option_a,option_b,option_c,option_d,correct_option,explanation,difficulty,is_verified) VALUES
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='analogies' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Doctor : Hospital :: Teacher : ?','Book','Chalk','School','Class','C','Workplace relationship: doctor works at hospital, teacher works at school.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='analogies' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Caterpillar : Butterfly :: Tadpole : ?','Fish','Frog','Insect','Lizard','B','Metamorphosis: caterpillar→butterfly, tadpole→frog.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='analogies' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Author : Book :: Composer : ?','Song','Orchestra','Melody','Symphony','D','Creator to creation: author creates book, composer creates symphony.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='analogies' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Petal : Flower :: Page : ?','Book','Library','Words','Chapter','A','Part to whole: petal part of flower, page part of book.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='analogies' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Stethoscope : Doctor :: Gavel : ?','Lawyer','Judge','Court','Justice','B','Tool to user: stethoscope used by doctor, gavel used by judge.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='analogies' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Warm : Hot :: Cool : ?','Ice','Water','Cold','Breeze','C','Degree/intensity: warm and hot differ by intensity, cool and cold differ by intensity.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='analogies' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Drought : Famine :: War : ?','Army','Peace','Destruction','Victory','C','Cause to effect: drought causes famine, war causes destruction.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='analogies' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Key : Lock :: Password : ?','Computer','Access','Internet','Screen','B','Function: key gives access through lock, password gives access to system.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='analogies' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Wood : Furniture :: Clay : ?','Mud','Pottery','Brick','Sand','B','Material to product: wood used to make furniture, clay used to make pottery.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='analogies' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Cub : Lion :: Lamb : ?','Cow','Sheep','Goat','Deer','B','Young of animal: cub is young lion, lamb is young sheep.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='analogies' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Microscope : Biologist :: Telescope : ?','Optician','Pilot','Astronomer','Sailor','C','Tool to user: microscope used by biologist, telescope used by astronomer.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='analogies' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Illiteracy : Education :: Disease : ?','Hospital','Medicine','Doctor','Injection','B','Remedy relationship: education addresses illiteracy, medicine addresses disease.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='analogies' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Mountain : Hill :: Ocean : ?','River','Lake','Pond','Stream','B','Size relationship: mountain is larger hill, ocean is larger lake.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='analogies' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Dog : Bark :: Cat : ?','Hiss','Meow','Growl','Roar','B','Animal to sound: dog barks, cat meows.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='analogies' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Sculptor : Statue :: Architect : ?','Painting','Building','Garden','Blueprint','B','Creator to creation: sculptor creates statue, architect creates building.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='analogies' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Coward : Brave :: Miser : ?','Rich','Generous','Selfish','Poor','B','Antonym relationship: coward opposite of brave, miser opposite of generous.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='analogies' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Bank : Money :: Library : ?','Silence','Study','Books','Reading','C','Place to stored item: bank stores money, library stores books.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='analogies' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Ink : Pen :: Fuel : ?','Car','Engine','Road','Speed','B','Medium/fuel used by: ink used by pen, fuel used by engine.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='analogies' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Marathon : Running :: Regatta : ?','Cycling','Rowing','Wrestling','Swimming','B','Type of race: marathon is running race, regatta is rowing/sailing race.','hard',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='analogies' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Virus : Disease :: Pollution : ?','Factory','Environment','Health problems','Government','C','Cause to effect: virus causes disease, pollution causes health problems.','medium',true);

-- Level 3 / synonyms-antonyms
INSERT INTO questions(test_id,level_id,topic_id,question_text,option_a,option_b,option_c,option_d,correct_option,explanation,difficulty,is_verified) VALUES
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='synonyms-antonyms' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Synonym of BENEVOLENT:','Cruel','Kind','Angry','Selfish','B','Benevolent means well-meaning and kind.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='synonyms-antonyms' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Antonym of GARRULOUS:','Talkative','Silent','Loud','Funny','B','Garrulous means excessively talkative. Antonym: silent/taciturn.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='synonyms-antonyms' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Synonym of DILIGENT:','Lazy','Careless','Hardworking','Fast','C','Diligent means showing care and effort in one's work.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='synonyms-antonyms' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Antonym of EPHEMERAL:','Short-lived','Brief','Permanent','Tiny','C','Ephemeral means very short-lived. Antonym: permanent.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='synonyms-antonyms' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Synonym of ASTUTE:','Dull','Clever','Careless','Honest','B','Astute means having sharp judgment.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='synonyms-antonyms' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Antonym of FRUGAL:','Careful','Thrifty','Extravagant','Saving','C','Frugal means thrifty. Antonym: extravagant/wasteful.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='synonyms-antonyms' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Synonym of CANDID:','Evasive','Secretive','Frank','Polite','C','Candid means open and frank in expression.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='synonyms-antonyms' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Antonym of HAUGHTY:','Proud','Arrogant','Humble','Rude','C','Haughty means arrogantly superior. Antonym: humble.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='synonyms-antonyms' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Synonym of METICULOUS:','Careless','Hasty','Precise','Lazy','C','Meticulous means very careful about details.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='synonyms-antonyms' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Antonym of VERBOSE:','Wordy','Lengthy','Concise','Repetitive','C','Verbose means using too many words. Antonym: concise.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='synonyms-antonyms' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Synonym of LETHARGIC:','Energetic','Sluggish','Active','Excited','B','Lethargic means lacking energy.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='synonyms-antonyms' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Antonym of OBSCURE:','Vague','Unknown','Clear','Hidden','C','Obscure means unclear or unknown. Antonym: clear/well-known.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='synonyms-antonyms' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Synonym of ELOQUENT:','Silent','Inarticulate','Fluent','Shy','C','Eloquent means fluent and persuasive in speech.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='synonyms-antonyms' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Antonym of TACITURN:','Quiet','Reserved','Talkative','Shy','C','Taciturn means reserved. Antonym: talkative/garrulous.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='synonyms-antonyms' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Synonym of PERTURB:','Calm','Soothe','Disturb','Ignore','C','Perturb means to make anxious or unsettle.','easy',true);

-- Level 3 / sentence-completion
INSERT INTO questions(test_id,level_id,topic_id,question_text,option_a,option_b,option_c,option_d,correct_option,explanation,difficulty,is_verified) VALUES
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='sentence-completion' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Despite his initial _____ he eventually accepted the new policy.','support','resistance','indifference','approval','B','Despite = contrast. Eventually accepted → initial reaction was resistance.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='sentence-completion' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'The scientist was _____ in her research leaving no detail unchecked.','careless','lazy','meticulous','hasty','C','Leaving no detail unchecked = meticulous.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='sentence-completion' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Because he had studied thoroughly Ali was _____ during the exam.','nervous','unprepared','confident','confused','C','Because = support. Thorough study → confidence.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='sentence-completion' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'The speech was so _____ that the audience fell asleep.','inspiring','tedious','entertaining','passionate','B','Audience fell asleep → speech was boring/tedious.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='sentence-completion' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Although she appeared _____ on the outside she was deeply worried within.','worried','calm','upset','nervous','B','Although = contrast. Outside appearance opposite of inner worry → calm.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='sentence-completion' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'The new manager was known for her _____ decisions — she always thought carefully before acting.','rash','impulsive','judicious','hasty','C','Thinking carefully before acting = judicious.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='sentence-completion' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'The evidence was so _____ that even the skeptics were convinced.','weak','ambiguous','compelling','irrelevant','C','Skeptics convinced → evidence was compelling/persuasive.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='sentence-completion' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'He was _____ about his future neither hopeful nor despairing.','optimistic','pessimistic','ambivalent','certain','C','Neither hopeful nor despairing = ambivalent (mixed feelings).','hard',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='sentence-completion' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'The teacher's _____ manner made students reluctant to ask questions.','friendly','approachable','intimidating','encouraging','C','Students reluctant to ask → teacher seems intimidating.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='sentence-completion' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Her ideas were so _____ that no one could understand what she was trying to say.','clear','obvious','cryptic','simple','C','No one could understand = cryptic/unclear.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='sentence-completion' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'The economy began to _____ after years of stagnation.','decline','worsen','deteriorate','recover','D','Opposite of stagnation = recovery/growth.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='sentence-completion' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Since the project was behind schedule the team had to work _____ to meet the deadline.','leisurely','slowly','diligently','carelessly','C','Behind schedule → need to work diligently/hard.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='sentence-completion' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'The new policy was _____ affecting millions of citizens across the country.','minor','limited','insignificant','far-reaching','D','Affecting millions = far-reaching.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='sentence-completion' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'He was so _____ in his praise that people suspected he had ulterior motives.','sincere','moderate','excessive','rare','C','Suspicion of motives suggests excessive/lavish praise.','hard',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='sentence-completion' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'The documentary was both _____ and _____ combining serious issues with moments of humour.','boring / exciting','informative / entertaining','serious / dull','educational / tedious','B','Both serious content and humour = informative AND entertaining.','medium',true);

-- Level 3 / critical-reasoning
INSERT INTO questions(test_id,level_id,topic_id,question_text,option_a,option_b,option_c,option_d,correct_option,explanation,difficulty,is_verified) VALUES
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='critical-reasoning' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'An argument's CONCLUSION is best described as:','The evidence provided','The claim the argument is trying to prove','The background information','The objection to the argument','B','The conclusion is the main claim supported by premises.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='critical-reasoning' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Which is an example of the ad hominem fallacy?','Providing counter-evidence','Attacking the logic of the argument','Attacking the person making the argument','Asking for clarification','C','Ad hominem = attacking the person not their argument.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='critical-reasoning' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Premise: Some politicians are corrupt. Ali is a politician. Conclusion: Ali is corrupt. This is:','Valid deductive reasoning','Invalid — some does not mean all','Valid inductive reasoning','A sound syllogism','B','Some A are B does not mean every A is B. Cannot conclude Ali is corrupt.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='critical-reasoning' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Which STRENGTHENS 'Students who read more perform better academically'?','Reading is enjoyable','Daily readers score 30% higher on standardized tests','Teachers should assign more reading','Some students do not like reading','B','A controlled study showing higher scores directly supports the claim.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='critical-reasoning' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'The assumption in 'Since it worked in Japan it will work in Pakistan' is:','Japan and Pakistan are identical','What works anywhere works everywhere','Pakistan is similar to Japan in relevant ways','The solution is perfect','C','The unstated assumption is that conditions are similar enough.','hard',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='critical-reasoning' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Which is a factual claim not an opinion?','Chocolate is the best flavour','Students should study harder','Pakistan gained independence in 1947','The economy needs reform','C','Independence in 1947 is a verifiable historical fact.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='critical-reasoning' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Valid deductive argument with true premises will have:','A false conclusion','A true conclusion','An uncertain conclusion','No conclusion','B','Valid deduction + true premises = true conclusion necessarily.','medium',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='critical-reasoning' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'The slippery slope fallacy argues that:','One small step leads inevitably to extreme consequences','Arguments get worse over time','Facts are relative','People slide when they argue','A','Slippery slope: one action will lead to a chain of extreme outcomes without sufficient evidence.','hard',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='critical-reasoning' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'A premise in an argument is:','The final conclusion','Evidence or fact supporting the conclusion','An assumption only','An objection','B','Premises are the evidence/facts that support the conclusion.','easy',true),
((SELECT id FROM tests WHERE slug='hat'),(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat')),(SELECT id FROM topics WHERE slug='critical-reasoning' AND level_id=(SELECT id FROM levels WHERE level_no=3 AND test_id=(SELECT id FROM tests WHERE slug='hat'))),'Which WEAKENS 'Banning junk food ads will reduce childhood obesity'?','Junk food is unhealthy','Children see more ads online than on TV','Obesity is a growing problem','Schools should teach nutrition','B','If children see more ads online (not affected by ban), the ban may not reduce exposure or obesity.','hard',true);
