# DATABASE SCHEMA - LCMS

## 📊 Tổng Quan

Hệ thống LCMS sử dụng **PostgreSQL** với **35 bảng** được chia thành 7 nhóm chính:

```
┌─────────────────────────────────────────────────────────────┐
│         DATABASE SCHEMA - THẢO NGUYÊN LCMS                  │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1️⃣  AUTHENTICATION & USERS (6 bảng)                       │
│     └─ users, roles, permissions, user_roles               │
│                                                              │
│  2️⃣  COURSES & CLASSES (8 bảng)                            │
│     └─ courses, classes, class_schedules, enrollments       │
│                                                              │
│  3️⃣  LEARNING CONTENT (10 bảng)                            │
│     └─ lessons, assignments, quizzes, flashcards           │
│                                                              │
│  4️⃣  PROGRESS & SCORING (6 bảng)                           │
│     └─ student_progress, scores, quiz_responses            │
│                                                              │
│  5️⃣  PAYMENTS & FINANCIAL (8 bảng)                         │
│     └─ registrations, payments, invoices, expenses          │
│                                                              │
│  6️⃣  CMS & NOTIFICATIONS (5 bảng)                          │
│     └─ pages, news, notifications, settings                │
│                                                              │
│  7️⃣  AUDIT & SYSTEM (4 bảng)                               │
│     └─ activity_logs, audit_logs, system_logs              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 1️⃣ AUTHENTICATION & USERS

### Bảng: `users`
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  avatar_url TEXT,
  role VARCHAR(50) NOT NULL DEFAULT 'student',
  -- student | teacher | manager | admin
  
  -- Personal Info
  date_of_birth DATE,
  gender VARCHAR(10), -- male | female | other
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
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  last_login_at TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_is_active ON users(is_active);
```

### Bảng: `roles`
```sql
CREATE TABLE roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(50) UNIQUE NOT NULL,
  description TEXT,
  level INT DEFAULT 0, -- 0=admin, 1=manager, 2=teacher, 3=student
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO roles (name, description, level) VALUES
('admin', 'Quản trị viên hệ thống', 0),
('manager', 'Quản lý trung tâm', 1),
('teacher', 'Giáo viên', 2),
('student', 'Học viên', 3);
```

### Bảng: `permissions`
```sql
CREATE TABLE permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) UNIQUE NOT NULL,
  description TEXT,
  module VARCHAR(50), -- auth, courses, students, payments, etc
  action VARCHAR(50), -- create, read, update, delete
  created_at TIMESTAMP DEFAULT NOW()
);

-- Examples:
-- courses.create, courses.read, courses.update, courses.delete
-- students.view, students.edit, payments.approve
```

### Bảng: `user_roles`
```sql
CREATE TABLE user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
  assigned_at TIMESTAMP DEFAULT NOW(),
  assigned_by UUID REFERENCES users(id),
  
  UNIQUE(user_id, role_id)
);

CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);
```

### Bảng: `students`
```sql
CREATE TABLE students (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  student_id VARCHAR(50) UNIQUE,
  current_level VARCHAR(10), -- A1, A2, B1, B2, C1, C2
  
  -- Learning Progress
  total_courses INT DEFAULT 0,
  completed_courses INT DEFAULT 0,
  in_progress_courses INT DEFAULT 1,
  
  -- Academic Info
  date_enrolled DATE DEFAULT CURRENT_DATE,
  preferred_time VARCHAR(50), -- sáng, chiều, tối
  learning_goals TEXT,
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_students_user_id ON students(user_id);
CREATE INDEX idx_students_student_id ON students(student_id);
```

### Bảng: `teachers`
```sql
CREATE TABLE teachers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  teacher_id VARCHAR(50) UNIQUE,
  
  -- Professional Info
  qualifications TEXT[], -- Array of qualifications
  specialties TEXT[], -- Subjects they teach
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
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_teachers_user_id ON teachers(user_id);
CREATE INDEX idx_teachers_teacher_id ON teachers(teacher_id);
```

---

## 2️⃣ COURSES & CLASSES

