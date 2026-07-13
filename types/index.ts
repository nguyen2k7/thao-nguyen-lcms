// User Types
export type UserRole = 'student' | 'teacher' | 'manager' | 'admin';

export interface User {
  id: string;
  email: string;
  name: string;
  role: UserRole;
  avatar_url?: string;
  phone?: string;
  created_at: string;
  updated_at: string;
}

export interface Student extends User {
  student_id: string;
  date_of_birth?: string;
  current_level?: string;
}

export interface Teacher extends User {
  teacher_id: string;
  qualifications?: string[];
  specialties?: string[];
}

// Course Types
export interface Course {
  id: string;
  name: string;
  code: string;
  description: string;
  level: string;
  price: number;
  promotional_price?: number;
  duration: number;
  total_sessions: number;
  max_students: number;
  created_at: string;
}

export interface Class {
  id: string;
  course_id: string;
  name: string;
  code: string;
  teacher_id: string;
  room?: string;
  online_link?: string;
  start_date: string;
  end_date: string;
  status: 'planning' | 'ongoing' | 'completed' | 'cancelled';
}

// Payment Types
export interface Payment {
  id: string;
  registration_id: string;
  amount: number;
  payment_method: 'cash' | 'transfer' | 'card';
  status: 'pending' | 'completed' | 'failed';
  paid_at?: string;
  created_at: string;
}

export interface Invoice {
  id: string;
  payment_id: string;
  invoice_number: string;
  amount: number;
  issued_date: string;
  due_date: string;
  status: 'draft' | 'issued' | 'paid' | 'cancelled';
}

// Progress Types
export interface StudentProgress {
  id: string;
  student_id: string;
  course_id: string;
  completion_percentage: number;
  total_lessons: number;
  completed_lessons: number;
  updated_at: string;
}

export interface StudentScore {
  id: string;
  student_id: string;
  assignment_id: string;
  score: number;
  max_score: number;
  submitted_at: string;
  graded_at?: string;
}
