import { NextResponse } from 'next/server';
import { query } from '@/lib/db';
import { fallbackQuestions } from '@/lib/data';

export async function POST(req: Request){
  const { levelId, excludeIds = [] } = await req.json();
  
  let questions: any[] = [];
  try {
    if(excludeIds.length > 0){
      questions = await query(
        `SELECT * FROM questions WHERE level_id=$1 AND is_verified=true AND id NOT IN (${excludeIds.map((_:any,i:number)=>`$${i+2}`).join(',')}) ORDER BY random() LIMIT 20`,
        [levelId, ...excludeIds]
      );
    } else {
      questions = await query(
        'SELECT * FROM questions WHERE level_id=$1 AND is_verified=true ORDER BY random() LIMIT 20',
        [levelId]
      );
    }
  } catch(e) {}

  if(!questions.length) questions = fallbackQuestions;
  return NextResponse.json({ questions });
}
