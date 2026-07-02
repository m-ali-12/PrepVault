'use client';
import { useState, useEffect } from 'react';
import Link from 'next/link';

type Q = { id:string; question_text:string; option_a:string; option_b:string; option_c:string; option_d:string; correct_option:string; explanation:string; };
type Phase = 'test' | 'result';

export default function TestClient({ questions: initial, levelId }: { questions: Q[]; levelId: string }) {
  const [questions, setQuestions] = useState<Q[]>(initial);
  const [idx, setIdx] = useState(0);
  const [answers, setAnswers] = useState<Record<string,string>>({});
  const [phase, setPhase] = useState<Phase>('test');
  const [tabWarn, setTabWarn] = useState(0);
  const [seenIds, setSeenIds] = useState<string[]>([]);
  const [retesting, setRetesting] = useState(false);
  const [loadingRetest, setLoadingRetest] = useState(false);
  const [savingResult, setSavingResult] = useState(false);

  useEffect(() => {
    const h = () => { if(document.hidden) setTabWarn(x => Math.min(x+1,5)); };
    document.addEventListener('visibilitychange', h);
    return () => document.removeEventListener('visibilitychange', h);
  }, []);

  const q = questions[idx];

  const results = questions.map(q => ({ ...q, chosen: answers[q.id]||null, correct: answers[q.id]===q.correct_option }));
  const correctCount = results.filter(r=>r.correct).length;
  const pct = Math.round((correctCount/questions.length)*100);
  const passed = pct >= 85;

  async function submit() {
    const allSeen = Array.from(new Set(seenIds.concat(questions.map(q=>q.id))));
    setSeenIds(allSeen);
    setPhase('result');
    setSavingResult(true);
    try {
      await fetch('/api/level-complete', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ levelId, score: Math.round((correctCount/questions.length)*100), correct: correctCount, total: questions.length })
      });
    } catch {}
    setSavingResult(false);
  }

  async function startRetest() {
    setLoadingRetest(true);
    const allSeen = Array.from(new Set(seenIds.concat(questions.map(q=>q.id))));
    try {
      const res = await fetch('/api/questions-for-retest', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ levelId, excludeIds: allSeen })
      });
      const data = await res.json();
      setQuestions(data.questions);
      setAnswers({});
      setIdx(0);
      setPhase('test');
      setRetesting(true);
      setSeenIds(allSeen);
    } catch { setAnswers({}); setIdx(0); setPhase('test'); }
    setLoadingRetest(false);
  }

  if (phase === 'test') {
    const progress = Math.round(((idx+1)/questions.length)*100);
    return (
      <div className="max-w-2xl mx-auto">
        {tabWarn > 0 && (
          <div className="mb-4 rounded-xl bg-red-500/20 border border-red-400/40 text-red-300 p-3 text-sm font-bold">
            ⚠️ Tab switch detected ({tabWarn}/5) — Anti-cheat active
          </div>
        )}
        {retesting && (
          <div className="mb-4 rounded-xl bg-cyan-400/10 border border-cyan-400/30 text-cyan-200 p-3 text-sm">
            🔄 Fresh questions loaded — previously seen questions excluded
          </div>
        )}
        <div className="glass rounded-3xl p-6">
          <div className="flex justify-between text-sm text-slate-400 mb-2">
            <span>Question {idx+1} / {questions.length}</span>
            <span>{Object.keys(answers).length} answered</span>
          </div>
          <div className="h-2 rounded-full bg-slate-800 mb-6">
            <div className="h-2 rounded-full bg-cyan-400 transition-all" style={{ width: `${progress}%` }} />
          </div>
          <p className="text-xl font-bold leading-relaxed">{q.question_text}</p>
          <div className="grid gap-3 mt-6">
            {(['A','B','C','D'] as const).map(opt => (
              <button key={opt} onClick={() => setAnswers({...answers,[q.id]:opt})}
                className={`text-left rounded-2xl p-4 border transition-all ${answers[q.id]===opt ? 'border-cyan-400 bg-cyan-400/15 text-white' : 'border-white/10 bg-white/5 hover:bg-white/10'}`}>
                <span className={`inline-block w-8 h-8 rounded-lg text-center leading-8 mr-3 font-bold text-sm ${answers[q.id]===opt ? 'bg-cyan-400 text-slate-950' : 'bg-white/10'}`}>{opt}</span>
                {q[`option_${opt.toLowerCase()}` as keyof Q]}
              </button>
            ))}
          </div>
          <div className="mt-6 flex justify-between">
            <button disabled={idx===0} onClick={()=>setIdx(idx-1)} className="px-5 py-3 rounded-xl bg-white/10 disabled:opacity-30">← Back</button>
            {idx===questions.length-1
              ? <button onClick={submit} className="px-6 py-3 rounded-xl neon font-bold">Submit Test →</button>
              : <button onClick={()=>setIdx(idx+1)} className="px-6 py-3 rounded-xl neon font-bold">Next →</button>
            }
          </div>
        </div>
        <div className="mt-4 flex flex-wrap gap-2">
          {questions.map((_,i) => (
            <button key={i} onClick={()=>setIdx(i)}
              className={`w-9 h-9 rounded-lg text-sm font-bold border ${i===idx ? 'border-cyan-400 bg-cyan-400/20' : answers[questions[i].id] ? 'border-green-400/50 bg-green-400/10' : 'border-white/10 bg-white/5'}`}>
              {i+1}
            </button>
          ))}
        </div>
      </div>
    );
  }

  // RESULT PHASE
  const wrongOnes = results.filter(r => !r.correct);
  return (
    <div className="max-w-2xl mx-auto space-y-6">
      <div className={`glass rounded-3xl p-8 text-center border ${passed ? 'border-green-400/40' : 'border-red-400/40'}`}>
        <div className={`text-7xl font-black ${passed ? 'text-green-400' : 'text-red-400'}`}>{pct}%</div>
        <div className="text-2xl font-bold mt-2">{passed ? '🎉 Level Passed!' : '❌ Not Passed Yet'}</div>
        <div className="text-slate-400 mt-1">{correctCount} correct out of {questions.length} • Need 85% to pass</div>
        {savingResult && <div className="text-xs text-slate-500 mt-2">Saving result...</div>}

        {/* Summary boxes */}
        <div className="grid grid-cols-3 gap-3 mt-5">
          <div className="rounded-2xl bg-green-400/10 border border-green-400/30 p-3">
            <div className="text-2xl font-black text-green-400">{correctCount}</div>
            <div className="text-xs text-slate-400">Correct</div>
          </div>
          <div className="rounded-2xl bg-red-400/10 border border-red-400/30 p-3">
            <div className="text-2xl font-black text-red-400">{questions.length - correctCount}</div>
            <div className="text-xs text-slate-400">Wrong</div>
          </div>
          <div className="rounded-2xl bg-slate-400/10 border border-slate-400/30 p-3">
            <div className="text-2xl font-black">{questions.length - Object.keys(answers).length}</div>
            <div className="text-xs text-slate-400">Skipped</div>
          </div>
        </div>

        <div className="mt-6 flex gap-3 justify-center flex-wrap">
          {passed ? (
            <>
              <Link href={`/level-summary/${levelId}`} className="px-6 py-3 rounded-xl bg-green-400 text-slate-950 font-bold">📊 View Level Summary</Link>
              <Link href="/dashboard" className="px-6 py-3 rounded-xl bg-white/10">← Dashboard</Link>
            </>
          ) : (
            <>
              <button onClick={startRetest} disabled={loadingRetest} className="px-6 py-3 rounded-xl neon font-bold disabled:opacity-50">
                {loadingRetest ? 'Loading fresh questions...' : '🔄 Retest with New Questions'}
              </button>
              <Link href={`/study/${levelId}`} className="px-6 py-3 rounded-xl bg-white/10">📚 Review Study Material</Link>
            </>
          )}
        </div>
      </div>

      {/* Wrong answers review */}
      {wrongOnes.length > 0 && (
        <>
          <h2 className="text-xl font-bold text-red-300">❌ Wrong Answers — Review & Learn</h2>
          {wrongOnes.map((r,i) => (
            <div key={r.id} className="glass rounded-2xl p-5 border-l-4 border-l-red-400">
              <p className="font-semibold text-lg">{r.question_text}</p>
              <div className="mt-3 grid gap-2">
                {(['A','B','C','D'] as const).map(opt => {
                  const isCorrect = opt===r.correct_option;
                  const isChosen = opt===r.chosen;
                  return (
                    <div key={opt} className={`px-4 py-2 rounded-xl text-sm border ${isCorrect ? 'border-green-400/60 bg-green-400/10 text-green-300' : isChosen ? 'border-red-400/60 bg-red-400/10 text-red-300' : 'border-white/5 text-slate-500'}`}>
                      <span className="font-bold mr-2">{opt}.</span>
                      {r[`option_${opt.toLowerCase()}` as keyof typeof r]}
                      {isCorrect && <span className="ml-2 text-xs font-bold">✓ Correct answer</span>}
                      {isChosen && !isCorrect && <span className="ml-2 text-xs">✗ Your answer</span>}
                    </div>
                  );
                })}
              </div>
              {r.explanation && (
                <div className="mt-3 rounded-xl bg-amber-400/10 border border-amber-400/30 p-3 text-amber-200 text-sm">
                  <span className="font-bold">💡 Explanation: </span>{r.explanation}
                </div>
              )}
            </div>
          ))}
        </>
      )}

      {/* Correct answers review */}
      {results.filter(r=>r.correct).length > 0 && (
        <>
          <h2 className="text-xl font-bold text-green-300">✅ Correct Answers</h2>
          {results.filter(r=>r.correct).map((r) => (
            <div key={r.id} className="glass rounded-2xl p-4 border-l-4 border-l-green-400 flex items-start gap-3">
              <span className="text-green-400 text-xl mt-1">✅</span>
              <div>
                <p className="font-medium">{r.question_text}</p>
                <p className="text-green-300 text-sm mt-1">{r.correct_option}. {r[`option_${r.correct_option.toLowerCase()}` as keyof typeof r]}</p>
              </div>
            </div>
          ))}
        </>
      )}

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
