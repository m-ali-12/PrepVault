import { NextResponse } from 'next/server';
import { currentUser } from '@/lib/auth';
import { pool, query } from '@/lib/db';

export async function POST(req: Request){
  const user = await currentUser();
  if(!user) return NextResponse.json({ error: 'Login required' }, { status: 401 });
  const { levelId, score, correct, total } = await req.json();
  if(!levelId || score === undefined) return NextResponse.json({ error: 'Missing fields' }, { status: 400 });
  try {
    await pool.query(
      `INSERT INTO level_completions(user_id, level_id, score, correct, total, passed)
       VALUES($1,$2,$3,$4,$5,$6)
       ON CONFLICT(user_id, level_id)
       DO UPDATE SET score=$3, correct=$4, total=$5, passed=$6, completed_at=now()`,
      [user.id, levelId, score, correct, total, score >= 85]
    );
    return NextResponse.json({ ok: true });
  } catch(e: any) {
    return NextResponse.json({ error: e.message }, { status: 500 });
  }
}

export async function GET(req: Request){
  const user = await currentUser();
  if(!user) return NextResponse.json({ completions: [] });
  const rows = await query(
    'SELECT level_id, score, correct, total, passed, completed_at FROM level_completions WHERE user_id=$1',
    [user.id]
  ).catch(() => []);
  return NextResponse.json({ completions: rows });
}
