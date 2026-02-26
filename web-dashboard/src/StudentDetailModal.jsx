import React, { useState, useEffect } from 'react';
import { api } from './api';
import { ArrowLeft, Leaf, CalendarDays, Droplets, Wind, RotateCw } from 'lucide-react';

export default function StudentDetailModal({ student, onBack }) {
    const [plants, setPlants] = useState([]);
    const [diary, setDiary] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        loadStudentData();
    }, [student.id]);

    const loadStudentData = async () => {
        try {
            const plantsRes = await api.getStudentPlants(student.id);
            const diaryRes = await api.getStudentDiary(student.id);
            setPlants(plantsRes.data);
            setDiary(diaryRes.data);
        } catch (error) {
            console.error("Error loading student details", error);
        } finally {
            setLoading(false);
        }
    };

    if (loading) return <div className="loading-spinner">Loading Student Data...</div>;

    return (
        <div className="custom-fade-in">
            <button
                onClick={onBack}
                style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '2rem', color: 'var(--text-light)', fontWeight: '600' }}
            >
                <ArrowLeft size={20} /> Back to Student List
            </button>

            <div className="glass-panel" style={{ padding: '2rem', marginBottom: '2rem', borderLeft: '6px solid var(--primary)' }}>
                <h2>{student.name}</h2>
                <p style={{ color: 'var(--text-light)', marginTop: '0.5rem' }}>
                    Class: {student.class} | Year: {student.year} | Email: {student.email}
                </p>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 2fr', gap: '2rem' }}>

                {/* Plants Section */}
                <div className="glass-panel" style={{ padding: '2rem' }}>
                    <h3 style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '1.5rem' }}>
                        <Leaf size={24} /> Registered Plants ({plants.length})
                    </h3>

                    <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
                        {plants.map(p => (
                            <div key={p.id} style={{ padding: '1rem', backgroundColor: 'var(--surface)', borderRadius: '12px', border: '1px solid var(--border)' }}>
                                <div style={{ fontWeight: 'bold', fontSize: '1.1rem', color: 'var(--primary)', marginBottom: '0.5rem' }}>{p.name}</div>
                                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.5rem', fontSize: '0.9rem', color: 'var(--text-light)' }}>
                                    <div>💧 Water: {p.water_amount} ml</div>
                                    <div>☀️ Sun: {p.sun_exposure} hrs</div>
                                    <div>🧪 pH: {p.soil_ph}</div>
                                    <div>📏 Height: {p.height} cm</div>
                                </div>
                            </div>
                        ))}
                        {plants.length === 0 && <p style={{ color: 'var(--text-light)' }}>No plants registered yet.</p>}
                    </div>
                </div>

                {/* Diary Section */}
                <div className="glass-panel" style={{ padding: '2rem' }}>
                    <h3 style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '1.5rem' }}>
                        <CalendarDays size={24} /> Daily Reports ({diary.length})
                    </h3>

                    <div style={{ maxHeight: '600px', overflowY: 'auto', paddingRight: '1rem' }}>
                        {diary.map(d => (
                            <div key={d.id} style={{ padding: '1.5rem', backgroundColor: 'var(--surface)', borderRadius: '12px', border: '1px solid var(--border)', marginBottom: '1rem' }}>
                                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem', borderBottom: '1px solid var(--border)', paddingBottom: '0.5rem' }}>
                                    <span style={{ fontWeight: 'bold', color: 'var(--primary)' }}>
                                        {new Date(d.entry_date).toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
                                    </span>
                                    <span style={{ fontSize: '0.85rem', backgroundColor: 'var(--accent)', color: 'white', padding: '0.2rem 0.6rem', borderRadius: '12px', fontWeight: 'bold' }}>
                                        Submitted at {d.entry_time || 'Unknown Time'}
                                    </span>
                                </div>

                                <p style={{ fontStyle: 'italic', marginBottom: '1rem', color: 'var(--text-dark)', lineHeight: '1.6' }}>
                                    "{d.notes || 'No notes provided for this day.'}"
                                </p>

                                <div style={{ display: 'flex', gap: '1rem', fontSize: '0.9rem' }}>
                                    <TaskBadge icon={<Droplets size={16} />} label="Watered" done={d.watering} />
                                    <TaskBadge icon={<Wind size={16} />} label="Misted" done={d.misting} />
                                    <TaskBadge icon={<Leaf size={16} />} label="Fertilized" done={d.fertilizing} />
                                    <TaskBadge icon={<RotateCw size={16} />} label="Rotated" done={d.rotating} />
                                </div>
                            </div>
                        ))}
                        {diary.length === 0 && <p style={{ color: 'var(--text-light)' }}>No reports submitted yet.</p>}
                    </div>
                </div>

            </div>
        </div>
    );
}

function TaskBadge({ icon, label, done }) {
    return (
        <div style={{
            display: 'flex',
            alignItems: 'center',
            gap: '0.3rem',
            padding: '0.3rem 0.6rem',
            borderRadius: '8px',
            backgroundColor: done ? 'var(--secondary)' : '#f0f0f0',
            color: done ? 'var(--primary)' : 'var(--text-light)',
            fontWeight: done ? '600' : '400',
            opacity: done ? 1 : 0.5
        }}>
            {icon} {label}
        </div>
    );
}
