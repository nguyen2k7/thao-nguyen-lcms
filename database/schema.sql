-- ============================================================================
-- LCMS - Language Center Management System
-- Database Schema for PostgreSQL (Supabase Compatible)
-- ============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- 1. AUTHENTICATION & USERS
-- ============================================================================

-- Roles table
CREATE TABLE IF NOT EXISTS roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(50) UNIQUE NOT NULL,
  description TEXT,
  level INT DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  avatar_url TEXT,
  role VARCHAR(50) NOT NULL DEFAULT 'student',
  
  -- Personal Info
  date_of_birth DATE,
  gender VARCHAR(10),
  address TEXT,
  city VARCHAR(100),
  district VARCHAR(100),
  ward VARCHAR(100),
  
  -- Account Status
  is_active BOOLEAN DEFAULT true,
  is_email_verified BOOLEAN DEFAULT false,
  is_phone_verified BOOLEAN DEFAULT false,
  email_verified_at TIMESTAMP,
  
  -- Timestamps
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_login_at TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_is_active ON users(is_active);

-- Permissions table
CREATE TABLE IF NOT EXISTS permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) UNIQUE NOT NULL,
  description TEXT,
  module VARCHAR(50),
  action VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User roles junction table
CREATE TABLE IF NOT EXISTS user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
  assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  assigned_by UUID REFERENCES users(id),
  
  UNIQUE(user_id, role_id)
);

CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);

-- Students table
CREATE TABLE IF NOT EXISTS students (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  student_id VARCHAR(50) UNIQUE,
  current_level VARCHAR(10),
  
  -- Learning Progress
  total_courses INT DEFAULT 0,
  completed_courses INT DEFAULT 0,
  in_progress_courses INT DEFAULT 0,
  
  -- Academic Info
  date_enrolled DATE DEFAULT CURRENT_DATE,
  preferred_time VARCHAR(50),
  learning_goals TEXT,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_students_user_id ON students(user_id);
CREATE INDEX idx_students_student_id ON students(student_id);

-- Teachers table
CREATE TABLE IF NOT EXISTS teachers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  teacher_id VARCHAR(50) UNIQUE,
  
  -- Professional Info
  qualifications TEXT[],
  specialties TEXT[],
  experience_years INT,
  bio TEXT,
  
  -- Teaching Info
  total_classes INT DEFAULT 0,
  active_classes INT DEFAULT 0,
  students_taught INT DEFAULT 0,
  
  -- Rating
  average_rating DECIMAL(3,2) DEFAULT 0,
  total_ratings INT DEFAULT 0,
  
  is_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_teachers_user_id ON teachers(user_id);
CREATE INDEX idx_teachers_teacher_id ON teachers(teacher_id);

-- ============================================================================
-- 2. COURSES & CLASSES
-- ============================================================================

-- Course categories
CREATE TABLE IF NOT EXISTS course_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  icon_url TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Courses table
CREATE TABLE IF NOT EXISTS courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  code VARCHAR(50) UNIQUE NOT NULL,
  description TEXT,
  slug VARCHAR(255) UNIQUE,
  category_id UUID REFERENCES course_categories(id),
  
  -- Course Details
  level VARCHAR(10),
  language VARCHAR(50),
  duration_hours INT,
  total_sessions INT,
  max_students INT,
  
  -- Pricing
  price DECIMAL(10,2) NOT NULL,
  promotional_price DECIMAL(10,2),
  discount_percent INT DEFAULT 0,
  
  -- Course Content
  thumbnail_url TEXT,
  video_intro_url TEXT,
  learning_outcomes TEXT[],
  requirements TEXT[],
  
  -- Status
  is_active BOOLEAN DEFAULT true,
  is_featured BOOLEAN DEFAULT false,
  status VARCHAR(50) DEFAULT 'planning',
  
  -- Metadata
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_courses_code ON courses(code);
CREATE INDEX idx_courses_level ON courses(level);
CREATE INDEX idx_courses_is_active ON courses(is_active);

-- Classes table
CREATE TABLE IF NOT EXISTS classes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  code VARCHAR(50) UNIQUE NOT NULL,
  
  -- Teacher & Room
  teacher_id UUID NOT NULL REFERENCES teachers(id),
  room VARCHAR(100),
  online_link TEXT,
  
  -- Schedule
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  
  -- Capacity
  max_students INT,
  current_students INT DEFAULT 0,
  
  -- Status
  status VARCHAR(50) DEFAULT 'planning',
  
  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_classes_course_id ON classes(course_id);
CREATE INDEX idx_classes_teacher_id ON classes(teacher_id);
CREATE INDEX idx_classes_code ON classes(code);
CREATE INDEX idx_classes_status ON classes(status);

-- Class schedules table
CREATE TABLE IF NOT EXISTS class_schedules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  
  -- Schedule Details
  day_of_week VARCHAR(20),
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  
  -- Session Info
  room VARCHAR(100),
  online_link TEXT,
  is_online BOOLEAN DEFAULT false,
  
  -- Status
  is_active BOOLEAN DEFAULT true,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_class_schedules_class_id ON class_schedules(class_id);

-- Enrollments table
CREATE TABLE IF NOT EXISTS enrollments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  
  -- Status
  status VARCHAR(50) DEFAULT 'enrolled',
  enrollment_date DATE DEFAULT CURRENT_DATE,
  completion_date DATE,
  
  -- Progress
  attendance_rate DECIMAL(5,2) DEFAULT 0,
  final_score DECIMAL(5,2),
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  UNIQUE(student_id, class_id)
);

