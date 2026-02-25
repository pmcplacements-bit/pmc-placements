# Flask Web Application for Placement Cell Online Test Platform
from flask import Flask, render_template, request, redirect, url_for, session, jsonify
from functools import wraps
import os
from datetime import timedelta
from supabase import create_client, Client

app = Flask(__name__)
app.secret_key = os.environ.get('SECRET_KEY', 'your-secret-key-here-change-in-production')
app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(hours=24)

# Supabase configuration
SUPABASE_URL = "https://kflhmnyikwaznzkgeini.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtmbGhtbnlpa3dhem56a2dlaW5pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ1NTQ5MDEsImV4cCI6MjA4MDEzMDkwMX0.nTkrtt4SQEYLq529ccYvnR46L1mbzBzagoVifP2VkWQ"
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# Authentication decorator
def login_required(role=None):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if 'email' not in session:
                return redirect(url_for('index'))
            if role and session.get('role') != role:
                return redirect(url_for('index'))
            return f(*args, **kwargs)
        return decorated_function
    return decorator

# Routes
@app.route('/')
def index():
    return render_template('index.html')

@app.route('/student_login', methods=['GET', 'POST'])
def student_login():
    if request.method == 'POST':
        email = request.form.get('email')
        password = request.form.get('password')
        
        try:
            response = supabase.table('students').select('*').eq('email', email).eq('password', password).execute()
            if response.data and len(response.data) > 0:
                student = response.data[0]
                session['email'] = student['email']
                session['name'] = student['name']
                session['student_id'] = student['id']
                session['role'] = 'student'
                session.permanent = True
                return redirect(url_for('student_dashboard'))
            else:
                return render_template('student_login.html', error='Invalid credentials')
        except Exception as e:
            return render_template('student_login.html', error=str(e))
    
    return render_template('student_login.html')

@app.route('/admin_login', methods=['GET', 'POST'])
def admin_login():
    if request.method == 'POST':
        email = request.form.get('email')
        password = request.form.get('password')
        
        try:
            response = supabase.table('users').select('*').eq('email', email).eq('password', password).eq('role', 'admin').execute()
            if response.data and len(response.data) > 0:
                admin = response.data[0]
                session['email'] = admin['email']
                session['name'] = admin.get('name', 'Admin')
                session['user_id'] = admin['id']
                session['role'] = 'admin'
                session.permanent = True
                return redirect(url_for('admin_dashboard'))
            else:
                return render_template('admin_login.html', error='Invalid credentials')
        except Exception as e:
            return render_template('admin_login.html', error=str(e))
    
    return render_template('admin_login.html')

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('index'))

@app.route('/student_dashboard')
@login_required(role='student')
def student_dashboard():
    return render_template('student_dashboard.html')

@app.route('/admin_dashboard')
@login_required(role='admin')
def admin_dashboard():
    return render_template('admin_dashboard.html')

@app.route('/exam_instructions')
@login_required(role='student')
def exam_instructions():
    exam_id = request.args.get('exam_id')
    return render_template('exam_instructions.html', exam_id=exam_id)

@app.route('/exam_fullscreen')
@login_required(role='student')
def exam_fullscreen():
    return render_template('exam_fullscreen.html')

@app.route('/student_management')
@login_required(role='admin')
def student_management():
    return render_template('student_management.html')

@app.route('/events_management')
@login_required(role='admin')
def events_management():
    return render_template('events_management.html')

@app.route('/circulars_management')
@login_required(role='admin')
def circulars_management():
    return render_template('circulars_management.html')

@app.route('/manage_exams')
@login_required(role='admin')
def manage_exams():
    return render_template('manage_exams.html')

@app.route('/create_exam')
@login_required(role='admin')
def create_exam():
    return render_template('create_exam.html')

@app.route('/question_bank')
@login_required(role='admin')
def question_bank():
    return render_template('question_bank.html')

@app.route('/results_analytics')
@login_required(role='admin')
def results_analytics():
    return render_template('results_analytics.html')

@app.route('/live_monitoring')
@login_required(role='admin')
def live_monitoring():
    return render_template('live_monitoring.html')

