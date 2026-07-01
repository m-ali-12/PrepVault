'use client';
import { useState, useEffect } from 'react';
import Link from 'next/link';

type Q = {
  id: string;
  question_text: string;
  option_a: string;
  option_b: string;
  option_c: string;
  option_d: string;
  correct_option: string;
  explanation: string;
};

type Phase = 'test' | 'result';

export default function TestClient({ questions: initial, levelId }: { questions: Q[]; levelId: string }) {
  const [questions, setQuestions] = useState<Q[]>(initial);
  const [idx, setIdx] = useState(0);
  const [answers, setAnswers] = useState<Record<string, string>>({});
  const [phase, setPhase] = useState<Phase>('test');
  const [tabWarnings, setTabWarnings] = useState(0);
  const [seenIds, setSeenIds] = useState<string[]>([]);
  const [retesting, setRetesting] = useState(false);
  const [loadingRetest, setLoadingRetest] = useState(false);

  useEffect(() => {
    const handler = () => { if (document.hidden) setTabWarnings(x => Math.min(x + 1, 3)); };
    document.addEventListener('visibilitychange', handler);
    return () => document.removeEventListener('visibilitychange', handler);
  }, []);

  const q = questions[idx];

  // ---- RESULTS CALCULATION ----
  const results = questions.map(q => ({
    ...q,
    chosen: answers[q.id] || null,
    correct: answers[q.id] === q.correct_option,
  }));
  const correctCount = results.filter(r => r.correct).length;
  const pct = Math.round((correctCount / questions.length) * 100);
  const passed = pct >= 85;

  function submit() {
    setSeenIds(prev => Array.from(new Set(prev.concat(questions.map(q => q.id)))));
    setPhase('result');
  }

  async function startRetest() {
    setLoadingRetest(true);
    const allSeen = Array.from(new Set(seenIds.concat(questions.map(q => q.id))));
    try {
      const res = await fetch('/api/questions-for-retest', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ levelId, excludeIds: allSeen }),
      });
      const data = await res.json();
      setQuestions(data.questions);
      setAnswers({});
      setIdx(0);
      setPhase('test');
      setRetesting(true);
      setSeenIds(allSeen);
    } catch {
      // fallback: allow repeat if no fresh questions
      setAnswers({});
      setIdx(0);
      setPhase('test');
    }
    setLoadingRetest(false);
  }

  // ---- TEST PHASE ----
  if (phase === 'test') {
    const progress = Math.round(((idx + 1) / questions.length) * 100);
    return (
      <div className="max-w-2xl mx-auto">
        {tabWarnings > 0 && (
          <div className="mb-4 rounded-xl bg-red-500/20 border border-red-400/40 text-red-300 p-3 text-sm font-bold">
            ⚠️ Tab switch detected ({tabWarnings}/3) — Anti-cheat active
          </div>
        )}
        {retesting && (
          <div className="mb-4 rounded-xl bg-cyan-400/10 border border-cyan-400/30 text-cyan-200 p-3 text-sm">
            🔄 Fresh questions loaded — previously seen questions excluded
          </div>
        )}
        <div className="glass rounded-3xl p-6">
          {/* Progress bar */}
          <div className="flex justify-between text-sm text-slate-400 mb-2">
            <span>Question {idx + 1} of {questions.length}</span>
            <span>{Object.keys(answers).length} answered</span>
          </div>
          <div className="h-2 rounded-full bg-slate-800 mb-6">
            <div className="h-2 rounded-full bg-cyan-400 transition-all" style={{ width: `${progress}%` }} />
          </div>

          <p className="text-xl font-bold leading-relaxed">{q.question_text}</p>

          <div className="grid gap-3 mt-6">
            {(['A', 'B', 'C', 'D'] as const).map(opt => (
              <button
                key={opt}
                onClick={() => setAnswers({ ...answers, [q.id]: opt })}
                className={`text-left rounded-2xl p-4 border transition-all ${
                  answers[q.id] === opt
                    ? 'border-cyan-400 bg-cyan-400/15 text-white'
                    : 'border-white/10 bg-white/5 hover:bg-white/10'
                }`}
              >
                <span className={`inline-block w-8 h-8 rounded-lg text-center leading-8 mr-3 font-bold text-sm ${answers[q.id] === opt ? 'bg-cyan-400 text-slate-950' : 'bg-white/10'}`}>{opt}</span>
                {q[`option_${opt.toLowerCase()}` as keyof Q]}
              </button>
            ))}
          </div>

          <div className="mt-6 flex justify-between">
            <button disabled={idx === 0} onClick={() => setIdx(idx - 1)} className="px-5 py-3 rounded-xl bg-white/10 disabled:opacity-30">← Back</button>
            {idx === questions.length - 1 ? (
              <button onClick={submit} className="px-6 py-3 rounded-xl neon font-bold">Submit Test →</button>
            ) : (
              <button onClick={() => setIdx(idx + 1)} className="px-6 py-3 rounded-xl neon font-bold">Next →</button>
            )}
          </div>
        </div>

        {/* Question dots navigation */}
        <div className="mt-4 flex flex-wrap gap-2">
          {questions.map((_, i) => (
            <button
              key={i}
              onClick={() => setIdx(i)}
              className={`w-9 h-9 rounded-lg text-sm font-bold border ${
                i === idx ? 'border-cyan-400 bg-cyan-400/20' :
                answers[questions[i].id] ? 'border-green-400/50 bg-green-400/10' :
                'border-white/10 bg-white/5'
              }`}
            >{i + 1}</button>
          ))}
        </div>
      </div>
    );
  }

  // ---- RESULT PHASE ----
  return (
    <div className="max-w-2xl mx-auto space-y-6">
      {/* Score card */}
      <div className={`glass rounded-3xl p-8 text-center border ${passed ? 'border-green-400/40' : 'border-red-400/40'}`}>
        <div className={`text-7xl font-black ${passed ? 'text-green-400' : 'text-red-400'}`}>{pct}%</div>
        <div className="text-2xl font-bold mt-2">{passed ? '🎉 Level Passed!' : '❌ Not Passed Yet'}</div>
        <div className="text-slate-400 mt-1">{correctCount} correct out of {questions.length} questions</div>
        <div className="mt-2 text-sm text-slate-400">Passing score: 85%</div>

        <div className="mt-6 flex gap-3 justify-center flex-wrap">
          {passed ? (
            <Link href="/dashboard" className="px-6 py-3 rounded-xl neon font-bold">Go to Dashboard →</Link>
          ) : (
            <button
              onClick={startRetest}
              disabled={loadingRetest}
              className="px-6 py-3 rounded-xl neon font-bold disabled:opacity-50"
            >
              {loadingRetest ? 'Loading fresh questions...' : '🔄 Retest with New Questions'}
            </button>
          )}
          <Link href={`/study/${levelId}`} className="px-6 py-3 rounded-xl bg-white/10">📚 Review Study Material</Link>
        </div>
      </div>

      {/* Per-question review */}
      <h2 className="text-2xl font-bold">Question Review</h2>
      {results.map((r, i) => (
        <div key={r.id} className={`glass rounded-2xl p-5 border-l-4 ${r.correct ? 'border-l-green-400' : 'border-l-red-400'}`}>
          <div className="flex items-start gap-3">
            <span className={`text-xl ${r.correct ? '✅' : '❌'}`}>{r.correct ? '✅' : '❌'}</span>
            <div className="flex-1">
              <p className="font-semibold">Q{i + 1}. {r.question_text}</p>

              <div className="mt-3 grid gap-2">
                {(['A', 'B', 'C', 'D'] as const).map(opt => {
                  const isCorrect = opt === r.correct_option;
                  const isChosen = opt === r.chosen;
                  return (
                    <div
                      key={opt}
                      className={`px-4 py-2 rounded-xl text-sm border ${
                        isCorrect ? 'border-green-400/60 bg-green-400/10 text-green-300' :
                        isChosen && !isCorrect ? 'border-red-400/60 bg-red-400/10 text-red-300' :
                        'border-white/5 text-slate-400'
                      }`}
                    >
                      <span className="font-bold mr-2">{opt}.</span>
                      {r[`option_${opt.toLowerCase()}` as keyof typeof r]}
                      {isCorrect && <span className="ml-2 text-xs font-bold">← Correct</span>}
                      {isChosen && !isCorrect && <span className="ml-2 text-xs">← Your answer</span>}
                    </div>
                  );
                })}
              </div>

              {!r.correct && r.explanation && (
                <div className="mt-3 rounded-xl bg-amber-400/10 border border-amber-400/30 p-3 text-amber-200 text-sm">
                  <span className="font-bold">💡 Explanation: </span>{r.explanation}
                </div>
              )}
              {!r.chosen && (
                <p className="mt-2 text-sm text-slate-500 italic">Not answered</p>
              )}
            </div>
          </div>
        </div>
      ))}

      <div className="pb-8 flex gap-3 flex-wrap">
        {!passed && (
          <button onClick={startRetest} disabled={loadingRetest} className="px-6 py-3 rounded-xl neon font-bold disabled:opacity-50">
            {loadingRetest ? 'Loading...' : '🔄 Retest with New Questions'}
          </button>
        )}
        <Link href="/dashboard" className="px-6 py-3 rounded-xl bg-white/10">← Dashboard</Link>
      </div>
    </div>
  );
}

declare global { interface Window { __pvWatch?: boolean } }