CREATE INDEX idx_enrollments_student_id ON enrollments(student_id);
CREATE INDEX idx_enrollments_class_id ON enrollments(class_id);

-- ============================================================================
-- 3. LEARNING CONTENT
-- ============================================================================

-- Lessons table
CREATE TABLE IF NOT EXISTS lessons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  
  -- Content
  content TEXT,
  order_index INT NOT NULL,
  
  -- Media
  thumbnail_url TEXT,
  video_url TEXT,
  video_duration INT,
  
  -- Access Control
  is_published BOOLEAN DEFAULT false,
  is_free BOOLEAN DEFAULT false,
  
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_lessons_course_id ON lessons(course_id);
CREATE INDEX idx_lessons_is_published ON lessons(is_published);

-- Lesson materials table
CREATE TABLE IF NOT EXISTS lesson_materials (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  
  title VARCHAR(255) NOT NULL,
  type VARCHAR(50),
  file_url TEXT,
  file_size INT,
  
  order_index INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_lesson_materials_lesson_id ON lesson_materials(lesson_id);

-- Assignments table
CREATE TABLE IF NOT EXISTS assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  
  title VARCHAR(255) NOT NULL,
  description TEXT,
  type VARCHAR(50),
  
  -- Due Date
  due_date DATE,
  allow_late_submission BOOLEAN DEFAULT false,
  late_submission_days INT DEFAULT 0,
  
  -- Grading
  total_points INT DEFAULT 100,
  passing_score INT DEFAULT 60,
  
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_assignments_lesson_id ON assignments(lesson_id);

-- Assignment submissions table
CREATE TABLE IF NOT EXISTS assignment_submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  assignment_id UUID NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  
  -- Submission
  submission_text TEXT,
  file_url TEXT,
  submitted_at TIMESTAMP,
  
  -- Grading
  score INT,
  feedback TEXT,
  graded_at TIMESTAMP,
  graded_by UUID REFERENCES teachers(id),
  
  status VARCHAR(50) DEFAULT 'draft',
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_assignment_submissions_assignment_id ON assignment_submissions(assignment_id);
CREATE INDEX idx_assignment_submissions_student_id ON assignment_submissions(student_id);

-- Quizzes table
CREATE TABLE IF NOT EXISTS quizzes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  
  title VARCHAR(255) NOT NULL,
  description TEXT,
  
  -- Quiz Settings
  total_questions INT,
  passing_score INT DEFAULT 60,
  time_limit_minutes INT,
  allow_retake BOOLEAN DEFAULT false,
  max_attempts INT DEFAULT 1,
  
  -- Randomization
  randomize_questions BOOLEAN DEFAULT false,
  randomize_options BOOLEAN DEFAULT false,
  
  is_published BOOLEAN DEFAULT false,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_quizzes_lesson_id ON quizzes(lesson_id);

-- Quiz questions table
CREATE TABLE IF NOT EXISTS quiz_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
  
  question_text TEXT NOT NULL,
  question_type VARCHAR(50),
  
  -- Options (JSONB for flexibility)
  options JSONB,
  correct_answer VARCHAR(50),
  explanation TEXT,
  
  points INT DEFAULT 1,
  order_index INT,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_quiz_questions_quiz_id ON quiz_questions(quiz_id);

-- Quiz responses table
CREATE TABLE IF NOT EXISTS quiz_responses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  
  -- Attempt
  attempt_number INT DEFAULT 1,
  started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  submitted_at TIMESTAMP,
  
  -- Responses (JSONB)
  responses JSONB,
  
  -- Results
  total_score INT,
  max_score INT,
  percentage DECIMAL(5,2),
  status VARCHAR(50) DEFAULT 'in_progress',
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_quiz_responses_quiz_id ON quiz_responses(quiz_id);
CREATE INDEX idx_quiz_responses_student_id ON quiz_responses(student_id);

-- Flashcard sets table
CREATE TABLE IF NOT EXISTS flashcard_sets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
  lesson_id UUID REFERENCES lessons(id) ON DELETE CASCADE,
  
  title VARCHAR(255) NOT NULL,
  description TEXT,
  
  total_cards INT DEFAULT 0,
  difficulty_level VARCHAR(20),
  
  is_public BOOLEAN DEFAULT false,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_flashcard_sets_course_id ON flashcard_sets(course_id);
CREATE INDEX idx_flashcard_sets_lesson_id ON flashcard_sets(lesson_id);

-- Flashcards table
CREATE TABLE IF NOT EXISTS flashcards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  flashcard_set_id UUID NOT NULL REFERENCES flashcard_sets(id) ON DELETE CASCADE,
  
  front_text TEXT NOT NULL,
  back_text TEXT NOT NULL,
  
  -- Media
  front_image_url TEXT,
  back_image_url TEXT,
  audio_url TEXT,
  
  order_index INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_flashcards_flashcard_set_id ON flashcards(flashcard_set_id);

-- ============================================================================
-- 4. PROGRESS & SCORING
-- ============================================================================

-- Student progress table
CREATE TABLE IF NOT EXISTS student_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  
  -- Progress Metrics
  total_lessons INT DEFAULT 0,
  completed_lessons INT DEFAULT 0,
  completion_percentage DECIMAL(5,2) DEFAULT 0,
  
  -- Engagement
  last_accessed_at TIMESTAMP,
  total_learning_hours INT DEFAULT 0,
  
  -- Status
  status VARCHAR(50) DEFAULT 'in_progress',
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_student_progress_student_id ON student_progress(student_id);
CREATE INDEX idx_student_progress_class_id ON student_progress(class_id);

-- Lesson progress table
CREATE TABLE IF NOT EXISTS lesson_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  
  -- Completion
  is_completed BOOLEAN DEFAULT false,
  completed_at TIMESTAMP,
  
  -- Time Tracking
  time_spent_minutes INT DEFAULT 0,
  started_at TIMESTAMP,
  
  -- Status
  status VARCHAR(50) DEFAULT 'not_started',
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  UNIQUE(student_id, lesson_id)
);