### Bảng: `courses`
```sql
CREATE TABLE courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  code VARCHAR(50) UNIQUE NOT NULL,
  description TEXT,
  slug VARCHAR(255) UNIQUE,
  
  -- Course Details
  level VARCHAR(10), -- A1, A2, B1, B2, C1, C2
  language VARCHAR(50), -- English, Chinese, etc
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
  learning_outcomes TEXT[], -- Array of outcomes
  requirements TEXT[], -- Prerequisites
  
  -- Status
  is_active BOOLEAN DEFAULT true,
  is_featured BOOLEAN DEFAULT false,
  status VARCHAR(50) DEFAULT 'planning', -- planning, recruiting, ongoing, completed
  
  -- Metadata
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_courses_code ON courses(code);
CREATE INDEX idx_courses_level ON courses(level);
CREATE INDEX idx_courses_is_active ON courses(is_active);
```

### Bảng: `classes`
```sql
CREATE TABLE classes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  code VARCHAR(50) UNIQUE NOT NULL,
  
  -- Teacher & Room
  teacher_id UUID NOT NULL REFERENCES teachers(id),
  room VARCHAR(100),
  online_link TEXT, -- Zoom, Google Meet, etc
  
  -- Schedule
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  
  -- Capacity
  max_students INT,
  current_students INT DEFAULT 0,
  
  -- Status
  status VARCHAR(50) DEFAULT 'planning', -- planning, ongoing, completed, cancelled
  
  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_classes_course_id ON classes(course_id);
CREATE INDEX idx_classes_teacher_id ON classes(teacher_id);
CREATE INDEX idx_classes_code ON classes(code);
CREATE INDEX idx_classes_status ON classes(status);
```

### Bảng: `class_schedules`
```sql
CREATE TABLE class_schedules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  
  -- Schedule Details
  day_of_week VARCHAR(20), -- Monday, Tuesday, etc
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  
  -- Session Info
  room VARCHAR(100),
  online_link TEXT,
  is_online BOOLEAN DEFAULT false,
  
  -- Status
  is_active BOOLEAN DEFAULT true,
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_class_schedules_class_id ON class_schedules(class_id);
```

### Bảng: `enrollments`
```sql
CREATE TABLE enrollments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  
  -- Status
  status VARCHAR(50) DEFAULT 'enrolled', -- enrolled, dropped, completed, transferred
  enrollment_date DATE DEFAULT CURRENT_DATE,
  completion_date DATE,
  
  -- Progress
  attendance_rate DECIMAL(5,2) DEFAULT 0,
  final_score DECIMAL(5,2),
  
  UNIQUE(student_id, class_id)
);

CREATE INDEX idx_enrollments_student_id ON enrollments(student_id);
CREATE INDEX idx_enrollments_class_id ON enrollments(class_id);
```

### Bảng: `course_categories`
```sql
CREATE TABLE course_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  icon_url TEXT,
  
  created_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO course_categories (name, description) VALUES
('Tiếng Anh', 'Khóa học tiếng Anh'),
('IELTS', 'Chuẩn bị thi IELTS'),
('TOEIC', 'Chuẩn bị thi TOEIC'),
('Tiếng Trung', 'Khóa học tiếng Trung HSK');
```

---

## 3️⃣ LEARNING CONTENT

### Bảng: `lessons`
```sql
CREATE TABLE lessons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  
  -- Content
  content TEXT, -- Rich HTML content
  order_index INT NOT NULL,
  
  -- Media
  thumbnail_url TEXT,
  video_url TEXT,
  video_duration INT, -- seconds
  
  -- Access Control
  is_published BOOLEAN DEFAULT false,
  is_free BOOLEAN DEFAULT false,
  
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_lessons_course_id ON lessons(course_id);
CREATE INDEX idx_lessons_is_published ON lessons(is_published);
```

### Bảng: `lesson_materials`
```sql
CREATE TABLE lesson_materials (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  
  title VARCHAR(255) NOT NULL,
  type VARCHAR(50), -- pdf, doc, image, audio, etc
  file_url TEXT,
  file_size INT, -- bytes
  
  order_index INT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_lesson_materials_lesson_id ON lesson_materials(lesson_id);
```

