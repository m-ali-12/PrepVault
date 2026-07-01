import StudentShell from '@/components/StudentShell';
import { one, query } from '@/lib/db';
import Link from 'next/link';

export const dynamic = 'force-dynamic';

const categoryColors: Record<string, string> = {
  'Analytical': 'text-purple-300 bg-purple-400/10 border-purple-400/30',
  'Quantitative': 'text-cyan-300 bg-cyan-400/10 border-cyan-400/30',
  'Verbal': 'text-green-300 bg-green-400/10 border-green-400/30',
  'General': 'text-amber-300 bg-amber-400/10 border-amber-400/30',
};

export default async function Study({ params }: { params: { levelId: string } }) {
  const level = await one(
    `SELECT l.*, t.name as test_name, t.slug as test_slug, t.short_name
     FROM levels l JOIN tests t ON t.id = l.test_id
     WHERE l.id = $1`,
    [params.levelId]
  );

  const topics = await query(
    'SELECT * FROM topics WHERE level_id=$1 ORDER BY order_no',
    [params.levelId]
  ).catch(() => []);

  const lessons = await query(
    `SELECT lessons.*, topics.title as topic_title, topics.category, topics.slug as topic_slug
     FROM lessons
     JOIN topics ON topics.id = lessons.topic_id
     WHERE topics.level_id = $1
     ORDER BY topics.order_no, lessons.order_no`,
    [params.levelId]
  ).catch(() => []);

  const grouped: Record<string, any[]> = {};
  for (const l of lessons) {
    const key = l.topic_title || 'General';
    if (!grouped[key]) grouped[key] = [];
    grouped[key].push(l);
  }

  if (!level) {
    return (
      <StudentShell>
        <div className="max-w-3xl mx-auto">
          <p className="text-slate-400 text-sm mb-2">Demo Mode — Connect database to load full content</p>
          <h1 className="text-4xl font-black">Analytical Reasoning Foundations</h1>
          <div className="mt-6 glass rounded-3xl p-6">
            <h2 className="text-xl font-bold text-purple-300">Analytical Reasoning</h2>
            <div className="mt-4 space-y-4">
              <div className="border border-white/10 rounded-2xl p-4">
                <h3 className="font-bold">Logical Connectives</h3>
                <p className="text-slate-300 mt-2">If A implies B, the contrapositive (not B → not A) is always valid. Never reverse or inverse a statement.</p>
              </div>
              <div className="border border-white/10 rounded-2xl p-4">
                <h3 className="font-bold">Ordering Method</h3>
                <p className="text-slate-300 mt-2">Draw a diagram first. "Immediately before" means nothing is between the two elements.</p>
              </div>
            </div>
          </div>
          <Link className="inline-block mt-6 neon rounded-xl px-5 py-3 font-bold" href={`/test/${params.levelId}`}>Take Level Test →</Link>
        </div>
      </StudentShell>
    );
  }

  return (
    <StudentShell>
      <div className="max-w-3xl mx-auto">
        {/* Breadcrumb */}
        <div className="flex items-center gap-2 text-sm text-slate-400 mb-4">
          <Link href="/exams" className="hover:text-white">Exams</Link>
          <span>/</span>
          <Link href={`/dashboard?exam=${level.test_slug}`} className="hover:text-white">{level.short_name}</Link>
          <span>/</span>
          <span className="text-white">Level {level.level_no}</span>
        </div>

        {/* Header */}
        <div className="inline-block px-3 py-1 rounded-full bg-cyan-400/10 border border-cyan-400/30 text-cyan-300 text-sm mb-3">
          {level.test_name} — Level {level.level_no}
        </div>
        <h1 className="text-4xl font-black">{level.title}</h1>
        <p className="text-slate-400 mt-2 mb-6">Study each topic carefully, then take the level test. You need 85% to unlock the next level.</p>

        {/* Topics summary */}
        {topics.length > 0 && (
          <div className="flex flex-wrap gap-2 mb-6">
            {topics.map((t: any) => (
              <span key={t.id} className={`px-3 py-1 rounded-full text-sm border ${categoryColors[t.category] || 'text-slate-300 bg-white/5 border-white/10'}`}>
                {t.title}
              </span>
            ))}
          </div>
        )}

        {/* Lessons grouped by topic */}
        {Object.keys(grouped).length === 0 ? (
          <div className="glass rounded-3xl p-6 text-slate-400">
            Study material for this level is being added by admin. Check back soon.
          </div>
        ) : (
          <div className="space-y-6">
            {Object.entries(grouped).map(([topic, topicLessons]) => {
              const cat = topicLessons[0]?.category || 'General';
              const colorClass = categoryColors[cat] || 'text-slate-300 bg-white/5 border-white/10';
              return (
                <div key={topic} className="glass rounded-3xl overflow-hidden">
                  <div className={`px-6 py-3 border-b border-white/10 flex items-center gap-3`}>
                    <span className={`text-xs font-bold px-2 py-1 rounded-full border ${colorClass}`}>{cat}</span>
                    <h2 className="text-xl font-bold">{topic}</h2>
                  </div>
                  <div className="p-4 space-y-3">
                    {topicLessons.map((l: any) => (
                      <div key={l.id} className="rounded-2xl bg-white/5 p-5">
                        <h3 className="font-bold text-lg">{l.title}</h3>
                        <p className="text-slate-300 mt-2 whitespace-pre-wrap leading-relaxed">{l.content_md}</p>
                        {l.source_reference && (
                          <div className="mt-3 text-xs text-cyan-400 font-medium">📌 {l.source_reference}</div>
                        )}
                      </div>
                    ))}
                  </div>
                </div>
              );
            })}
          </div>
        )}

        <div className="mt-8 flex gap-3">
          <Link href={`/dashboard?exam=${level.test_slug}`} className="px-5 py-3 rounded-xl bg-white/10">← Dashboard</Link>
          <Link className="px-6 py-3 rounded-xl neon font-bold" href={`/test/${params.levelId}`}>Take Level Test →</Link>
        </div>
      </div>
    </StudentShell>
  );
}
