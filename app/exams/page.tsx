import StudentShell from '@/components/StudentShell';
import Link from 'next/link';

const exams = [
  {
    slug: 'hat',
    name: 'HAT',
    full: 'HEC Achievement Test',
    icon: '🎓',
    desc: 'For BS/MSc/MPhil/PhD admissions. Tests Analytical, Quantitative and Verbal reasoning.',
    topics: ['Analytical Reasoning', 'Quantitative Reasoning', 'Verbal Reasoning'],
    color: 'from-cyan-400/20 to-blue-400/10 border-cyan-400/30',
  },
  {
    slug: 'lat',
    name: 'LAT',
    full: 'Law Admission Test',
    icon: '⚖️',
    desc: 'For LLB admission in Pakistan. Tests logical, verbal and general knowledge.',
    topics: ['Legal Reasoning', 'Verbal Ability', 'General Knowledge'],
    color: 'from-purple-400/20 to-pink-400/10 border-purple-400/30',
  },
  {
    slug: 'ecat',
    name: 'ECAT',
    full: 'Engineering College Admission Test',
    icon: '⚙️',
    desc: 'For engineering universities in Punjab. Tests Physics, Chemistry, Math.',
    topics: ['Mathematics', 'Physics', 'Chemistry', 'English'],
    color: 'from-green-400/20 to-emerald-400/10 border-green-400/30',
  },
  {
    slug: 'mdcat',
    name: 'MDCAT',
    full: 'Medical & Dental College Admission Test',
    icon: '🏥',
    desc: 'For medical colleges in Pakistan. Tests Biology, Chemistry, Physics, English.',
    topics: ['Biology', 'Chemistry', 'Physics', 'English'],
    color: 'from-red-400/20 to-orange-400/10 border-red-400/30',
  },
  {
    slug: 'lawgat',
    name: 'Law GAT',
    full: 'Graduate Assessment Test (Law)',
    icon: '📜',
    desc: 'For LLM admissions. Tests advanced legal reasoning and analytical ability.',
    topics: ['Legal Reasoning', 'Analytical Skills', 'Verbal Reasoning'],
    color: 'from-amber-400/20 to-yellow-400/10 border-amber-400/30',
  },
];

export default function Exams() {
  return (
    <StudentShell>
      <div className="max-w-5xl mx-auto">
        <h1 className="text-4xl font-black mb-2">Choose Your Exam</h1>
        <p className="text-slate-400 mb-8">
          Select the test you are preparing for. Your dashboard, study levels and mock tests will be tailored to it.
        </p>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-5">
          {exams.map(e => (
            <Link
              key={e.slug}
              href={`/dashboard?exam=${e.slug}`}
              className={`glass rounded-3xl p-6 border bg-gradient-to-br ${e.color} hover:scale-[1.02] transition-transform`}
            >
              <div className="text-4xl mb-3">{e.icon}</div>
              <div className="flex items-baseline gap-2">
                <h2 className="text-2xl font-black">{e.name}</h2>
                <span className="text-xs text-slate-400">{e.full}</span>
              </div>
              <p className="text-slate-300 mt-2 text-sm">{e.desc}</p>
              <div className="mt-4 flex flex-wrap gap-2">
                {e.topics.map(t => (
                  <span key={t} className="px-2 py-1 rounded-lg bg-white/10 text-xs text-slate-300">{t}</span>
                ))}
              </div>
              <div className="mt-5 text-sm font-bold text-white">Start Preparation →</div>
            </Link>
          ))}
        </div>
      </div>
    </StudentShell>
  );
}
