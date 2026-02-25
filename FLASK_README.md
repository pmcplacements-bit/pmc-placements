# Placement Cell Online Test Platform - Flask Web Application

## Overview
This is a Flask-based web application for conducting online tests and exams for college placement cells.

## Installation

### Prerequisites
- Python 3.8 or higher
- pip (Python package installer)

### Setup Steps

1. **Install Python dependencies**
   ```bash
   pip install -r requirements.txt
   ```

2. **Run the application**
   ```bash
   python app.py
   ```

The application will start on `http://localhost:5000`

## Project Structure
```
PLACEMENT CELL/
├── app.py                  # Main Flask application
├── requirements.txt        # Python dependencies
├── templates/              # HTML templates (Jinja2)
│   ├── index.html
│   ├── student_login.html
│   ├── admin_login.html
│   └── ...
└── static/                 # Static files (CSS, JS)
    └── js/                 # JavaScript files
```

## Routes

### Authentication
- `/` - Home page
- `/student_login` - Student login (GET/POST)
- `/admin_login` - Admin login (GET/POST)
- `/logout` - Logout

### Student Routes (Protected)
- `/student_dashboard` - Student dashboard
- `/exam_instructions` - Exam instructions
- `/exam_fullscreen` - Exam interface

### Admin Routes (Protected)
- `/admin_dashboard` - Admin dashboard
- `/student_management` - Manage students
- `/manage_exams` - Manage exams
- `/create_exam` - Create new exam
- `/question_bank` - Question bank
- `/results_analytics` - Results analytics
- `/live_monitoring` - Live exam monitoring

## API Endpoints
- `/api/get_exams` - Get assigned exams (student)
- `/api/get_results` - Get exam results (student)
- `/api/get_questions` - Get exam questions (student)
- `/api/save_answer` - Save exam answer (student)
- `/api/submit_exam` - Submit exam (student)
- `/api/get_student_profile` - Get student profile (student)

## Security Notes
- Change the `SECRET_KEY` in production
- Use environment variables for sensitive data
- Enable HTTPS in production

## Technologies Used
- **Backend**: Flask (Python)
- **Frontend**: HTML, Tailwind CSS, JavaScript
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Flask sessions
