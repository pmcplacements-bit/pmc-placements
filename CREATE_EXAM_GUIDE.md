# Create Exam Page - Usage Guide

## ✅ Updated Features

The create_exam.html page now supports **7 different question types**:

### 1. Multiple Choice Questions (MCQ)
- **Fields**: Question text, 4 options, correct answer, difficulty, points, tags
- **Auto-graded**: Yes
- **Usage**: Traditional multiple choice questions

### 2. True/False Questions
- **Fields**: Question text, correct answer (true/false), points
- **Auto-graded**: Yes  
- **Usage**: Simple yes/no questions

### 3. Short Answer Questions
- **Fields**: Question text, expected answer (optional), case sensitivity, points
- **Auto-graded**: Only if expected answer is provided (exact match)
- **Manual Grading**: If no expected answer is set
- **Usage**: Brief text responses (1-2 lines)

### 4. Essay/Long Answer Questions
- **Fields**: Question text, max word count, points
- **Auto-graded**: No - requires manual grading
- **Usage**: Detailed written responses, explanations

### 5. Fill in the Blank Questions
- **Fields**: Question text (with [blank] or _____), correct answers, points
- **Auto-graded**: Yes (exact match)
- **Usage**: Complete the sentence questions
- **Format**: "The capital of France is [blank]" → Answer: "Paris"

### 6. Matching Questions
- **Fields**: Question text, matching pairs (left-right items), points
- **Auto-graded**: Yes
- **Usage**: Match items from two columns
- **Example**: Match countries to capitals

### 7. Coding Questions (LeetCode Style) 🔥
- **Fields**: 
  - Question text (problem statement)
  - Supported languages (Python, Java, C++, JavaScript)
  - Time limit (milliseconds)
  - Memory limit (MB)
  - Input/output format descriptions
  - Constraints
  - Template code (starter code for students)
  - Test cases (sample + hidden)
- **Auto-graded**: Yes (based on test case results)
- **Usage**: Programming challenges

---

## 📝 How to Use

### Step 1: Create Exam
1. Fill in exam title, date, duration, and instructions
2. Click "✓ Create Exam"
3. Question section will appear

### Step 2: Add Questions

#### Single Question Tab (Recommended)
1. **Select Question Type** from dropdown
2. Form fields will change based on selected type
3. Fill in all required fields (marked with *)
4. Set points (default: 10)
5. Set difficulty (Easy/Medium/Hard)
6. Add tags (comma separated)
7. Click "✓ Add Question"

#### For Coding Questions:
1. Select "Coding Question (LeetCode Style)"
2. Fill problem statement
3. Check supported languages (Python, Java, C++, JavaScript)
4. Set time limit (default: 2000ms) and memory limit (default: 256MB)
5. Describe input/output formats
6. Add constraints
7. Provide template code (Python shown by default)
8. **Add Test Cases**:
   - Click "+ Add Test Case"
   - Enter input and expected output
   - Set points for this test case
   - Check "Sample Test" if students should see this (for testing)
   - Add explanation for sample tests
   - Add multiple test cases (at least 1 required)
9. Click "✓ Add Question"

---

## 🧪 Test Cases for Coding Questions

### Sample Test Cases
- **Visible** to students
- Used when students click "Run Code"
- Should include explanation
- Helps students understand the problem

### Hidden Test Cases
- **Not visible** to students
- Used for final grading when students click "Submit"
- Tests edge cases, large inputs, etc.
- Prevents hardcoding solutions

### Example Setup:
```
Problem: Find sum of two numbers

Sample Test 1 (visible):
Input: 2 3
Output: 5
Points: 5
Explanation: 2 + 3 = 5

Hidden Test 2:
Input: 1000000 2000000
Output: 3000000
Points: 5

Hidden Test 3:
Input: -5 10
Output: 5
Points: 5
```

---

## 🎨 Question Display

Questions are displayed with color-coded badges:
- **Blue**: MCQ
- **Green**: True/False
- **Yellow**: Short Answer
- **Purple**: Essay
- **Pink**: Fill Blank
- **Indigo**: Matching
- **Red**: Coding

Each question shows:
- Question number and type
- Question text
- Type-specific content (options, answers, test info)
- Points, difficulty, tags
- Edit and Delete buttons

---

## ⚠️ Important Notes

### Before Running:
1. **Execute SQL Script**: Run `update_questions_schema.sql` in Supabase SQL Editor
2. **Create Storage Buckets**:
   - "question-images" (for question images)
   - "Event Posters" (if not already created)

### Database Changes:
The new schema adds:
- `coding_test_cases` table
- `code_submissions` table
- `student_answers` table
- New columns in `questions` table

### Backend Requirements:
For coding questions to work during exams, you'll need:
1. Code execution engine (Judge0, Piston, or Docker)
2. Backend API routes for code execution
3. Security sandboxing for code execution

---

## 📊 Grading

### Auto-Graded:
- MCQ (correct option selected)
- True/False (correct answer)
- Short Answer (if expected answer provided - exact match)
- Fill Blank (exact match)
- Matching (all pairs correct)
- Coding (based on test cases passed)

### Manual Grading Required:
- Essay questions
- Short Answer (if no expected answer set)
- Any question needing subjective evaluation

---

## 🚀 Next Steps

After creating questions:
1. View all added questions in the list below
2. Edit or delete questions as needed
3. Click "✓ Done" to return to admin dashboard
4. Assign exam to students
5. Students can take the exam
6. View results and manually grade essay/short answer questions

---

## 💡 Tips

1. **Mix Question Types**: Use different types for comprehensive assessment
2. **Test Cases**: Add both simple and complex test cases for coding questions
3. **Points**: Allocate points based on difficulty (easy: 5-10, medium: 15-20, hard: 25-30)
4. **Tags**: Use tags for organizing questions (e.g., "arrays", "recursion", "aptitude")
5. **Sections**: Group questions by topic using section configuration
6. **Sample Tests**: Always provide at least one sample test case for coding questions

---

## 🐛 Troubleshooting

### Question not saving?
- Check all required fields are filled
- For coding: Ensure at least one test case is added
- For matching: Add at least 2 pairs

### Test case not appearing?
- Make sure both input and output are filled
- Click outside the field to trigger save

### Database errors?
- Ensure `update_questions_schema.sql` was executed
- Check Supabase connection in browser console

---

**Ready to create comprehensive exams!** 🎓