### Bảng: `assignments`
```sql
CREATE TABLE assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  
  title VARCHAR(255) NOT NULL,
  description TEXT,
  type VARCHAR(50), -- essay, quiz, exercise, project
  
  -- Due Date & Submission
  due_date DATE,
  allow_late_submission BOOLEAN DEFAULT false,
  late_submission_days INT DEFAULT 0,
  
  -- Grading
  total_points INT DEFAULT 100,
  passing_score INT DEFAULT 60,
  
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_assignments_lesson_id ON assignments(lesson_id);
```

### Bảng: `assignment_submissions`
```sql
CREATE TABLE assignment_submissions (
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
  graded_by UUID REFERENCES users(id),
  
  status VARCHAR(50) DEFAULT 'draft', -- draft, submitted, graded, resubmitted
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_assignment_submissions_assignment_id ON assignment_submissions(assignment_id);
CREATE INDEX idx_assignment_submissions_student_id ON assignment_submissions(student_id);
```

### Bảng: `quizzes`
```sql
CREATE TABLE quizzes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  
  title VARCHAR(255) NOT NULL,
  description TEXT,
  
  -- Quiz Settings
  total_questions INT,
  passing_score INT DEFAULT 60,
  time_limit_minutes INT, -- NULL = no limit
  allow_retake BOOLEAN DEFAULT false,
  max_attempts INT DEFAULT 1,
  
  -- Randomization
  randomize_questions BOOLEAN DEFAULT false,
  randomize_options BOOLEAN DEFAULT false,
  
  is_published BOOLEAN DEFAULT false,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_quizzes_lesson_id ON quizzes(lesson_id);
```

### Bảng: `quiz_questions`
```sql
CREATE TABLE quiz_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
  
  question_text TEXT NOT NULL,
  question_type VARCHAR(50), -- multiple_choice, true_false, short_answer, essay
  
  -- Options (for multiple choice)
  options JSONB, -- {"A": "option 1", "B": "option 2", ...}
  correct_answer VARCHAR(50), -- for auto-grading
  explanation TEXT,
  
  points INT DEFAULT 1,
  order_index INT,
  
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_quiz_questions_quiz_id ON quiz_questions(quiz_id);
```

### Bảng: `quiz_responses`
```sql
CREATE TABLE quiz_responses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  
  -- Attempt
  attempt_number INT DEFAULT 1,
  started_at TIMESTAMP DEFAULT NOW(),
  submitted_at TIMESTAMP,
  
  -- Responses (JSONB to store Q&A pairs)
  responses JSONB,
  
  -- Results
  total_score INT,
  max_score INT,
  percentage DECIMAL(5,2),
  status VARCHAR(50) DEFAULT 'in_progress', -- in_progress, submitted, graded
  
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_quiz_responses_quiz_id ON quiz_responses(quiz_id);
CREATE INDEX idx_quiz_responses_student_id ON quiz_responses(student_id);
```

### Bảng: `flashcard_sets`
```sql
CREATE TABLE flashcard_sets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
  lesson_id UUID REFERENCES lessons(id) ON DELETE CASCADE,
  
  title VARCHAR(255) NOT NULL,
  description TEXT,
  
  total_cards INT DEFAULT 0,
  difficulty_level VARCHAR(20), -- beginner, intermediate, advanced
  
  is_public BOOLEAN DEFAULT false,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_flashcard_sets_course_id ON flashcard_sets(course_id);
CREATE INDEX idx_flashcard_sets_lesson_id ON flashcard_sets(lesson_id);
```

### Bảng: `flashcards`
```sql
CREATE TABLE flashcards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  flashcard_set_id UUID NOT NULL REFERENCES flashcard_sets(id) ON DELETE CASCADE,
  
  front_text TEXT NOT NULL, -- Question or term
  back_text TEXT NOT NULL, -- Answer or definition
  
  -- Media
  front_image_url TEXT,
  back_image_url TEXT,
  audio_url TEXT,
  
  order_index INT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_flashcards_flashcard_set_id ON flashcards(flashcard_set_id);
```

---

## 4️⃣ PROGRESS & SCORING

