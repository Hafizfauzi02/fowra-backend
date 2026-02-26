const API_BASE_URL = 'https://fowra-api.onrender.com/api';

export const api = {
    getStats: async () => {
        const res = await fetch(`${API_BASE_URL}/admin/stats`);
        if (!res.ok) throw new Error('Failed to fetch stats');
        return res.json();
    },

    getStudents: async () => {
        const res = await fetch(`${API_BASE_URL}/admin/students`);
        if (!res.ok) throw new Error('Failed to fetch students');
        return res.json();
    },

    getStudentPlants: async (studentId) => {
        const res = await fetch(`${API_BASE_URL}/admin/student/${studentId}/plants`);
        if (!res.ok) throw new Error('Failed to fetch plants');
        return res.json();
    },

    getStudentDiary: async (studentId) => {
        const res = await fetch(`${API_BASE_URL}/admin/student/${studentId}/diary`);
        if (!res.ok) throw new Error('Failed to fetch diary');
        return res.json();
    },

    deleteStudent: async (studentId) => {
        const res = await fetch(`${API_BASE_URL}/admin/student/${studentId}`, {
            method: 'DELETE'
        });
        if (!res.ok) throw new Error('Failed to delete student');
        return res.json();
    }
};
