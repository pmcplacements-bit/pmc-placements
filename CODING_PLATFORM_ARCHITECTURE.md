# Coding Platform Architecture - LeetCode Style

## Overview
This document explains the complete architecture for supporting multiple question types including a LeetCode-style coding platform.

---

## Supported Question Types

### 1. **MCQ (Multiple Choice)** ✓ Already Implemented
- 4 options, single correct answer
- Auto-graded
- Stored in `questions` table with `options` and `correct_answer`

### 2. **True/False** 🆕
- Simple yes/no questions
- Auto-graded
- Stored with `expected_answer` = 'true' or 'false'

### 3. **Short Answer** 🆕
- Text input (1-2 lines)
- Can be auto-graded (exact match) or manually graded
- Uses `expected_answer` and `case_sensitive` flag

### 4. **Essay/Long Answer** 🆕
- Long text response
- Manually graded by teacher
- Has `max_word_count` limit
- Stored in `student_answers` table

### 5. **Fill in the Blanks** 🆕
- Text with missing words
- Auto-graded for exact matches
- Uses `expected_answer` (comma-separated for multiple blanks)

### 6. **Matching** 🆕
- Match items from two columns
- Stored as `matching_pairs` JSON
- Example: `[{"left": "Python", "right": "Programming Language"}]`

### 7. **Coding Questions** 🆕 (LeetCode Style)
- Write and execute code
- Multiple language support
- Test cases (sample + hidden)
- Auto-graded based on test results

---

## Database Architecture

### Modified Tables

#### `questions` Table - Enhanced
```sql
- type: 'mcq' | 'true_false' | 'short_answer' | 'essay' | 'fill_blank' | 'matching' | 'coding'
- points: INTEGER (default 10)

-- For Coding Questions:
- language_support: TEXT[] -- ['python', 'java', 'cpp']
- time_limit: INTEGER -- milliseconds (default 2000)
- memory_limit: INTEGER -- MB (default 256)
- input_format: TEXT -- Problem input description
- output_format: TEXT -- Expected output format
- constraints: TEXT -- Problem constraints
- template_code: JSONB -- Starter code per language
- solution_code: JSONB -- Reference solution (hidden from students)

-- For Other Types:
- expected_answer: TEXT -- For auto-grading (true/false, short answer)
- case_sensitive: BOOLEAN -- For text matching
- max_word_count: INTEGER -- For essays
- matching_pairs: JSONB -- For matching questions
```

### New Tables

#### 1. `coding_test_cases`
Stores test cases for coding questions (both sample and hidden)

```sql
CREATE TABLE coding_test_cases (
  id UUID PRIMARY KEY,
  question_id UUID REFERENCES questions(id),
  input TEXT NOT NULL,
  expected_output TEXT NOT NULL,
  is_sample BOOLEAN DEFAULT false, -- true = shown to students
  points INTEGER DEFAULT 10,
  explanation TEXT, -- For sample cases
  test_order INTEGER DEFAULT 0,
  time_limit INTEGER, -- Optional override
  memory_limit INTEGER -- Optional override
);
```

**Example:**
```sql
INSERT INTO coding_test_cases (question_id, input, expected_output, is_sample, points, explanation)
VALUES 
  ('q-uuid', '2 3', '5', true, 5, 'Sample: 2 + 3 = 5'),
  ('q-uuid', '1000000 2000000', '3000000', false, 5, 'Large numbers test');
```

#### 2. `code_submissions`
Tracks every code submission by students

```sql
CREATE TABLE code_submissions (
  id UUID PRIMARY KEY,
  student_id UUID REFERENCES users(id),
  question_id UUID REFERENCES questions(id),
  exam_id UUID REFERENCES exams(id),
  code TEXT NOT NULL,
  language TEXT NOT NULL, -- 'python', 'java', 'cpp', 'javascript'
  submission_time TIMESTAMPTZ DEFAULT NOW(),
  status TEXT, -- 'accepted', 'wrong_answer', 'tle', 'mle', 'runtime_error', 'compilation_error'
  test_cases_passed INTEGER,
  total_test_cases INTEGER,
  execution_time INTEGER, -- milliseconds
  memory_used INTEGER, -- KB
  score DECIMAL(5,2),
  error_message TEXT,
  test_results JSONB, -- Detailed per-test results
  is_final_submission BOOLEAN DEFAULT false
);
```

**Example test_results JSON:**
```json
[
  {
    "test_id": "uuid-1",
    "passed": true,
    "time": 145,
    "memory": 2048,
    "output": "5",
    "error": null
  },
  {
    "test_id": "uuid-2",
    "passed": false,
    "time": 2500,
    "memory": 3072,
    "output": "",
    "error": "Time Limit Exceeded"
  }
]
```

#### 3. `student_answers`
For non-MCQ, non-coding questions (short answer, essay, etc.)