### Bảng: `student_progress`
```sql
CREATE TABLE student_progress (
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
  
  -- Current Status
  status VARCHAR(50) DEFAULT 'in_progress', -- in_progress, completed, paused, dropped
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_student_progress_student_id ON student_progress(student_id);
CREATE INDEX idx_student_progress_class_id ON student_progress(class_id);
```

### Bảng: `lesson_progress`
```sql
CREATE TABLE lesson_progress (
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
  status VARCHAR(50) DEFAULT 'not_started', -- not_started, in_progress, completed
  
  UNIQUE(student_id, lesson_id)
);

CREATE INDEX idx_lesson_progress_student_id ON lesson_progress(student_id);
```

### Bảng: `student_scores`
```sql
CREATE TABLE student_scores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  
  -- Assessment Type
  assessment_type VARCHAR(50), -- assignment, quiz, midterm, final
  assessment_id UUID,
  
  -- Score
  score DECIMAL(5,2),
  max_score INT DEFAULT 100,
  percentage DECIMAL(5,2),
  
  -- Feedback
  teacher_feedback TEXT,
  
  graded_at TIMESTAMP,
  graded_by UUID REFERENCES teachers(id),
  
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_student_scores_student_id ON student_scores(student_id);
CREATE INDEX idx_student_scores_class_id ON student_scores(class_id);
```

### Bảng: `certificates`
```sql
CREATE TABLE certificates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  
  certificate_number VARCHAR(100) UNIQUE,
  issue_date DATE DEFAULT CURRENT_DATE,
  expiry_date DATE,
  
  -- Achievement
  final_score DECIMAL(5,2),
  completion_percentage INT,
  
  certificate_url TEXT, -- PDF download
  verification_code VARCHAR(50) UNIQUE,
  
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_certificates_student_id ON certificates(student_id);
CREATE INDEX idx_certificates_course_id ON certificates(course_id);
```

---

## 5️⃣ PAYMENTS & FINANCIAL

### Bảng: `registrations`
```sql
CREATE TABLE registrations (
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
  status VARCHAR(50) DEFAULT 'pending', -- pending, confirmed, paid, rejected, cancelled
  
  -- Approval
  approved_by UUID REFERENCES users(id),
  approved_at TIMESTAMP,
  rejection_reason TEXT,
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_registrations_student_id ON registrations(student_id);
CREATE INDEX idx_registrations_status ON registrations(status);
```

### Bảng: `payments`
```sql
CREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  registration_id UUID NOT NULL REFERENCES registrations(id) ON DELETE CASCADE,
  
  -- Payment Info
  payment_number VARCHAR(50) UNIQUE,
  amount DECIMAL(10,2) NOT NULL,
  payment_method VARCHAR(50), -- cash, transfer, card, etc
  
  -- Bank Info (for transfers)
  bank_name VARCHAR(255),
  account_name VARCHAR(255),
  account_number VARCHAR(50),
  transaction_reference VARCHAR(100),
  
  -- Status
  status VARCHAR(50) DEFAULT 'pending', -- pending, completed, failed, refunded
  
  -- Confirmation
  confirmed_by UUID REFERENCES users(id),
  confirmed_at TIMESTAMP,
  confirmation_note TEXT,
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_payments_registration_id ON payments(registration_id);
CREATE INDEX idx_payments_status ON payments(status);
```

### Bảng: `invoices`
```sql
CREATE TABLE invoices (
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
  status VARCHAR(50) DEFAULT 'draft', -- draft, issued, paid, cancelled
  
  -- File
  pdf_url TEXT,
  
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_invoices_payment_id ON invoices(payment_id);
```

### Bảng: `expenses`
```sql
CREATE TABLE expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Expense Info
  expense_number VARCHAR(50) UNIQUE,
  category VARCHAR(100), -- salary, rent, utilities, etc
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
  status VARCHAR(50) DEFAULT 'pending', -- pending, approved, rejected
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_expenses_category ON expenses(category);
CREATE INDEX idx_expenses_status ON expenses(status);
```

### Bảng: `financial_reports`
```sql
CREATE TABLE financial_reports (
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
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_financial_reports_report_date ON financial_reports(report_date);
```

---

## 6️⃣ CMS & NOTIFICATIONS

