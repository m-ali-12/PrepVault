import StudentShell from '@/components/StudentShell';
import { one, query } from '@/lib/db';
import { currentUser } from '@/lib/auth';
import Link from 'next/link';
import { redirect } from 'next/navigation';

export const dynamic = 'force-dynamic';

export default async function LevelSummary({ params }: { params: { levelId: string } }) {
  const user = await currentUser();
  if (!user) redirect('/login');

  const level = await one(
    `SELECT l.*, t.name as test_name, t.slug as test_slug, t.short_name
     FROM levels l JOIN tests t ON t.id=l.test_id WHERE l.id=$1`,
    [params.levelId]
  ).catch(() => null);

  const completion = await one(
    'SELECT * FROM level_completions WHERE user_id=$1 AND level_id=$2',
    [user.id, params.levelId]
  ).catch(() => null);

  const topics = await query(
    'SELECT * FROM topics WHERE level_id=$1 ORDER BY order_no',
    [params.levelId]
  ).catch(() => []);

  const lessonCount = await one(
    `SELECT COUNT(*) as cnt FROM lessons JOIN topics ON topics.id=lessons.topic_id WHERE topics.level_id=$1`,
    [params.levelId]
  ).catch(() => ({ cnt: 0 }));

  const qCount = await one(
    'SELECT COUNT(*) as cnt FROM questions WHERE level_id=$1 AND is_verified=true',
    [params.levelId]
  ).catch(() => ({ cnt: 0 }));

  return (
    <StudentShell>
      <div className="max-w-3xl mx-auto">
        {/* Breadcrumb */}
        {level && (
          <div className="flex items-center gap-2 text-sm text-slate-400 mb-4">
            <Link href="/exams">Exams</Link>
            <span>/</span>
            <Link href={`/dashboard?exam=${level.test_slug}`}>{level.short_name}</Link>
            <span>/</span>
            <span>Level {level.level_no} Summary</span>
          </div>
        )}

        <h1 className="text-4xl font-black mb-2">Level {level?.level_no} Summary</h1>
        <p className="text-slate-400 mb-6">{level?.title}</p>

        {/* Test result card */}
        {completion ? (
          <div className={`glass rounded-3xl p-6 mb-6 border ${completion.passed ? 'border-green-400/40' : 'border-red-400/40'}`}>
            <div className="flex items-center justify-between">
              <div>
                <div className="text-slate-400 text-sm">Your best score</div>
                <div className={`text-5xl font-black ${completion.passed ? 'text-green-400' : 'text-red-400'}`}>{completion.score}%</div>
                <div className="text-slate-400 mt-1">{completion.correct} / {completion.total} correct</div>
              </div>
              <div className="text-6xl">{completion.passed ? '🎓' : '📝'}</div>
            </div>
            <div className="mt-4 flex gap-3">
              <span className={`px-3 py-1 rounded-full text-sm font-bold ${completion.passed ? 'bg-green-400/20 text-green-300 border border-green-400/40' : 'bg-red-400/20 text-red-300 border border-red-400/40'}`}>
                {completion.passed ? '✅ PASSED' : '❌ NOT PASSED'}
              </span>
              <span className="px-3 py-1 rounded-full text-sm bg-white/10 text-slate-300">
                Completed {new Date(completion.completed_at).toLocaleDateString('en-PK', { day:'numeric', month:'short', year:'numeric' })}
              </span>
            </div>
          </div>
        ) : (
          <div className="glass rounded-3xl p-6 mb-6 text-center">
            <p className="text-slate-400">You have not taken this level test yet.</p>
            <Link href={`/test/${params.levelId}`} className="inline-block mt-4 px-5 py-3 rounded-xl neon font-bold">Take Level Test</Link>
          </div>
        )}

        {/* What you studied */}
        <div className="glass rounded-3xl p-6 mb-6">
          <h2 className="text-xl font-bold mb-4">📚 What you studied</h2>
          <div className="grid grid-cols-2 gap-3 mb-4">
            <div className="rounded-2xl bg-white/5 p-4">
              <div className="text-2xl font-black text-cyan-400">{parseInt(lessonCount?.cnt)||0}</div>
              <div className="text-slate-400 text-sm">Study lessons</div>
            </div>
            <div className="rounded-2xl bg-white/5 p-4">
              <div className="text-2xl font-black text-purple-400">{parseInt(qCount?.cnt)||0}</div>
              <div className="text-slate-400 text-sm">Practice questions</div>
            </div>
          </div>
          {topics.length > 0 && (
            <div>
              <div className="text-sm text-slate-400 mb-2">Topics covered:</div>
              <div className="flex flex-wrap gap-2">
                {topics.map((t: any) => (
                  <span key={t.id} className="px-3 py-1 rounded-full bg-white/10 text-sm text-slate-200">✓ {t.title}</span>
                ))}
              </div>
            </div>
          )}
        </div>

        {/* Actions */}
        <div className="flex flex-wrap gap-3">
          <Link href={`/study/${params.levelId}`} className="px-5 py-3 rounded-xl bg-white/10 font-medium">📚 Review Study Material</Link>
          <Link href={`/test/${params.levelId}`} className="px-5 py-3 rounded-xl neon font-bold">⚡ Retest</Link>
          {level && <Link href={`/dashboard?exam=${level.test_slug}`} className="px-5 py-3 rounded-xl bg-white/10">← Dashboard</Link>}
        </div>
      </div>
    </StudentShell>
  );
}
