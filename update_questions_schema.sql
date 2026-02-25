-- ========================================
-- Update Questions Schema for Multiple Question Types
-- Including LeetCode-style Coding Platform
-- ========================================

-- 1. Modify questions table to support multiple question types
ALTER TABLE questions 
  ADD COLUMN IF NOT EXISTS language_support TEXT[], -- ['python', 'java', 'cpp', 'javascript']
  ADD COLUMN IF NOT EXISTS time_limit INTEGER DEFAULT 2000, -- milliseconds
  ADD COLUMN IF NOT EXISTS memory_limit INTEGER DEFAULT 256, -- MB
  ADD COLUMN IF NOT EXISTS input_format TEXT, -- Description of input format
  ADD COLUMN IF NOT EXISTS output_format TEXT, -- Description of output format
  ADD COLUMN IF NOT EXISTS constraints TEXT, -- Problem constraints
  ADD COLUMN IF NOT EXISTS template_code JSONB, -- Starter code: {"python": "def solve():\n    pass", "java": "class Solution {...}"}
  ADD COLUMN IF NOT EXISTS solution_code JSONB, -- Reference solution for each language
  ADD COLUMN IF NOT EXISTS points INTEGER DEFAULT 10, -- Points for this question
  ADD COLUMN IF NOT EXISTS max_word_count INTEGER, -- For essay questions
  ADD COLUMN IF NOT EXISTS case_sensitive BOOLEAN DEFAULT false, -- For short answer/fill blanks
  ADD COLUMN IF NOT EXISTS matching_pairs JSONB, -- For matching type: [{"left": "A", "right": "1"}]
  ADD COLUMN IF NOT EXISTS expected_answer TEXT; -- For short answer, true/false, fill blank

-- Update type column to remove constraint (if exists) and allow all types
-- Valid types: 'mcq', 'true_false', 'short_answer', 'essay', 'fill_blank', 'matching', 'coding'
ALTER TABLE questions 
  DROP CONSTRAINT IF EXISTS questions_type_check;

ALTER TABLE questions 
  ADD CONSTRAINT questions_type_check 
  CHECK (type IN ('mcq', 'true_false', 'short_answer', 'essay', 'fill_blank', 'matching', 'coding'));

-- 2. Create coding_test_cases table for coding questions
CREATE TABLE IF NOT EXISTS coding_test_cases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  input TEXT NOT NULL, -- Test case input
  expected_output TEXT NOT NULL, -- Expected output
  is_sample BOOLEAN DEFAULT false, -- true = shown to students, false = hidden
  points INTEGER DEFAULT 10, -- Weight/points for this test case
  explanation TEXT, -- Explanation for sample test cases (shown to students)
  test_order INTEGER DEFAULT 0, -- Order of test execution
  time_limit INTEGER, -- Override question time limit (optional)
  memory_limit INTEGER, -- Override question memory limit (optional)
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_test_cases_question ON coding_test_cases(question_id);
CREATE INDEX idx_test_cases_sample ON coding_test_cases(is_sample);

-- 3. Create code_submissions table to track student code submissions
CREATE TABLE IF NOT EXISTS code_submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  exam_id UUID REFERENCES exams(id) ON DELETE CASCADE,
  code TEXT NOT NULL, -- Student's submitted code
  language TEXT NOT NULL, -- 'python', 'java', 'cpp', 'javascript', 'c', 'go'
  submission_time TIMESTAMPTZ DEFAULT NOW(),
  status TEXT DEFAULT 'pending', -- pending, running, accepted, wrong_answer, tle, mle, runtime_error, compilation_error
  test_cases_passed INTEGER DEFAULT 0,
  total_test_cases INTEGER DEFAULT 0,
  execution_time INTEGER, -- Total execution time in milliseconds
  memory_used INTEGER, -- Peak memory usage in KB
  score DECIMAL(5,2) DEFAULT 0, -- Score earned (out of total points)
  error_message TEXT, -- Compilation errors or runtime errors
  test_results JSONB, -- Detailed results: [{"test_id": "uuid", "passed": true, "time": 100, "memory": 1024, "output": "...", "error": null}]
  is_final_submission BOOLEAN DEFAULT false, -- Mark as final submission for grading
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_submissions_student ON code_submissions(student_id);
CREATE INDEX idx_submissions_exam ON code_submissions(exam_id);
CREATE INDEX idx_submissions_question ON code_submissions(question_id);
CREATE INDEX idx_submissions_status ON code_submissions(status);
CREATE INDEX idx_submissions_final ON code_submissions(is_final_submission);