### Bảng: `pages`
```sql
CREATE TABLE pages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  title VARCHAR(255) NOT NULL,
  slug VARCHAR(255) UNIQUE NOT NULL,
  content TEXT, -- Rich HTML content
  
  -- SEO
  meta_title VARCHAR(255),
  meta_description TEXT,
  meta_keywords TEXT,
  
  -- Status
  is_published BOOLEAN DEFAULT false,
  is_featured BOOLEAN DEFAULT false,
  
  author_id UUID REFERENCES users(id),
  published_at TIMESTAMP,
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_pages_slug ON pages(slug);
CREATE INDEX idx_pages_is_published ON pages(is_published);
```

### Bảng: `news_articles`
```sql
CREATE TABLE news_articles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  title VARCHAR(255) NOT NULL,
  slug VARCHAR(255) UNIQUE,
  excerpt TEXT,
  content TEXT, -- Rich HTML content
  
  thumbnail_url TEXT,
  category VARCHAR(100),
  
  is_published BOOLEAN DEFAULT false,
  is_featured BOOLEAN DEFAULT false,
  
  author_id UUID REFERENCES users(id),
  published_at TIMESTAMP,
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_news_articles_slug ON news_articles(slug);
CREATE INDEX idx_news_articles_is_published ON news_articles(is_published);
```

### Bảng: `notifications`
```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Recipient
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- Message
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  type VARCHAR(50), -- info, warning, error, success
  action_url TEXT,
  
  -- Status
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMP,
  
  -- Channels
  via_email BOOLEAN DEFAULT false,
  via_sms BOOLEAN DEFAULT false,
  
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
```

### Bảng: `email_templates`
```sql
CREATE TABLE email_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  name VARCHAR(100) UNIQUE NOT NULL,
  subject VARCHAR(255) NOT NULL,
  template_html TEXT NOT NULL,
  template_text TEXT,
  
  -- Variables
  variables TEXT[], -- [name, email, course, etc]
  
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### Bảng: `settings`
```sql
CREATE TABLE settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  key VARCHAR(100) UNIQUE NOT NULL,
  value TEXT,
  type VARCHAR(50), -- string, number, boolean, json
  
  description TEXT,
  is_public BOOLEAN DEFAULT false,
  
  updated_by UUID REFERENCES users(id),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Example settings:
-- site_name, site_url, logo_url, primary_color
-- smtp_host, smtp_port, smtp_user
-- currency, timezone, language
```

---

## 7️⃣ AUDIT & SYSTEM

### Bảng: `activity_logs`
```sql
CREATE TABLE activity_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  user_id UUID NOT NULL REFERENCES users(id),
  action VARCHAR(100) NOT NULL, -- create, update, delete, view
  entity_type VARCHAR(100), -- courses, students, payments
  entity_id UUID,
  
  -- Details
  description TEXT,
  old_value JSONB, -- Previous value
  new_value JSONB, -- New value
  
  -- Request Info
  ip_address VARCHAR(50),
  user_agent TEXT,
  
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_activity_logs_user_id ON activity_logs(user_id);
CREATE INDEX idx_activity_logs_created_at ON activity_logs(created_at);
CREATE INDEX idx_activity_logs_entity_type ON activity_logs(entity_type);
```

### Bảng: `audit_logs`
```sql
CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  user_id UUID REFERENCES users(id),
  table_name VARCHAR(100),
  operation VARCHAR(20), -- INSERT, UPDATE, DELETE
  
  -- Data
  record_id UUID,
  old_data JSONB,
  new_data JSONB,
  
  -- Meta
  timestamp TIMESTAMP DEFAULT NOW(),
  ip_address VARCHAR(50)
);