```sql
CREATE TABLE student_answers (
  id UUID PRIMARY KEY,
  student_id UUID REFERENCES users(id),
  exam_id UUID REFERENCES exams(id),
  question_id UUID REFERENCES questions(id),
  answer_text TEXT, -- For text-based answers
  answer_json JSONB, -- For matching questions
  submitted_at TIMESTAMPTZ DEFAULT NOW(),
  score DECIMAL(5,2), -- null = not graded yet
  max_score DECIMAL(5,2) DEFAULT 10,
  graded_by UUID REFERENCES users(id),
  graded_at TIMESTAMPTZ,
  feedback TEXT,
  auto_graded BOOLEAN DEFAULT false,
  UNIQUE(student_id, exam_id, question_id)
);
```

---

## Coding Platform Features

### 1. **Multi-Language Support**
Supported languages:
- **Python** (3.8+)
- **Java** (JDK 11+)
- **C++** (g++ 11)
- **JavaScript** (Node.js)
- **C** (gcc)
- **Go** (optional)

### 2. **Code Editor**
- Syntax highlighting using CodeMirror or Monaco Editor
- Auto-completion
- Multiple themes (light/dark)
- Font size adjustment
- Line numbers
- Bracket matching

### 3. **Test Case Execution**
- **Sample Test Cases**: Visible to students with explanations
- **Hidden Test Cases**: Used for final grading
- Real-time execution feedback
- Time and memory tracking per test case

### 4. **Submission Flow**
1. Student writes code in editor
2. Student clicks "Run Code" → Executes against sample test cases only
3. Student clicks "Submit" → Executes against all test cases (sample + hidden)
4. System records submission with detailed results
5. Student can submit multiple times (last submission or best submission counts)

### 5. **Execution Statuses**
- ✅ **Accepted**: All test cases passed
- ❌ **Wrong Answer**: Incorrect output
- ⏱️ **Time Limit Exceeded**: Execution took too long
- 💾 **Memory Limit Exceeded**: Used too much memory
- 🔥 **Runtime Error**: Code crashed during execution
- 🛠️ **Compilation Error**: Code didn't compile

### 6. **Security Considerations**
⚠️ **IMPORTANT**: Code execution must be sandboxed!

Options:
- **Judge0 API** (Recommended) - External service, secure
- **Piston API** - Open-source code execution engine
- **Docker Containers** - Isolated execution environment
- **AWS Lambda / Cloud Functions** - Serverless execution

---

## Implementation Architecture

### Backend (Flask) Routes

```python
# Execute code (run/submit)
@app.route('/api/execute_code', methods=['POST'])
def execute_code():
    # Receives: code, language, question_id, test_type ('sample' or 'all')
    # Returns: execution results, test case status
    pass

# Get code submissions history
@app.route('/api/submissions/<question_id>')
def get_submissions(question_id):
    # Returns: list of all submissions for this question
    pass

# Get test cases (only samples for students)
@app.route('/api/test_cases/<question_id>')
def get_test_cases(question_id):
    # Returns: only sample test cases for students
    pass

# Mark submission as final
@app.route('/api/mark_final/<submission_id>', methods=['POST'])
def mark_final_submission(submission_id):
    pass
```

### Frontend Components

#### 1. **Coding Question Interface** (coding_question.html)
- Split view: Problem statement (left) + Code editor (right)
- Language selector dropdown
- "Run Code" button (sample tests only)
- "Submit" button (all tests)
- Test cases panel (collapsible)
- Submission history panel

#### 2. **Code Editor Integration**
```html
<!-- Using Monaco Editor (VS Code editor) -->
<div id="monaco-editor" style="height: 500px;"></div>

<script src="https://cdn.jsdelivr.net/npm/monaco-editor/min/vs/loader.js"></script>
<script>
  require.config({ paths: { vs: 'https://cdn.jsdelivr.net/npm/monaco-editor/min/vs' }});
  require(['vs/editor/editor.main'], function() {
    var editor = monaco.editor.create(document.getElementById('monaco-editor'), {
      value: templateCode,
      language: 'python',
      theme: 'vs-dark',
      automaticLayout: true
    });
  });
</script>
```

#### 3. **Test Results Display**
```html
<div class="test-results">
  <div class="test-case passed">
    <span class="icon">✅</span>
    <span>Test Case 1: Passed</span>
    <span class="time">145ms</span>
    <span class="memory">2.1MB</span>
  </div>
  <div class="test-case failed">
    <span class="icon">❌</span>
    <span>Test Case 2: Wrong Answer</span>
    <div class="details">
      <p>Expected: 10</p>
      <p>Got: 11</p>
    </div>
  </div>
</div>
```

---

## Code Execution Options

