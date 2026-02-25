Render deployment notes
======================

Build command (optional):

- Leave blank (Render installs from `requirements.txt` automatically), or run:

```
pip install -r requirements.txt
```

Start command:

```
gunicorn app:app
```

Environment variables to set on Render (at minimum):

- `SECRET_KEY` — session secret
- `SUPABASE_URL` — your Supabase project URL
- `SUPABASE_KEY` — your Supabase anon/service key
- `FLASK_DEBUG` — optional, `True` for debug when running locally

Notes:

- A `Procfile` is included (`web: gunicorn app:app`).
- `requirements.txt` now includes `gunicorn`.
- The app reads the `PORT` environment variable when run locally via `python app.py`.