CREATE INDEX idx_audit_logs_timestamp ON audit_logs(timestamp);
```

### Bảng: `system_logs`
```sql
CREATE TABLE system_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  level VARCHAR(20), -- INFO, WARNING, ERROR, CRITICAL
  message TEXT,
  context JSONB,
  
  stack_trace TEXT,
  source VARCHAR(255),
  
  is_resolved BOOLEAN DEFAULT false,
  resolved_at TIMESTAMP,
  
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_system_logs_level ON system_logs(level);
CREATE INDEX idx_system_logs_created_at ON system_logs(created_at);
```

### Bảng: `backup_records`
```sql
CREATE TABLE backup_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  backup_name VARCHAR(255) NOT NULL,
  backup_size_mb INT,
  backup_file_path TEXT,
  
  backup_type VARCHAR(50), -- full, incremental
  status VARCHAR(50), -- success, failed, in_progress
  
  started_at TIMESTAMP,
  completed_at TIMESTAMP,
  
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW()
);
```

---

## 📋 ERD - Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                      USERS & AUTH                               │
├─────────────────────────────────────────────────────────────────┤
│  users                  1 ──> N  user_roles                      │
│  ├─ id (PK)             │       ├─ user_id (FK)                  │
│  ├─ email               └─────> ├─ role_id (FK)                  │
│  ├─ name                                                          │
│  └─ role                roles                                     │
│                         ├─ id (PK)                              │
│                         └─ name                                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                   COURSES & CLASSES                              │
├─────────────────────────────────────────────────────────────────┤
│  courses  1 ──> N  classes  1 ──> N  class_schedules            │
│  ├─ id            ├─ id            ├─ id                        │
│  ├─ name          └─ teacher_id    └─ class_id (FK)             │
│  ├─ price        (FK to teachers)                                │
│  └─ level                                                        │
│                  1 ──> N  enrollments  ──> students             │
│                         ├─ class_id (FK)                        │
│                         └─ student_id (FK)                      │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                   LEARNING CONTENT                               │
├─────────────────────────────────────────────────────────────────┤
│  lessons  1 ──> N  lesson_materials                             │
│  ├─ id            └─ file_url                                   │
│  ├─ title                                                        │
│  └─ video_url    1 ──> N  assignments ──> assignment_submissions│
│                  ├─ id                ├─ student_id (FK)        │
│  flashcard_sets  └─ title             └─ score                  │
│  ├─ id                                                           │
│  └─ title        1 ──> N  quizzes  ──> quiz_responses          │
│                          ├─ id         ├─ student_id (FK)       │
│  1 ──> N flashcards      └─ title      └─ responses             │
│         ├─ id                                                    │
│         └─ front_text    1 ──> N  quiz_questions                │
│                                  └─ question_text               │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│              PROGRESS & SCORING                                  │
├─────────────────────────────────────────────────────────────────┤
│  students  1 ──> N  student_progress                            │
│  ├─ id            ├─ class_id (FK)                             │
│  ├─ user_id (FK)  └─ completion_percentage                      │
│  └─ level                                                        │
│                  1 ──> N  lesson_progress                       │
│                           ├─ lesson_id (FK)                     │
│                           └─ is_completed                       │
│                                                                  │
│  1 ──> N  student_scores                                        │
│         ├─ class_id (FK)                                        │
│         └─ score                                                │
│                                                                  │
│  1 ──> N  certificates                                          │
│         ├─ course_id (FK)                                       │
│         └─ certificate_number                                   │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│            PAYMENTS & FINANCIAL                                  │
├─────────────────────────────────────────────────────────────────┤
│  registrations  1 ──> N  payments  ──> invoices                │
│  ├─ id               ├─ id             ├─ id                   │
│  ├─ student_id (FK)  ├─ amount         └─ amount               │
│  ├─ course_id (FK)   └─ status                                 │
│  └─ status                                                      │
│                    1 ──> N  expenses                            │
│                              ├─ id                              │
│                              ├─ amount                          │
│                              └─ category                        │
│                                                                  │
│                    1 ──> N  financial_reports                   │
│                              ├─ total_revenue                   │
│                              ├─ total_expenses                  │
│                              └─ profit_loss                     │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│              AUDIT & SYSTEM                                      │
├─────────────────────────────────────────────────────────────────┤
│  users  1 ──> N  activity_logs                                  │
│  ├─ id            ├─ action                                     │
│  └─ role          └─ timestamp                                  │
│                                                                  │
│              1 ──> N  audit_logs                                │
│                      ├─ old_data                                │
│                      └─ new_data                                │
│                                                                  │
│              1 ──> N  system_logs                               │
│                      └─ level                                   │
│                                                                  │
│              1 ──> N  backup_records                            │
│                      └─ backup_file_path                        │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔑 Primary Keys & Relationships

### Primary Keys (UUIDs)
Tất cả bảng sử dụng **UUID** làm khóa chính:
```sql
id UUID PRIMARY KEY DEFAULT gen_random_uuid()
```

### Foreign Keys Pattern
```sql
-- Standard Foreign Key
table_id UUID NOT NULL REFERENCES other_table(id) ON DELETE CASCADE