### Option 1: Judge0 API (Recommended)
```python
import requests

def execute_code_judge0(code, language, test_cases):
    JUDGE0_API = "https://judge0-ce.p.rapidapi.com/submissions"
    headers = {
        "X-RapidAPI-Key": "YOUR_KEY",
        "X-RapidAPI-Host": "judge0-ce.p.rapidapi.com"
    }
    
    results = []
    for test in test_cases:
        payload = {
            "source_code": code,
            "language_id": get_language_id(language),
            "stdin": test['input'],
            "expected_output": test['expected_output']
        }
        
        response = requests.post(JUDGE0_API, json=payload, headers=headers)
        token = response.json()['token']
        
        # Poll for result
        result = get_submission_result(token)
        results.append(result)
    
    return results
```

### Option 2: Piston API (Open Source)
```python
def execute_code_piston(code, language, stdin):
    PISTON_API = "https://emkc.org/api/v2/piston/execute"
    
    payload = {
        "language": language,
        "version": "*",
        "files": [{"content": code}],
        "stdin": stdin
    }
    
    response = requests.post(PISTON_API, json=payload)
    return response.json()
```

### Option 3: Docker (Self-Hosted)
```python
import docker

def execute_code_docker(code, language, stdin):
    client = docker.from_env()
    
    # Run code in isolated container
    container = client.containers.run(
        image=f"language-executor-{language}",
        command=f"python /code/solution.py",
        stdin_open=True,
        detach=True,
        mem_limit="256m",
        cpu_period=100000,
        cpu_quota=50000,  # 50% CPU
        network_disabled=True  # Security
    )
    
    # Get output
    result = container.wait(timeout=5)
    output = container.logs()
    container.remove()
    
    return output.decode('utf-8')
```

---

## Grading Logic

### Auto-Grading for Coding Questions
```python
def grade_coding_submission(submission_id):
    submission = get_submission(submission_id)
    question = get_question(submission.question_id)
    test_cases = get_test_cases(question.id)
    
    total_points = question.points
    passed_points = 0
    
    for test in test_cases:
        result = execute_test_case(submission.code, submission.language, test)
        
        if result.status == 'accepted':
            passed_points += test.points
    
    score = (passed_points / total_points) * question.points
    
    update_submission(submission_id, {
        'score': score,
        'test_cases_passed': count_passed,
        'total_test_cases': len(test_cases)
    })
    
    return score
```

---

## Next Steps

1. ✅ **Run SQL Script**: Execute `update_questions_schema.sql` in Supabase
2. **Choose Execution Engine**: Judge0, Piston, or Docker
3. **Update create_exam.html**: Add UI for all question types
4. **Create Coding Interface**: Build the code editor page
5. **Implement Backend**: Add Flask routes for code execution
6. **Testing**: Test with sample coding problems

---

## Example: Complete Coding Question

```sql
-- Create a coding question
INSERT INTO questions (
  exam_id, question_text, type, language_support,
  time_limit, memory_limit, points,
  input_format, output_format, constraints, template_code
) VALUES (
  'exam-uuid',
  'Given an array of integers, return the sum of all even numbers.',
  'coding',
  ARRAY['python', 'java', 'cpp'],
  2000,
  256,
  15,
  'First line: integer n (size of array)\nSecond line: n space-separated integers',
  'Single integer: sum of even numbers',
  '1 <= n <= 10^5, -10^9 <= arr[i] <= 10^9',
  '{
    "python": "def sum_evens(arr):\n    # Write your code here\n    pass\n\n# Read input\nn = int(input())\narr = list(map(int, input().split()))\nprint(sum_evens(arr))",
    "java": "import java.util.*;\n\nclass Solution {\n    public static int sumEvens(int[] arr) {\n        // Write your code here\n        return 0;\n    }\n    \n    public static void main(String[] args) {\n        Scanner sc = new Scanner(System.in);\n        int n = sc.nextInt();\n        int[] arr = new int[n];\n        for(int i=0; i<n; i++) arr[i] = sc.nextInt();\n        System.out.println(sumEvens(arr));\n    }\n}"
  }'::jsonb
);

-- Add test cases
INSERT INTO coding_test_cases (question_id, input, expected_output, is_sample, points, explanation) VALUES
  ('question-uuid', '5\n1 2 3 4 5', '6', true, 5, 'Sample: 2 + 4 = 6'),
  ('question-uuid', '4\n2 4 6 8', '20', false, 5, 'All even numbers'),
  ('question-uuid', '3\n1 3 5', '0', false, 5, 'No even numbers');
```

---

## Security Checklist

- [ ] Sandbox all code execution
- [ ] Set CPU time limits
- [ ] Set memory limits
- [ ] Disable network access during execution
- [ ] Validate all inputs
- [ ] Prevent infinite loops (timeout)
- [ ] Prevent file system access
- [ ] Use separate execution environment per submission
- [ ] Rate limit submissions (max 5 per minute)
- [ ] Log all code executions for audit

---

**Ready to implement!** Run the SQL script first, then we'll update the create_exam page to support all question types.
