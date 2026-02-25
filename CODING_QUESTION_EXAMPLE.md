# Coding Question Example - Complete Setup

## 📝 Example Problem: "Sum of Even Numbers in Array"

Follow this step-by-step guide to create your first coding question.

---

## Step-by-Step Instructions

### 1. Create Exam First
- **Exam Title**: `Python Programming Test 2025`
- **Exam Date**: `2025-12-20`
- **Duration**: `90` minutes
- **Instructions**: `Read each question carefully. For coding questions, test your code before submitting.`
- Click **"✓ Create Exam"**

### 2. Navigate to Single Question Tab
- Click on **"📝 Single Question"** tab

### 3. Select Question Type
- **Question Type**: Select **"Coding Question (LeetCode Style)"** from dropdown

### 4. Fill Question Details

#### Question Text (Problem Statement):
```
Given an array of integers, write a function to find the sum of all even numbers in the array.

Example 1:
Input: arr = [1, 2, 3, 4, 5, 6]
Output: 12
Explanation: Even numbers are 2, 4, 6. Sum = 2 + 4 + 6 = 12

Example 2:
Input: arr = [1, 3, 5, 7]
Output: 0
Explanation: No even numbers in the array

Example 3:
Input: arr = [-2, -4, 3, 5]
Output: -6
Explanation: Even numbers are -2, -4. Sum = -2 + (-4) = -6

Write a function sum_evens(arr) that takes a list of integers and returns the sum of all even numbers.
```

#### Supported Languages:
- ✅ Check **Python** (required)
- ✅ Check **Java** (optional)
- ✅ Check **C++** (optional)
- ☐ JavaScript (optional)

#### Time Limit:
- Enter: `2000` (milliseconds)

#### Memory Limit:
- Enter: `256` (MB)

#### Input Format Description:
```
First line contains an integer n (1 ≤ n ≤ 10^5), the size of the array.
Second line contains n space-separated integers representing the array elements.
```

#### Output Format Description:
```
Print a single integer representing the sum of all even numbers in the array.
```

#### Constraints:
```
• 1 ≤ n ≤ 100,000
• -10^9 ≤ arr[i] ≤ 10^9
• If no even numbers exist, return 0
```

#### Template Code (Python):
```python
def sum_evens(arr):
    """
    Calculate the sum of all even numbers in the array.
    
    Args:
        arr: List of integers
    
    Returns:
        Integer representing sum of even numbers
    """
    # Write your code here
    pass

# Read input
n = int(input())
arr = list(map(int, input().split()))

# Call function and print result
result = sum_evens(arr)
print(result)
```

#### Points:
- Enter: `20`

#### Difficulty:
- Select: **Easy**

#### Tags:
- Enter: `arrays, loops, conditionals, basics`

---

### 5. Add Test Cases

Click **"+ Add Test Case"** button 4 times to add 4 test cases.

#### Test Case 1 (Sample - Visible to Students)
- **Input**:
  ```
  6
  1 2 3 4 5 6
  ```
- **Expected Output**:
  ```
  12
  ```
- **Points**: `5`
- **Sample Test**: ✅ **Check this box** (makes it visible to students)
- **Explanation**: `Even numbers are 2, 4, 6. Sum = 2 + 4 + 6 = 12`

#### Test Case 2 (Sample - Visible to Students)
- **Input**:
  ```
  4
  1 3 5 7
  ```
- **Expected Output**:
  ```
  0
  ```
- **Points**: `5`
- **Sample Test**: ✅ **Check this box**
- **Explanation**: `No even numbers in the array, so sum is 0`

#### Test Case 3 (Hidden - For Grading Only)
- **Input**:
  ```
  5
  -2 -4 3 5 8
  ```
- **Expected Output**:
  ```
  2
  ```
- **Points**: `5`
- **Sample Test**: ☐ **Leave unchecked** (hidden test)
- **Explanation**: Leave empty (not shown to students)

#### Test Case 4 (Hidden - Edge Case)
- **Input**:
  ```
  10
  10 20 30 40 50 60 70 80 90 100
  ```
- **Expected Output**:
  ```
  550
  ```
- **Points**: `5`
- **Sample Test**: ☐ **Leave unchecked**
- **Explanation**: Leave empty

---

### 6. Final Check

Your form should look like this:

```
Question Type: Coding Question (LeetCode Style)

Question Text: [Full problem statement as shown above]

Supported Languages:
  ✅ Python
  ✅ Java
  ✅ C++

Time Limit: 2000 ms
Memory Limit: 256 MB

Input Format: First line contains an integer n...
Output Format: Print a single integer...
Constraints: • 1 ≤ n ≤ 100,000...

Template Code (Python): [Code template as shown above]

Test Cases: 4 cases added
  - Test Case 1: Sample ✅ (5 points)
  - Test Case 2: Sample ✅ (5 points)
  - Test Case 3: Hidden (5 points)
  - Test Case 4: Hidden (5 points)

Points: 20
Difficulty: Easy
Tags: arrays, loops, conditionals, basics
```