CREATE INDEX idx_lesson_progress_student_id ON lesson_progress(student_id);

-- Student scores table
CREATE TABLE IF NOT EXISTS student_scores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  
  -- Assessment Type
  assessment_type VARCHAR(50),
  assessment_id UUID,
  
  -- Score
  score DECIMAL(5,2),
  max_score INT DEFAULT 100,
  percentage DECIMAL(5,2),
  
  -- Feedback
  teacher_feedback TEXT,
  
  graded_at TIMESTAMP,
  graded_by UUID REFERENCES teachers(id),
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_student_scores_student_id ON student_scores(student_id);
CREATE INDEX idx_student_scores_class_id ON student_scores(class_id);

-- Certificates table
CREATE TABLE IF NOT EXISTS certificates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  
  certificate_number VARCHAR(100) UNIQUE,
  issue_date DATE DEFAULT CURRENT_DATE,
  expiry_date DATE,
  
  -- Achievement
  final_score DECIMAL(5,2),
  completion_percentage INT,
  
  certificate_url TEXT,
  verification_code VARCHAR(50) UNIQUE,
  
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_certificates_student_id ON certificates(student_id);
CREATE INDEX idx_certificates_course_id ON certificates(course_id);

-- ============================================================================
-- 5. PAYMENTS & FINANCIAL
-- ============================================================================

