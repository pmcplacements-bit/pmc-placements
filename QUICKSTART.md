# Quick Start Guide - Flask Application

## Step 1: Install Dependencies
```bash
pip install -r requirements.txt
```

## Step 2: Run the Application
```bash
python app.py
```

## Step 3: Access the Application
Open your browser and go to:
```
http://localhost:5000
```

## Login Credentials

### Admin Login
- URL: http://localhost:5000/admin_login
- Use credentials from your `users` table in Supabase

### Student Login
- URL: http://localhost:5000/student_login
- Use credentials from your `students` table in Supabase

## Key Changes from Static Site

1. **Authentication**: Now handled server-side with Flask sessions
2. **Routes**: All pages use Flask routes instead of direct HTML links
3. **API Calls**: Frontend JavaScript makes AJAX calls to Flask API endpoints
4. **Templates**: HTML files are now in `templates/` folder
5. **Static Files**: JS/CSS files are in `static/` folder

## File Structure
```
PLACEMENT CELL/
├── app.py                    # Main Flask application
├── requirements.txt          # Python dependencies
├── templates/                # Jinja2 templates
│   ├── base.html            # Base template
│   ├── index.html
│   ├── student_login.html
│   ├── admin_login.html
│   ├── student_dashboard.html
│   └── ...
└── static/                   # Static assets
    └── js/                   # JavaScript files
        ├── database.js
        ├── examEngine.js
        └── ...
```

## Important Notes

- Session timeout is set to 24 hours
- Change `SECRET_KEY` in production
- The application uses Supabase for database operations
- Client-side JavaScript still handles exam logic and anti-cheat
- Server validates all submissions

## Troubleshooting

**Port already in use:**
```bash
# Kill process on port 5000 (Windows)
netstat -ano | findstr :5000
taskkill /PID <PID> /F
```

**Module not found:**
```bash
pip install -r requirements.txt
```

**Database connection issues:**
- Verify Supabase URL and API key in `app.py`
- Check internet connection
- Verify Supabase project is active