-- Optional Foreign Key
table_id UUID REFERENCES other_table(id) ON DELETE SET NULL
```

### Indexes Strategy
- ✅ Tất cả Foreign Keys có index
- ✅ Tất cả search fields có index (email, code, slug)
- ✅ Tất cả status fields có index
- ✅ Tất cả date fields có index (created_at, updated_at)

---

## 🔄 Triggers & Functions

### Auto-update `updated_at`
```sql
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables with updated_at
CREATE TRIGGER users_update_timestamp BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER courses_update_timestamp BEFORE UPDATE ON courses
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- ... repeat for other tables
```

### Update Student Statistics
```sql
CREATE OR REPLACE FUNCTION update_student_stats()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE students
  SET completed_courses = (
    SELECT COUNT(*) FROM enrollments 
    WHERE student_id = NEW.student_id AND status = 'completed'
  )
  WHERE id = NEW.student_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enrollments_update_stats AFTER UPDATE ON enrollments
FOR EACH ROW EXECUTE FUNCTION update_student_stats();
```

---

## 🛡️ Security & Constraints

### Unique Constraints
```sql
-- Email must be unique
ALTER TABLE users ADD CONSTRAINT unique_email UNIQUE(email);

-- Course code must be unique
ALTER TABLE courses ADD CONSTRAINT unique_course_code UNIQUE(code);

-- Registration must be unique per student per course
ALTER TABLE registrations ADD CONSTRAINT unique_student_course 
  UNIQUE(student_id, course_id);
```

### Check Constraints
```sql
-- Price must be positive
ALTER TABLE courses ADD CONSTRAINT check_price 
  CHECK(price > 0);

-- Score must be between 0 and 100
ALTER TABLE student_scores ADD CONSTRAINT check_score 
  CHECK(score >= 0 AND score <= 100);
```

---

## 📊 View Examples

### Useful Views

```sql
-- Active Students in Classes
CREATE VIEW active_students AS
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
WHERE e.status = 'enrolled' AND c.status = 'ongoing';

-- Monthly Revenue
CREATE VIEW monthly_revenue AS
SELECT 
  DATE_TRUNC('month', p.created_at)::date as month,
  SUM(p.amount) as total_revenue,
  COUNT(DISTINCT p.registration_id) as transactions
FROM payments p
WHERE p.status = 'completed'
GROUP BY DATE_TRUNC('month', p.created_at);

-- Teacher Performance
CREATE VIEW teacher_performance AS
SELECT 
  t.id, t.user_id, u.name,
  COUNT(DISTINCT c.id) as total_classes,
  COUNT(DISTINCT e.student_id) as total_students,
  AVG(t.average_rating) as avg_rating
FROM teachers t
JOIN users u ON t.user_id = u.id
LEFT JOIN classes c ON t.id = c.teacher_id
LEFT JOIN enrollments e ON c.id = e.class_id
GROUP BY t.id, t.user_id, u.name;
```

---

## 🚀 Migration Strategy

1. **Initial Setup**: Create all tables
2. **Indexes**: Create all indexes
3. **Triggers**: Add update_timestamp triggers
4. **Views**: Create useful views
5. **Seed Data**: Insert basic data (roles, categories, settings)
6. **Verification**: Run integrity checks

---

## 📝 Notes

- Tất cả timestamps sử dụng **UTC timezone**
- Soft deletes không được sử dụng (hard delete với cascading)
- JSONB được sử dụng cho dữ liệu flexible (quiz responses, settings)
- UUIDs được sử dụng thay vì sequential IDs (bảo mật tốt hơn)

---

**Next**: Tôi sẽ tạo SQL migration file sẵn sàng chạy trên Supabase! 🚀