-- Registrations table
CREATE TABLE IF NOT EXISTS registrations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  
  -- Registration Info
  registration_number VARCHAR(50) UNIQUE,
  registration_date DATE DEFAULT CURRENT_DATE,
  
  -- Pricing
  course_price DECIMAL(10,2),
  discount_amount DECIMAL(10,2) DEFAULT 0,
  promotional_code VARCHAR(50),
  final_price DECIMAL(10,2),
  
  -- Status
  status VARCHAR(50) DEFAULT 'pending',
  
  -- Approval
  approved_by UUID REFERENCES users(id),
  approved_at TIMESTAMP,
  rejection_reason TEXT,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_registrations_student_id ON registrations(student_id);
CREATE INDEX idx_registrations_status ON registrations(status);

-- Payments table
CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  registration_id UUID NOT NULL REFERENCES registrations(id) ON DELETE CASCADE,
  
  -- Payment Info
  payment_number VARCHAR(50) UNIQUE,
  amount DECIMAL(10,2) NOT NULL,
  payment_method VARCHAR(50),
  
  -- Bank Info
  bank_name VARCHAR(255),
  account_name VARCHAR(255),
  account_number VARCHAR(50),
  transaction_reference VARCHAR(100),
  
  -- Status
  status VARCHAR(50) DEFAULT 'pending',
  
  -- Confirmation
  confirmed_by UUID REFERENCES users(id),
  confirmed_at TIMESTAMP,
  confirmation_note TEXT,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_payments_registration_id ON payments(registration_id);
CREATE INDEX idx_payments_status ON payments(status);

-- Invoices table
CREATE TABLE IF NOT EXISTS invoices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  payment_id UUID NOT NULL REFERENCES payments(id) ON DELETE CASCADE,
  
  invoice_number VARCHAR(50) UNIQUE,
  invoice_date DATE DEFAULT CURRENT_DATE,
  due_date DATE,
  
  -- Details
  course_name VARCHAR(255),
  amount DECIMAL(10,2),
  tax_amount DECIMAL(10,2) DEFAULT 0,
  total_amount DECIMAL(10,2),
  
  -- Customer Info
  customer_name VARCHAR(255),
  customer_email VARCHAR(255),
  customer_phone VARCHAR(20),
  
  -- Status
  status VARCHAR(50) DEFAULT 'draft',
  
  -- File
  pdf_url TEXT,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_invoices_payment_id ON invoices(payment_id);

-- Expenses table
CREATE TABLE IF NOT EXISTS expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Expense Info
  expense_number VARCHAR(50) UNIQUE,
  category VARCHAR(100),
  description TEXT,
  
  -- Amount & Date
  amount DECIMAL(10,2) NOT NULL,
  expense_date DATE DEFAULT CURRENT_DATE,
  
  -- Approval
  created_by UUID REFERENCES users(id),
  approved_by UUID REFERENCES users(id),
  approved_at TIMESTAMP,
  
  -- Attachment
  receipt_url TEXT,
  
  -- Status
  status VARCHAR(50) DEFAULT 'pending',
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_expenses_category ON expenses(category);
CREATE INDEX idx_expenses_status ON expenses(status);

-- Financial reports table
CREATE TABLE IF NOT EXISTS financial_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Report Period
  report_date DATE DEFAULT CURRENT_DATE,
  report_month INT,
  report_year INT,
  
  -- Revenue
  total_revenue DECIMAL(12,2) DEFAULT 0,
  course_fees DECIMAL(12,2) DEFAULT 0,
  
  -- Expenses
  total_expenses DECIMAL(12,2) DEFAULT 0,
  salary_expenses DECIMAL(12,2) DEFAULT 0,
  operational_expenses DECIMAL(12,2) DEFAULT 0,
  
  -- Summary
  profit_loss DECIMAL(12,2) DEFAULT 0,
  profit_margin DECIMAL(5,2) DEFAULT 0,
  
  -- Student Stats
  total_registrations INT DEFAULT 0,
  total_paid INT DEFAULT 0,
  total_unpaid INT DEFAULT 0,
  
  generated_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_financial_reports_report_date ON financial_reports(report_date);

