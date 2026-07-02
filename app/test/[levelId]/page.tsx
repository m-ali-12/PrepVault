import StudentShell from '@/components/StudentShell';
import { one, query } from '@/lib/db';
import { fallbackQuestions } from '@/lib/data';
import TestClient from './test-client';
import Link from 'next/link';

export const dynamic = 'force-dynamic';

export default async function TestPage({ params }: { params: { levelId: string } }) {
  const level = await one(
    `SELECT l.*, t.name as test_name, t.slug as test_slug, t.short_name
     FROM levels l JOIN tests t ON t.id=l.test_id WHERE l.id=$1`,
    [params.levelId]
  ).catch(() => null);

  // Get next level
  const nextLevel = level ? await one(
    `SELECT l.id, l.level_no, l.title FROM levels l
     WHERE l.test_id=$1 AND l.level_no=$2`,
    [level.test_id, level.level_no + 1]
  ).catch(() => null) : null;

  let questions: any[] = await query(
    'SELECT * FROM questions WHERE level_id=$1 AND is_verified=true ORDER BY random() LIMIT 20',
    [params.levelId]
  ).catch(() => []);

  if (!questions.length) questions = fallbackQuestions;

  return (
    <StudentShell>
      <div className="max-w-2xl mx-auto">
        {level && (
          <div className="flex items-center gap-2 text-sm text-slate-400 mb-4">
            <Link href="/exams" className="hover:text-white">Exams</Link>
            <span>/</span>
            <Link href={`/dashboard?exam=${level.test_slug}`} className="hover:text-white">{level.short_name}</Link>
            <span>/</span>
            <span className="text-white">Level {level.level_no} Test</span>
          </div>
        )}

        <div className="mb-6">
          <div className="inline-block px-3 py-1 rounded-full bg-red-400/10 border border-red-400/30 text-red-300 text-sm mb-2">
            ⚡ Anti-cheat active — tab switch monitored
          </div>
          <h1 className="text-4xl font-black">
            {level ? `${level.short_name} — Level ${level.level_no} Test` : 'Level Test'}
          </h1>
          <p className="text-slate-400 mt-1">{questions.length} randomized questions • Pass with 85% to unlock next level</p>
        </div>

        <TestClient
          questions={questions}
          levelId={params.levelId}
          nextLevelId={nextLevel?.id || null}
          nextLevelTitle={nextLevel ? `Level ${nextLevel.level_no}: ${nextLevel.title}` : null}
          examSlug={level?.test_slug || 'hat'}
        />
      </div>
    </StudentShell>
  );
}