-- 4. Create student_answers table for non-MCQ questions (short answer, essay, fill blank, matching, true/false)
CREATE TABLE IF NOT EXISTS student_answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  exam_id UUID NOT NULL REFERENCES exams(id) ON DELETE CASCADE,
  question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  answer_text TEXT, -- For short answer, essay, fill blanks, true/false
  answer_json JSONB, -- For matching, multiple answers: {"pairs": [{"left": "A", "right": "2"}]}
  submitted_at TIMESTAMPTZ DEFAULT NOW(),
  score DECIMAL(5,2), -- Score after grading (null = not graded yet)
  max_score DECIMAL(5,2) DEFAULT 10, -- Maximum possible score
  graded_by UUID REFERENCES users(id), -- Admin/teacher who graded
  graded_at TIMESTAMPTZ,
  feedback TEXT, -- Teacher's feedback on the answer
  auto_graded BOOLEAN DEFAULT false, -- true if auto-graded (for true/false, exact match short answer)
  UNIQUE(student_id, exam_id, question_id)
);

CREATE INDEX idx_student_answers_exam ON student_answers(exam_id);
CREATE INDEX idx_student_answers_student ON student_answers(student_id);
CREATE INDEX idx_student_answers_question ON student_answers(question_id);
CREATE INDEX idx_student_answers_grading ON student_answers(graded_by);
CREATE INDEX idx_student_answers_pending ON student_answers(score) WHERE score IS NULL;

-- 5. Add RLS policies for new tables

-- Policies for coding_test_cases
ALTER TABLE coding_test_cases ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public to view sample test cases"
  ON coding_test_cases FOR SELECT
  USING (is_sample = true);

CREATE POLICY "Allow authenticated users to view all test cases during grading"
  ON coding_test_cases FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Allow admin to manage test cases"
  ON coding_test_cases FOR ALL
  USING (auth.role() = 'authenticated');

-- Policies for code_submissions
ALTER TABLE code_submissions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Students can view their own submissions"
  ON code_submissions FOR SELECT
  USING (auth.uid() = student_id);

CREATE POLICY "Students can insert their own submissions"
  ON code_submissions FOR INSERT
  WITH CHECK (auth.uid() = student_id);

CREATE POLICY "Students can update their own submissions"
  ON code_submissions FOR UPDATE
  USING (auth.uid() = student_id);

CREATE POLICY "Admins can view all submissions"
  ON code_submissions FOR SELECT
  USING (auth.role() = 'authenticated');

-- Policies for student_answers
ALTER TABLE student_answers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Students can view their own answers"
  ON student_answers FOR SELECT
  USING (auth.uid() = student_id);

CREATE POLICY "Students can insert their own answers"
  ON student_answers FOR INSERT
  WITH CHECK (auth.uid() = student_id);

CREATE POLICY "Students can update their own ungraded answers"
  ON student_answers FOR UPDATE
  USING (auth.uid() = student_id AND score IS NULL);

CREATE POLICY "Admins can view all answers"
  ON student_answers FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Admins can update all answers for grading"
  ON student_answers FOR UPDATE
  USING (auth.role() = 'authenticated');

-- 6. Create functions for auto-grading

-- Function to auto-grade true/false and exact match short answers
CREATE OR REPLACE FUNCTION auto_grade_answer()
RETURNS TRIGGER AS $$
DECLARE
  question_record RECORD;
  calculated_score DECIMAL(5,2);
BEGIN
  -- Get question details
  SELECT type, expected_answer, case_sensitive, points
  INTO question_record
  FROM questions
  WHERE id = NEW.question_id;

  -- Auto-grade true/false
  IF question_record.type = 'true_false' THEN
    IF LOWER(TRIM(NEW.answer_text)) = LOWER(TRIM(question_record.expected_answer)) THEN
      calculated_score := question_record.points;
    ELSE
      calculated_score := 0;
    END IF;
    
    NEW.score := calculated_score;
    NEW.max_score := question_record.points;
    NEW.auto_graded := true;
    NEW.graded_at := NOW();
  END IF;

  -- Auto-grade short answer with exact match
  IF question_record.type = 'short_answer' AND question_record.expected_answer IS NOT NULL THEN
    IF question_record.case_sensitive THEN
      IF TRIM(NEW.answer_text) = TRIM(question_record.expected_answer) THEN
        calculated_score := question_record.points;
      ELSE
        calculated_score := 0;
      END IF;
    ELSE
      IF LOWER(TRIM(NEW.answer_text)) = LOWER(TRIM(question_record.expected_answer)) THEN
        calculated_score := question_record.points;
      ELSE
        calculated_score := 0;
      END IF;
    END IF;
    
    NEW.score := calculated_score;
    NEW.max_score := question_record.points;
    NEW.auto_graded := true;
    NEW.graded_at := NOW();
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for auto-grading
CREATE TRIGGER trigger_auto_grade_answer
  BEFORE INSERT OR UPDATE ON student_answers
  FOR EACH ROW
  EXECUTE FUNCTION auto_grade_answer();

