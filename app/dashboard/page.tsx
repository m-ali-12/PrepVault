import StudentShell from '@/components/StudentShell';
import { fallbackLevels } from '@/lib/data';
import { query } from '@/lib/db';
import { currentUser } from '@/lib/auth';
import Link from 'next/link';
import { redirect } from 'next/navigation';

export const dynamic = 'force-dynamic';

const examMeta: Record<string, { name: string; full: string; icon: string; color: string }> = {
  hat:    { name: 'HAT',     full: 'HEC Achievement Test',                    icon: '🎓', color: 'text-cyan-300' },
  lat:    { name: 'LAT',     full: 'Law Admission Test',                       icon: '⚖️', color: 'text-purple-300' },
  ecat:   { name: 'ECAT',    full: 'Engineering College Admission Test',       icon: '⚙️', color: 'text-green-300' },
  mdcat:  { name: 'MDCAT',   full: 'Medical & Dental College Admission Test',  icon: '🏥', color: 'text-red-300' },
  lawgat: { name: 'Law GAT', full: 'Graduate Assessment Test (Law)',           icon: '📜', color: 'text-amber-300' },
};

export default async function Dashboard({ searchParams }: { searchParams: { exam?: string } }) {
  const user = await currentUser();
  if (!user) redirect('/login');

  const exam = (searchParams.exam || 'hat').toLowerCase();
  const meta = examMeta[exam] || { name: exam.toUpperCase(), full: '', icon: '📝', color: 'text-white' };

  let levels: any[] = await query(
    'SELECT level_id as id, level_no, title, description, verified_questions FROM dashboard_level_view WHERE test_slug=$1 ORDER BY level_no',
    [exam]
  ).catch(() => []);
  if (!levels.length && exam === 'hat') levels = fallbackLevels;

  // fetch user completions
  const completions: any[] = await query(
    'SELECT level_id, score, passed FROM level_completions WHERE user_id=$1',
    [user.id]
  ).catch(() => []);
  const completionMap: Record<string, any> = {};
  for (const c of completions) completionMap[c.level_id] = c;

  const totalQ = levels.reduce((s: number, l: any) => s + (parseInt(l.verified_questions) || 0), 0);
  const passedCount = completions.filter(c => c.passed).length;

  return (
    <StudentShell>
      <div className="max-w-6xl mx-auto">
        {/* Header */}
        <div className="flex items-center justify-between mb-6">
          <div className="flex items-center gap-3">
            <span className="text-4xl">{meta.icon}</span>
            <div>
              <h1 className={`text-3xl font-black ${meta.color}`}>{meta.name}</h1>
              <p className="text-slate-400 text-sm">{meta.full}</p>
            </div>
          </div>
          <Link href="/exams" className="text-sm text-cyan-300 font-bold glass px-4 py-2 rounded-xl">Switch Exam ↗</Link>
        </div>

        <div className="grid lg:grid-cols-[1fr_320px] gap-6">
          <section>
            {/* Stats */}
            <div className="grid grid-cols-4 gap-3 mb-6">
              <div className="glass rounded-2xl p-4">
                <div className="text-slate-400 text-xs">Target</div>
                <div className="text-2xl font-black text-green-400">85%</div>
              </div>
              <div className="glass rounded-2xl p-4">
                <div className="text-slate-400 text-xs">Levels</div>
                <div className="text-2xl font-black">{levels.length}</div>
              </div>
              <div className="glass rounded-2xl p-4">
                <div className="text-slate-400 text-xs">Questions</div>
                <div className="text-2xl font-black">{totalQ}</div>
              </div>
              <div className="glass rounded-2xl p-4">
                <div className="text-slate-400 text-xs">Passed</div>
                <div className="text-2xl font-black text-cyan-400">{passedCount}/{levels.length}</div>
              </div>
            </div>

            {/* Progress bar */}
            {levels.length > 0 && (
              <div className="glass rounded-2xl p-4 mb-6">
                <div className="flex justify-between text-sm mb-2">
                  <span className="text-slate-400">Overall progress</span>
                  <span className="font-bold">{Math.round((passedCount / levels.length) * 100)}%</span>
                </div>
                <div className="h-3 rounded-full bg-slate-800">
                  <div className="h-3 rounded-full bg-cyan-400 transition-all" style={{ width: `${Math.round((passedCount / levels.length) * 100)}%` }} />
                </div>
              </div>
            )}

            {/* Levels */}
            <h2 className="text-xl font-bold mb-3">Study Levels</h2>
            {levels.length === 0 ? (
              <div className="glass rounded-3xl p-8 text-center">
                <div className="text-4xl mb-3">{meta.icon}</div>
                <h3 className="text-xl font-bold">{meta.name} content coming soon</h3>
                <p className="text-slate-400 mt-2">Admin is adding verified questions. Try HAT which has full content.</p>
                <Link href="/dashboard?exam=hat" className="inline-block mt-4 px-5 py-3 rounded-xl neon font-bold">Try HAT Prep</Link>
              </div>
            ) : (
              <div className="space-y-3">
                {levels.map((l: any, i: number) => {
                  const comp = completionMap[l.id];
                  const isPassed = comp?.passed;
                  const prevPassed = i === 0 || completionMap[levels[i-1]?.id]?.passed;
                  return (
                    <div key={l.id} className={`glass rounded-2xl p-5 flex items-center justify-between gap-4 border ${isPassed ? 'border-green-400/40' : 'border-transparent'}`}>
                      <div className="flex items-center gap-4">
                        <div className={`w-12 h-12 rounded-xl flex items-center justify-center text-xl font-black shrink-0 ${isPassed ? 'bg-green-400 text-slate-950' : i === 0 || prevPassed ? 'bg-cyan-400 text-slate-950' : 'bg-white/10'}`}>
                          {isPassed ? '✓' : l.level_no}
                        </div>
                        <div>
                          <div className="text-xs text-slate-400 mb-1 flex items-center gap-2">
                            {isPassed ? <span className="text-green-400 font-bold">✅ Passed {comp.score}%</span>
                              : i === 0 || prevPassed ? <span className="text-cyan-400">🟢 Unlocked</span>
                              : <span>🔒 Complete Level {i} first</span>}
                            <span>• {parseInt(l.verified_questions) || 0} questions</span>
                          </div>
                          <h3 className="text-lg font-bold">{l.title}</h3>
                          <p className="text-slate-400 text-sm">{l.description}</p>
                        </div>
                      </div>
                      <div className="flex gap-2 shrink-0">
                        <Link href={`/study/${l.id}`} className="px-4 py-2 rounded-xl bg-white/10 text-sm font-medium hover:bg-white/20">📚 Study</Link>
                        <Link href={`/test/${l.id}`} className="px-4 py-2 rounded-xl bg-cyan-400 text-slate-950 text-sm font-bold hover:bg-cyan-300">⚡ Test</Link>
                        {isPassed && (
                          <Link href={`/level-summary/${l.id}`} className="px-4 py-2 rounded-xl bg-green-400/20 border border-green-400/40 text-green-300 text-sm font-medium">📊 Summary</Link>
                        )}
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </section>

          {/* Sidebar */}
          <aside className="space-y-4">
            <div className="glass rounded-3xl p-6">
              <h3 className="text-lg font-bold">👤 {user.name}</h3>
              <p className="text-slate-400 text-sm mt-1">{user.email}</p>
              <div className="mt-4 pt-4 border-t border-white/10">
                <div className="text-xs text-slate-400">Currently preparing</div>
                <div className={`text-xl font-black mt-1 ${meta.color}`}>{meta.name}</div>
              </div>
            </div>
            <div className="glass rounded-3xl p-6">
              <h3 className="text-lg font-bold">🤖 AI Tutor</h3>
              <p className="text-slate-400 text-sm mt-2">Ask any {meta.name} question. Chat history saved to your account.</p>
              <Link href="/ai-tutor" className="mt-4 inline-block w-full text-center rounded-xl neon px-5 py-3 font-bold">Open AI Tutor</Link>
            </div>
            <div className="glass rounded-3xl p-6">
              <h3 className="text-lg font-bold">📊 Level System</h3>
              <div className="mt-3 space-y-2 text-sm text-slate-300">
                <div className="flex gap-2"><span className="text-green-400">1.</span> Study the material thoroughly</div>
                <div className="flex gap-2"><span className="text-cyan-400">2.</span> Take the level test</div>
                <div className="flex gap-2"><span className="text-yellow-400">3.</span> Score 85%+ to pass</div>
                <div className="flex gap-2"><span className="text-purple-400">4.</span> View your level summary</div>
                <div className="flex gap-2"><span className="text-red-400">5.</span> Below 85%? Retest with new questions</div>
              </div>
            </div>
          </aside>
        </div>
      </div>
    </StudentShell>
  );
}