# API endpoints for AJAX calls
@app.route('/api/get_exams', methods=['GET'])
@login_required(role='student')
def api_get_exams():
    try:
        student_id = session.get('student_id')
        if not student_id:
            return jsonify({'error': 'Student not logged in'}), 401
            
        # Get assigned exams
        assigned = supabase.table('student_exam_map').select('exam_id').eq('student_id', student_id).execute()
        
        # Get submissions (removed 'status' field that doesn't exist)
        submissions = supabase.table('submissions').select('exam_id,score,total,percentage,submitted_at,auto_submitted').eq('student_id', student_id).execute()
        
        exam_list = []
        submitted_map = {sub['exam_id']: sub for sub in (submissions.data or [])}
        
        for map_item in (assigned.data or []):
            try:
                exam = supabase.table('exams').select('*').eq('id', map_item['exam_id']).execute()
                if exam.data and len(exam.data) > 0:
                    exam_data = exam.data[0]
                    exam_id = exam_data.get('id')
                    exam_data['submitted'] = exam_id in submitted_map
                    exam_data['submission'] = submitted_map.get(exam_id)
                    exam_list.append(exam_data)
            except Exception as exam_error:
                print(f"Error loading exam: {exam_error}")
                continue
        
        return jsonify({'exams': exam_list})
    except Exception as e:
        print(f"Error in get_exams: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/get_results', methods=['GET'])
@login_required(role='student')
def api_get_results():
    try:
        student_id = session.get('student_id')
        if not student_id:
            return jsonify({'error': 'Student not logged in'}), 401
            
        submissions = supabase.table('submissions').select('*').eq('student_id', student_id).execute()
        
        results = []
        for sub in (submissions.data or []):
            try:
                exam = supabase.table('exams').select('title').eq('id', sub.get('exam_id')).execute()
                
                # Calculate percentage
                score = float(sub.get('score', 0))
                total = float(sub.get('total', 1))
                percentage = (score / total * 100) if total > 0 else 0
                
                # Determine status based on submission
                status = 'Auto-Submitted' if sub.get('auto_submitted') else 'Completed'
                
                result = {
                    'exam_title': exam.data[0]['title'] if exam.data and len(exam.data) > 0 else 'Unknown Exam',
                    'score': round(percentage, 2),
                    'raw_score': f"{int(score)}/{int(total)}",
                    'status': status,
                    'submitted_at': sub.get('submitted_at'),
                    'percentage': round(percentage, 2)
                }
                results.append(result)
            except Exception as sub_error:
                print(f"Error processing submission: {sub_error}")
                continue
        
        return jsonify({'results': results})
    except Exception as e:
        print(f"Error in get_results: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/submit_exam', methods=['POST'])
@login_required(role='student')
def api_submit_exam():
    try:
        data = request.json
        student_id = session.get('student_id')
        exam_id = data.get('exam_id')
        answers = data.get('answers')
        score = data.get('score')
        
        # Store in submissions table
        submission_obj = {
            'student_id': student_id,
            'exam_id': exam_id,
            'answers': str(answers),
            'score': score,
            'status': 'submitted'
        }
        
        supabase.table('submissions').insert(submission_obj).execute()
        supabase.table('results').upsert({'student_id': student_id, 'exam_id': exam_id, 'score': score}).execute()
        
        return jsonify({'success': True})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/get_questions', methods=['GET'])
@login_required(role='student')
def api_get_questions():
    try:
        exam_id = request.args.get('exam_id')
        questions = supabase.table('questions').select('*').eq('exam_id', exam_id).execute()
        return jsonify({'questions': questions.data or []})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/save_answer', methods=['POST'])
@login_required(role='student')
def api_save_answer():
    try:
        data = request.json
        student_id = session.get('student_id')
        question_id = data.get('question_id')
        answer = data.get('answer')
        
        supabase.table('answers').upsert({
            'student_id': student_id,
            'question_id': question_id,
            'answer': answer
        }).execute()
        
        return jsonify({'success': True})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/get_student_profile', methods=['GET'])
@login_required(role='student')
def api_get_student_profile():
    try:
        email = session.get('email')
        student = supabase.table('students').select('*').eq('email', email).execute()
        if student.data:
            return jsonify({'student': student.data[0]})
        return jsonify({'error': 'Student not found'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/upload_word_questions', methods=['POST'])
@login_required(role='admin')
def api_upload_word_questions():
    try:
        import re
        from docx import Document
        
        if 'file' not in request.files:
            return jsonify({'error': 'No file provided'}), 400
        
        file = request.files['file']
        exam_id = request.form.get('exam_id')
        section = request.form.get('section', '')
        
        if not exam_id:
            return jsonify({'error': 'No exam ID provided'}), 400
        
        # Parse Word document
        doc = Document(file)
        questions = []
        current_question = {}
        
        for para in doc.paragraphs:
            text = para.text.strip()
            if not text:
                continue
            
            # Format 1: Q1. Question? or Question: text
            if re.match(r'^(Q\d+\.|Question:)', text, re.IGNORECASE):
                if current_question and 'question_text' in current_question:
                    questions.append(current_question)
                current_question = {'question_text': re.sub(r'^(Q\d+\.|Question:)\s*', '', text, flags=re.IGNORECASE)}
                current_question['options'] = []
            
            # Format 1: Options A) B) C) D)
            elif re.match(r'^[A-D][\)\.]\s*.+', text, re.IGNORECASE):
                option_text = re.sub(r'^[A-D][\)\.]\s*', '', text, flags=re.IGNORECASE)
                is_correct = '[CORRECT]' in option_text.upper() or '(CORRECT)' in option_text.upper()
                option_text = re.sub(r'\s*[\[\(]CORRECT[\]\)]\s*', '', option_text, flags=re.IGNORECASE).strip()
                current_question['options'].append(option_text)
                if is_correct:
                    current_question['correct_answer'] = option_text
            
            # Format 2: Option1:, Option2:, etc.
            elif re.match(r'^Option[1-4]:\s*.+', text, re.IGNORECASE):
                option_text = re.sub(r'^Option[1-4]:\s*', '', text, flags=re.IGNORECASE).strip()
                current_question['options'].append(option_text)
            
            # Format 2: Correct: Option2
            elif re.match(r'^Correct:\s*.+', text, re.IGNORECASE):
                correct_ref = re.sub(r'^Correct:\s*', '', text, flags=re.IGNORECASE).strip()
                if 'Option' in correct_ref:
                    opt_num = int(re.search(r'\d+', correct_ref).group()) - 1
                    if opt_num < len(current_question.get('options', [])):
                        current_question['correct_answer'] = current_question['options'][opt_num]
                else:
                    current_question['correct_answer'] = correct_ref
            
            # Difficulty
            elif re.match(r'^Difficulty:\s*.+', text, re.IGNORECASE):
                current_question['difficulty'] = re.sub(r'^Difficulty:\s*', '', text, flags=re.IGNORECASE).strip()
            
            # Tags
            elif re.match(r'^Tags:\s*.+', text, re.IGNORECASE):
                current_question['tags'] = re.sub(r'^Tags:\s*', '', text, flags=re.IGNORECASE).strip()
            
            # Negative Mark
            elif re.match(r'^Negative:\s*.+', text, re.IGNORECASE):
                try:
                    current_question['negative_mark'] = float(re.sub(r'^Negative:\s*', '', text, flags=re.IGNORECASE).strip())
                except:
                    pass
        
        # Add last question
        if current_question and 'question_text' in current_question:
            questions.append(current_question)
        
        # Insert questions into database
        success_count = 0
        failed_count = 0
        preview = []
        
        for q in questions:
            if 'question_text' not in q or len(q.get('options', [])) < 4 or 'correct_answer' not in q:
                failed_count += 1
                continue
            
            insert_data = {
                'exam_id': exam_id,
                'question_text': q['question_text'],
                'type': 'mcq',
                'options': q['options'],  # Supabase will convert to JSON
                'correct_answer': q['correct_answer']
            }
            
            if section:
                insert_data['section'] = section
            if 'difficulty' in q:
                insert_data['difficulty'] = q['difficulty']
            if 'tags' in q:
                insert_data['tags'] = q['tags']
            if 'negative_mark' in q:
                insert_data['negative_mark'] = q['negative_mark']
            
            try:
                result = supabase.table('questions').insert(insert_data).execute()
                if result.data:
                    success_count += 1
                    if len(preview) < 3:
                        preview.append({'question_text': q['question_text']})
                else:
                    failed_count += 1
            except Exception as e:
                print(f"Error inserting question: {e}")
                failed_count += 1
        
        return jsonify({
            'success': success_count,
            'failed': failed_count,
            'preview': preview
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/dashboard_stats', methods=['GET'])
@login_required(role='admin')
def dashboard_stats():
    try:
        # Get total students count
        students_response = supabase.table('students').select('id', count='exact').execute()
        total_students = students_response.count if hasattr(students_response, 'count') else len(students_response.data)
        
        # Get total exams count
        exams_response = supabase.table('exams').select('id', count='exact').execute()
        total_exams = exams_response.count if hasattr(exams_response, 'count') else len(exams_response.data)
        
        # Get total questions count
        questions_response = supabase.table('questions').select('id', count='exact').execute()
        total_questions = questions_response.count if hasattr(questions_response, 'count') else len(questions_response.data)
        
        # Get total submissions count
        submissions_response = supabase.table('submissions').select('id', count='exact').execute()
        total_submissions = submissions_response.count if hasattr(submissions_response, 'count') else len(submissions_response.data)
        
        return jsonify({
            'students': total_students,
            'exams': total_exams,
            'questions': total_questions,
            'submissions': total_submissions
        })
    except Exception as e:
        return jsonify({
            'error': str(e),
            'students': 0,
            'exams': 0,
            'questions': 0,
            'submissions': 0
        }), 200

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
