import React, { useState, useEffect } from 'react';
import { api } from './api';
import { Users, Sprout, BookText, ChevronRight, ArrowLeft } from 'lucide-react';
import StudentDetailModal from './StudentDetailModal';

function App() {
  const [stats, setStats] = useState({ totalStudents: 0, totalPlants: 0, entriesToday: 0 });
  const [students, setStudents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedStudent, setSelectedStudent] = useState(null);

  useEffect(() => {
    loadDashboard();
  }, []);

  const loadDashboard = async () => {
    try {
      const statsRes = await api.getStats();
      const studentsRes = await api.getStudents();
      setStats(statsRes.data);
      setStudents(studentsRes.data);
    } catch (error) {
      console.error("Error loading dashboard", error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div className="loading-spinner">Loading Dashboard...</div>;
  }

  return (
    <div className="modern-container">
      <header style={{ marginBottom: '2rem' }}>
        <h1 style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <Sprout size={36} /> Fowra Teacher Dashboard
        </h1>
        <p style={{ color: 'var(--text-light)' }}>Monitor student agricultural progress in real-time.</p>
      </header>

      {selectedStudent ? (
        <StudentDetailModal
          student={selectedStudent}
          onBack={() => setSelectedStudent(null)}
        />
      ) : (
        <>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '1.5rem', marginBottom: '3rem' }}>
            <StatCard icon={<Users size={24} />} title="Total Students" value={stats.totalStudents} />
            <StatCard icon={<Sprout size={24} />} title="Total Plants Logged" value={stats.totalPlants} />
            <StatCard icon={<BookText size={24} />} title="Reports Today" value={stats.entriesToday} />
          </div>

          <div className="glass-panel" style={{ padding: '2rem' }}>
            <h2 style={{ marginBottom: '1.5rem' }}>Registered Students</h2>
            <div style={{ overflowX: 'auto' }}>
              <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
                <thead>
                  <tr style={{ borderBottom: '2px solid var(--border)', color: 'var(--text-light)' }}>
                    <th style={{ padding: '1rem' }}>Name</th>
                    <th style={{ padding: '1rem' }}>Class & Year</th>
                    <th style={{ padding: '1rem' }}>Email</th>
                    <th style={{ padding: '1rem', textAlign: 'right' }}>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {students.map(student => (
                    <tr key={student.id} style={{ borderBottom: '1px solid var(--border)', cursor: 'pointer', transition: 'background 0.2s' }} onClick={() => setSelectedStudent(student)} onMouseEnter={(e) => e.currentTarget.style.backgroundColor = 'rgba(46, 101, 77, 0.05)'} onMouseLeave={(e) => e.currentTarget.style.backgroundColor = 'transparent'}>
                      <td style={{ padding: '1rem', fontWeight: '600' }}>{student.name}</td>
                      <td style={{ padding: '1rem' }}>{student.class} - {student.year}</td>
                      <td style={{ padding: '1rem', color: 'var(--text-light)' }}>{student.email}</td>
                      <td style={{ padding: '1rem', textAlign: 'right', color: 'var(--primary)' }}>
                        <button style={{ display: 'flex', alignItems: 'center', gap: '0.25rem', color: 'inherit', fontWeight: '600', marginLeft: 'auto' }}>
                          View Details <ChevronRight size={16} />
                        </button>
                      </td>
                    </tr>
                  ))}
                  {students.length === 0 && (
                    <tr>
                      <td colSpan="4" style={{ padding: '2rem', textAlign: 'center', color: 'var(--text-light)' }}>No students registered yet.</td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>
        </>
      )}
    </div>
  );
}

function StatCard({ icon, title, value }) {
  return (
    <div className="glass-panel" style={{ padding: '1.5rem', display: 'flex', alignItems: 'flex-start', gap: '1rem' }}>
      <div style={{ backgroundColor: 'var(--secondary)', color: 'var(--primary)', padding: '1rem', borderRadius: '12px' }}>
        {icon}
      </div>
      <div>
        <h3 style={{ fontSize: '1rem', color: 'var(--text-light)', fontWeight: '500', marginBottom: '0.25rem' }}>{title}</h3>
        <div style={{ fontSize: '2rem', fontWeight: '700', color: 'var(--primary)' }}>{value}</div>
      </div>
    </div>
  );
}

export default App;