-- 7. Create view for exam results summary
CREATE OR REPLACE VIEW exam_results_summary AS
SELECT 
  e.id as exam_id,
  e.title as exam_title,
  u.id as student_id,
  u.username,
  u.email,
  COALESCE(SUM(CASE 
    WHEN q.type = 'mcq' THEN 
      CASE WHEN r.selected_answer = q.correct_answer THEN q.points ELSE 0 END
    WHEN q.type = 'coding' THEN cs.score
    ELSE sa.score
  END), 0) as total_score,
  COALESCE(SUM(q.points), 0) as max_score,
  ROUND(COALESCE(SUM(CASE 
    WHEN q.type = 'mcq' THEN 
      CASE WHEN r.selected_answer = q.correct_answer THEN q.points ELSE 0 END
    WHEN q.type = 'coding' THEN cs.score
    ELSE sa.score
  END), 0) * 100.0 / NULLIF(SUM(q.points), 0), 2) as percentage,
  COUNT(DISTINCT q.id) as total_questions,
  COUNT(DISTINCT CASE 
    WHEN q.type = 'mcq' AND r.selected_answer = q.correct_answer THEN q.id
    WHEN q.type = 'coding' AND cs.status = 'accepted' THEN q.id
    WHEN sa.score = sa.max_score THEN q.id
  END) as correct_answers
FROM exams e
CROSS JOIN users u
LEFT JOIN questions q ON q.exam_id = e.id
LEFT JOIN results r ON r.exam_id = e.id AND r.student_id = u.id AND r.question_id = q.id
LEFT JOIN code_submissions cs ON cs.exam_id = e.id AND cs.student_id = u.id AND cs.question_id = q.id AND cs.is_final_submission = true
LEFT JOIN student_answers sa ON sa.exam_id = e.id AND sa.student_id = u.id AND sa.question_id = q.id
WHERE u.role = 'student'
GROUP BY e.id, e.title, u.id, u.username, u.email;

-- 8. Sample data for testing different question types

-- Example: True/False Question
INSERT INTO questions (exam_id, question_text, type, expected_answer, points)
VALUES (
  'YOUR_EXAM_ID', -- Replace with actual exam ID
  'Python is a compiled programming language.',
  'true_false',
  'false',
  5
);

-- Example: Short Answer Question
INSERT INTO questions (exam_id, question_text, type, expected_answer, case_sensitive, points)
VALUES (
  'YOUR_EXAM_ID',
  'What is the capital of France?',
  'short_answer',
  'Paris',
  false,
  5
);

-- Example: Essay Question
INSERT INTO questions (exam_id, question_text, type, max_word_count, points)
VALUES (
  'YOUR_EXAM_ID',
  'Explain the concept of Object-Oriented Programming with examples.',
  'essay',
  500,
  20
);

-- Example: Coding Question
INSERT INTO questions (
  exam_id, question_text, type, language_support, 
  time_limit, memory_limit, input_format, output_format, 
  constraints, template_code, points
)
VALUES (
  'YOUR_EXAM_ID',
  'Write a function to find the sum of two numbers.',
  'coding',
  ARRAY['python', 'java', 'cpp'],
  2000,
  256,
  'Two integers a and b (1 <= a, b <= 10^9)',
  'Single integer representing the sum',
  '1 <= a, b <= 10^9',
  '{
    "python": "def add_numbers(a, b):\n    # Write your code here\n    pass",
    "java": "class Solution {\n    public int addNumbers(int a, int b) {\n        // Write your code here\n        return 0;\n    }\n}",
    "cpp": "class Solution {\npublic:\n    int addNumbers(int a, int b) {\n        // Write your code here\n        return 0;\n    }\n};"
  }'::jsonb,
  10
);

-- Add test cases for the coding question
INSERT INTO coding_test_cases (question_id, input, expected_output, is_sample, points, explanation)
VALUES 
  ('CODING_QUESTION_ID', '2 3', '5', true, 5, 'Sample test: 2 + 3 = 5'),
  ('CODING_QUESTION_ID', '100 200', '300', false, 5, 'Hidden test case');

-- ========================================
-- COMPLETED: Run this script in Supabase SQL Editor
-- ========================================