-- ============================================================================
-- 6. CMS & NOTIFICATIONS
-- ============================================================================

-- Pages table
CREATE TABLE IF NOT EXISTS pages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  title VARCHAR(255) NOT NULL,
  slug VARCHAR(255) UNIQUE NOT NULL,
  content TEXT,
  
  -- SEO
  meta_title VARCHAR(255),
  meta_description TEXT,
  meta_keywords TEXT,
  
  -- Status
  is_published BOOLEAN DEFAULT false,
  is_featured BOOLEAN DEFAULT false,
  
  author_id UUID REFERENCES users(id),
  published_at TIMESTAMP,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_pages_slug ON pages(slug);
CREATE INDEX idx_pages_is_published ON pages(is_published);

-- News articles table
CREATE TABLE IF NOT EXISTS news_articles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  title VARCHAR(255) NOT NULL,
  slug VARCHAR(255) UNIQUE,
  excerpt TEXT,
  content TEXT,
  
  thumbnail_url TEXT,
  category VARCHAR(100),
  
  is_published BOOLEAN DEFAULT false,
  is_featured BOOLEAN DEFAULT false,
  
  author_id UUID REFERENCES users(id),
  published_at TIMESTAMP,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_news_articles_slug ON news_articles(slug);
CREATE INDEX idx_news_articles_is_published ON news_articles(is_published);

-- Notifications table
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Recipient
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- Message
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  type VARCHAR(50),
  action_url TEXT,
  
  -- Status
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMP,
  
  -- Channels
  via_email BOOLEAN DEFAULT false,
  via_sms BOOLEAN DEFAULT false,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);

-- Email templates table
CREATE TABLE IF NOT EXISTS email_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  name VARCHAR(100) UNIQUE NOT NULL,
  subject VARCHAR(255) NOT NULL,
  template_html TEXT NOT NULL,
  template_text TEXT,
  
  -- Variables
  variables TEXT[],
  
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Settings table
CREATE TABLE IF NOT EXISTS settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  key VARCHAR(100) UNIQUE NOT NULL,
  value TEXT,
  type VARCHAR(50),
  
  description TEXT,
  is_public BOOLEAN DEFAULT false,
  
  updated_by UUID REFERENCES users(id),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 7. AUDIT & SYSTEM
-- ============================================================================

-- Activity logs table
CREATE TABLE IF NOT EXISTS activity_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  user_id UUID NOT NULL REFERENCES users(id),
  action VARCHAR(100) NOT NULL,
  entity_type VARCHAR(100),
  entity_id UUID,
  
  -- Details
  description TEXT,
  old_value JSONB,
  new_value JSONB,
  
  -- Request Info
  ip_address VARCHAR(50),
  user_agent TEXT,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_activity_logs_user_id ON activity_logs(user_id);
CREATE INDEX idx_activity_logs_created_at ON activity_logs(created_at);
CREATE INDEX idx_activity_logs_entity_type ON activity_logs(entity_type);

-- Audit logs table
CREATE TABLE IF NOT EXISTS audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  user_id UUID REFERENCES users(id),
  table_name VARCHAR(100),
  operation VARCHAR(20),
  
  -- Data
  record_id UUID,
  old_data JSONB,
  new_data JSONB,
  
  -- Meta
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  ip_address VARCHAR(50)
);

CREATE INDEX idx_audit_logs_timestamp ON audit_logs(timestamp);

-- System logs table
CREATE TABLE IF NOT EXISTS system_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  level VARCHAR(20),
  message TEXT,
  context JSONB,
  
  stack_trace TEXT,
  source VARCHAR(255),
  
  is_resolved BOOLEAN DEFAULT false,
  resolved_at TIMESTAMP,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_system_logs_level ON system_logs(level);
CREATE INDEX idx_system_logs_created_at ON system_logs(created_at);

-- Backup records table
CREATE TABLE IF NOT EXISTS backup_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  backup_name VARCHAR(255) NOT NULL,
  backup_size_mb INT,
  backup_file_path TEXT,
  
  backup_type VARCHAR(50),
  status VARCHAR(50),
  
  started_at TIMESTAMP,
  completed_at TIMESTAMP,
  
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- TRIGGERS - AUTO UPDATE TIMESTAMPS
-- ============================================================================

CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables with updated_at
CREATE TRIGGER users_update_timestamp BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER courses_update_timestamp BEFORE UPDATE ON courses
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER classes_update_timestamp BEFORE UPDATE ON classes
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER lessons_update_timestamp BEFORE UPDATE ON lessons
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER assignments_update_timestamp BEFORE UPDATE ON assignments
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER quizzes_update_timestamp BEFORE UPDATE ON quizzes
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER flashcard_sets_update_timestamp BEFORE UPDATE ON flashcard_sets
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER student_progress_update_timestamp BEFORE UPDATE ON student_progress
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER lesson_progress_update_timestamp BEFORE UPDATE ON lesson_progress
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER registrations_update_timestamp BEFORE UPDATE ON registrations
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER payments_update_timestamp BEFORE UPDATE ON payments
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER expenses_update_timestamp BEFORE UPDATE ON expenses
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER pages_update_timestamp BEFORE UPDATE ON pages
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER news_articles_update_timestamp BEFORE UPDATE ON news_articles
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- ============================================================================
-- SEED DATA
-- ============================================================================

-- Insert default roles
INSERT INTO roles (name, description, level) VALUES
('admin', 'Quản trị viên hệ thống', 0),
('manager', 'Quản lý trung tâm', 1),
('teacher', 'Giáo viên', 2),
('student', 'Học viên', 3)
ON CONFLICT (name) DO NOTHING;

-- Insert course categories
INSERT INTO course_categories (name, description) VALUES
('Tiếng Anh', 'Khóa học tiếng Anh'),
('IELTS', 'Chuẩn bị thi IELTS'),
('TOEIC', 'Chuẩn bị thi TOEIC'),
('Tiếng Trung', 'Khóa học tiếng Trung HSK'),
('Tiếng Pháp', 'Khóa học tiếng Pháp'),
('Tiếng Nhật', 'Khóa học tiếng Nhật')
ON CONFLICT (name) DO NOTHING;

-- ============================================================================
-- VIEWS
-- ============================================================================

-- Active Students in Classes
CREATE OR REPLACE VIEW active_students AS
SELECT 
  s.id, s.user_id, u.name, s.student_id,
  c.id as class_id, c.code as class_code,
  cr.name as course_name,
  e.enrollment_date
FROM students s
JOIN users u ON s.user_id = u.id
JOIN enrollments e ON s.id = e.student_id
JOIN classes c ON e.class_id = c.id
JOIN courses cr ON c.course_id = cr.id
WHERE e.status = 'enrolled' AND c.status IN ('ongoing', 'planning');

-- Monthly Revenue
CREATE OR REPLACE VIEW monthly_revenue AS
SELECT 
  DATE_TRUNC('month', p.created_at)::date as month,
  SUM(p.amount) as total_revenue,
  COUNT(DISTINCT p.registration_id) as transactions,
  COUNT(DISTINCT r.student_id) as unique_students
FROM payments p
JOIN registrations r ON p.registration_id = r.id
WHERE p.status = 'completed'
GROUP BY DATE_TRUNC('month', p.created_at);

-- Teacher Performance
CREATE OR REPLACE VIEW teacher_performance AS
SELECT 
  t.id, t.user_id, u.name, t.teacher_id,
  COUNT(DISTINCT c.id) as total_classes,
  COUNT(DISTINCT e.student_id) as total_students,
  ROUND(AVG(t.average_rating)::numeric, 2) as avg_rating
FROM teachers t
JOIN users u ON t.user_id = u.id
LEFT JOIN classes c ON t.id = c.teacher_id
LEFT JOIN enrollments e ON c.id = e.class_id
GROUP BY t.id, t.user_id, u.name, t.teacher_id;

-- Course Statistics
CREATE OR REPLACE VIEW course_statistics AS
SELECT 
  c.id, c.name, c.code,
  COUNT(DISTINCT cl.id) as total_classes,
  COUNT(DISTINCT e.student_id) as total_students,
  COUNT(DISTINCT e.student_id) FILTER (WHERE e.status = 'completed') as completed_students,
  c.price, c.promotional_price
FROM courses c
LEFT JOIN classes cl ON c.id = cl.course_id
LEFT JOIN enrollments e ON cl.id = e.class_id
GROUP BY c.id, c.name, c.code, c.price, c.promotional_price;

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