### 7. Submit
Click **"✓ Add Question"** button

You should see: ✓ Question added successfully!

---

## 🎯 Another Example: "Two Sum Problem" (Medium Difficulty)

### Quick Template:

**Question Text:**
```
Given an array of integers nums and an integer target, return the indices of the two numbers that add up to target.

You may assume that each input has exactly one solution, and you may not use the same element twice.

Example:
Input: nums = [2, 7, 11, 15], target = 9
Output: [0, 1]
Explanation: nums[0] + nums[1] = 2 + 7 = 9

Write a function two_sum(nums, target) that returns a list of two indices.
```

**Input Format:**
```
First line: integer n (array size)
Second line: n space-separated integers (array elements)
Third line: integer target
```

**Output Format:**
```
Two space-separated integers representing the indices (0-based)
```

**Constraints:**
```
• 2 ≤ n ≤ 10^4
• -10^9 ≤ nums[i] ≤ 10^9
• -10^9 ≤ target ≤ 10^9
• Exactly one solution exists
```

**Template Code:**
```python
def two_sum(nums, target):
    # Write your code here
    pass

# Read input
n = int(input())
nums = list(map(int, input().split()))
target = int(input())

# Call function
result = two_sum(nums, target)
print(result[0], result[1])
```

**Test Cases:**

**Sample Test 1:**
- Input: `4\n2 7 11 15\n9`
- Output: `0 1`
- Points: 10
- Sample: ✅
- Explanation: `nums[0] + nums[1] = 2 + 7 = 9`

**Hidden Test 2:**
- Input: `5\n3 2 4 1 6\n6`
- Output: `1 2`
- Points: 10
- Sample: ☐

**Hidden Test 3:**
- Input: `6\n-1 -2 -3 -4 -5 0\n-8`
- Output: `2 4`
- Points: 10
- Sample: ☐

**Points:** 30  
**Difficulty:** Medium  
**Tags:** arrays, hash-map, two-pointers

---

## 🔍 Verification Checklist

Before clicking "Add Question", verify:

- [ ] Question type selected: "Coding Question (LeetCode Style)"
- [ ] Problem statement is clear and detailed
- [ ] At least 1 language is checked
- [ ] Time limit set (default: 2000ms)
- [ ] Memory limit set (default: 256MB)
- [ ] Input/output format described
- [ ] Constraints listed
- [ ] Template code provided
- [ ] At least 1 test case added
- [ ] At least 1 sample test case (for students to test)
- [ ] At least 1 hidden test case (for grading)
- [ ] All test cases have input AND output
- [ ] Points allocated
- [ ] Difficulty selected

---

## 📊 Expected Result

After submission, you'll see the question in the "Added Questions" section below with:

- **Question Number**: Q1, Q2, etc.
- **Type Badge**: Red badge saying "Coding"
- **Question Text**: Your problem statement
- **Language Tags**: python, java, cpp (dark badges)
- **Time/Memory Info**: ⏱️ Time: 2000ms, 💾 Memory: 256MB
- **Points**: 💯 20 points (or whatever you set)
- **Difficulty**: 📊 Easy/Medium/Hard
- **Tags**: 🏷️ arrays, loops, etc.
- **Edit/Delete buttons**

---

## 💡 Pro Tips

1. **Start Simple**: Begin with easy problems like sum/count operations
2. **Multiple Test Cases**: Always include edge cases (empty arrays, negatives, large numbers)
3. **Sample Tests**: Provide 1-2 sample tests so students can verify their logic
4. **Hidden Tests**: Add 2-3 hidden tests to prevent hardcoding
5. **Clear Templates**: Provide function signature and input/output handling
6. **Point Distribution**: Distribute points across test cases (5 points each × 4 tests = 20 total)
7. **Time Limits**: 
   - Easy problems: 1000-2000ms
   - Medium: 2000-3000ms
   - Hard: 3000-5000ms
8. **Test Input Format**: Use newlines (`\n`) for multi-line input in test cases

---

## 🚀 Ready to Test!

Copy the "Sum of Even Numbers" example exactly as shown above and create your first coding question. Once it's saved, you can view it in the questions list and later test it during an actual exam.

**Next Steps:**
1. Run the SQL script: `update_questions_schema.sql`
2. Create the exam using the example values
3. Add the coding question with all fields
4. Verify it appears in the questions list
5. Later: Set up code execution engine (Judge0/Piston) for actual code testing

**Good luck! 🎓**
