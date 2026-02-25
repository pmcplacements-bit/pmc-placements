// Exam Engine: Timer, navigation, answer save, summary
// Custom popup modal for notifications and confirmations
function showPopup(opts) {
  // opts: { message, type, duration, onConfirm, onCancel }
  let popup = document.getElementById('custom-popup-modal');
  if (!popup) {
    popup = document.createElement('div');
    popup.id = 'custom-popup-modal';
    popup.className = 'fixed inset-0 flex items-center justify-center z-50';
    popup.innerHTML = `
      <div class="bg-white rounded-lg shadow-lg p-6 text-center max-w-sm w-full relative z-10">
        <div id="popup-message" class="mb-4 text-gray-800"></div>
        <div id="popup-actions"></div>
      </div>
      <div class="fixed inset-0 bg-black opacity-30 z-0"></div>
    `;
    document.body.appendChild(popup);
  }
  popup.style.display = 'flex';
  document.getElementById('popup-message').textContent = opts.message || '';
  const actions = document.getElementById('popup-actions');
  actions.innerHTML = '';
  if (opts.type === 'confirm') {
    const okBtn = document.createElement('button');
    okBtn.textContent = 'OK';
    okBtn.className = 'bg-blue-600 text-white px-4 py-2 rounded mr-2 hover:bg-blue-700';
    okBtn.onclick = () => {
      popup.style.display = 'none';
      if (opts.onConfirm) opts.onConfirm();
    };
    const cancelBtn = document.createElement('button');
    cancelBtn.textContent = 'Cancel';
    cancelBtn.className = 'bg-gray-200 text-gray-800 px-4 py-2 rounded hover:bg-gray-300';
    cancelBtn.onclick = () => {
      popup.style.display = 'none';
      if (opts.onCancel) opts.onCancel();
    };
    actions.appendChild(okBtn);
    actions.appendChild(cancelBtn);
  } else {
    const closeBtn = document.createElement('button');
    closeBtn.textContent = 'Close';
    closeBtn.className = 'bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700';
    closeBtn.onclick = () => {
      popup.style.display = 'none';
      if (opts.message && opts.message.toLowerCase().includes('exam submitted')) {
        window.location.href = 'student_dashboard.html?fullscreen=1';
      }
    };
    actions.appendChild(closeBtn);
    setTimeout(() => {
      popup.style.display = 'none';
      if (opts.message && opts.message.toLowerCase().includes('exam submitted')) {
        window.location.href = 'student_dashboard.html?fullscreen=1';
      }
    }, opts.duration || 2000);
  }
}
import { supabase } from './database.js';
import { shuffleArray } from './utils.js';
import { antiCheatInit } from './antiCheat.js';

let questions = [];
let answers = {};
let timer = null;
let duration = 0;
let examId = localStorage.getItem('exam_id');
let studentEmail = localStorage.getItem('email');
let studentId = null;

export async function startExam() {
  // Fullscreen is already enforced by exam_fullscreen.html
  // Get studentId and name
  const { data: student } = await supabase.from('students').select('id, name').eq('email', studentEmail).single();
  studentId = student.id;
  const studentName = student.name;
  // Generate initials from student name
  function getInitials(name) {
    if (!name) return '';
    return name.split(' ').map(w => w[0]).join('').toUpperCase();
  }
  const initials = getInitials(studentName);
  // Get exam details (name and duration)
  const { data: exam, error: examError } = await supabase.from('exams').select('title, duration').eq('id', examId).single();
  if (examError || !exam) {
    showPopup('Exam not found or invalid exam ID. Please contact admin.', 'error');
    return;
  }
  duration = exam.duration;
  const examName = exam.title;
  document.getElementById('exam-title').textContent = examName;
  // Set exam and student name in header
  document.getElementById('exam-title').textContent = examName;
  document.getElementById('student-name').textContent = studentName;
  // Set profile icon initials
  const profileIcon = document.querySelector('#examHeader span.bg-gray-200');
  if (profileIcon) profileIcon.textContent = initials;
  // Get questions
  const { data: qs } = await supabase.from('questions').select('*').eq('exam_id', examId);
  questions = shuffleArray(qs);
  // Load saved answers
  const { data: saved } = await supabase.from('answers').select('*').eq('student_id', studentId);
  for (const a of saved) answers[a.question_id] = a.answer;
  // Render UI
  renderExamUI();
  startTimer();
  autoSaveLoop();
  // Start anti-cheat only after UI is rendered and first question is shown
  setTimeout(() => { antiCheatInit({ autoSubmitThreshold: 3 }); }, 500);
}

function renderExamUI() {
  // Layout: left card, right sidebar
  const container = document.getElementById('examContainer');
  let html = `<div class='flex flex-col gap-6'>`;
  // Header is now in exam_fullscreen.html, so skip rendering it here
  html += `<div class='mb-4'><span class='font-semibold'>Question <span id='currentQNum'>1</span> of ${questions.length}</span>
    <div class='w-full bg-gray-200 rounded h-2 mt-2'><div id='progressBar' class='bg-green-500 h-2 rounded' style='width:0%'></div></div></div>`;
  html += `<div id='questionArea'></div>`;
  html += `<div class='flex justify-between items-center mt-10'>
    <button id='prevBtn' class='bg-gray-100 border px-6 py-2 rounded text-gray-700 font-semibold hover:bg-gray-200'>&larr; Previous</button>
    <button id='nextBtn' class='bg-green-600 text-white px-6 py-2 rounded font-semibold hover:bg-green-700'>Next &rarr;</button>
  </div>`;
  html += `</div>`;
  container.innerHTML = html;
  // Navigation logic
  let currentIdx = 0;
  let flagged = {};
  function updateProgress() {
    document.getElementById('currentQNum').textContent = currentIdx+1;
    document.getElementById('progressBar').style.width = `${((currentIdx+1)/questions.length)*100}%`;
  }
  function renderSidebarNav() {
    let navHtml = '';
    for (let i=0; i<questions.length; i++) {
      let status = '';
      if (answers[questions[i].id]) status = 'bg-green-100 text-green-700';
      else status = 'bg-gray-100 text-gray-700';
      if (flagged[questions[i].id]) status = 'bg-yellow-100 text-yellow-700';
      if (i === currentIdx) status = 'bg-blue-100 text-blue-700';
      navHtml += `<button class='px-3 py-2 rounded font-bold ${status}' onclick='showQuestion(${i})'>${i+1}</button>`;
    }
    document.getElementById('sidebarNav').innerHTML = navHtml;
  }
  window.showQuestion = function(idx) {
    currentIdx = idx;
    updateProgress();
    renderSidebarNav();
    renderQuestion(idx);
  };
  function renderQuestion(idx) {
    const q = questions[idx];
    let html = `<div class='mb-6 text-lg font-semibold'>${q.question_text}</div>`;
    if (q.type === 'mcq') {
      const opts = Array.isArray(q.options) ? q.options : JSON.parse(q.options);
      opts.forEach((opt, i) => {
        html += `<label class='block mb-3 cursor-pointer text-base'><input type='radio' name='answer' value='${opt}' ${answers[q.id]===opt?'checked':''}> <span class='ml-3'>${opt}</span></label>`;
      });
    } else if (q.type === 'true_false') {
      ['True','False'].forEach(opt => {
        html += `<label class='block mb-3 cursor-pointer text-base'><input type='radio' name='answer' value='${opt}' ${answers[q.id]===opt?'checked':''}> <span class='ml-3'>${opt}</span></label>`;
      });
    } else if (q.type === 'fill_blank') {
      html += `<input type='text' name='answer' class='border px-3 py-2 rounded w-full text-base' value='${answers[q.id]||''}'>`;
    }
    html += `<div class='mt-6 flex gap-4'><button class='bg-green-600 text-white px-6 py-2 rounded font-semibold text-base' onclick='saveAnswer(${idx})'>Save Changes</button> <button class='bg-yellow-500 text-white px-6 py-2 rounded font-semibold text-base' onclick='markForReview(${idx})'>Flag for Review</button></div>`;
    document.getElementById('questionArea').innerHTML = html;
  }
  document.getElementById('prevBtn').onclick = async function() {
    await saveCurrentAnswer();
    if (currentIdx > 0) showQuestion(currentIdx-1);
  };
  document.getElementById('nextBtn').onclick = async function() {
    await saveCurrentAnswer();
    if (currentIdx < questions.length-1) showQuestion(currentIdx+1);
  };
  document.getElementById('sidebarFlagBtn').onclick = function() {
    flagged[questions[currentIdx].id] = true;
    renderSidebarNav();
    showPopup('Question flagged for review.');
  };
  document.getElementById('sidebarSubmitBtn').onclick = function() {
  showPopup({
    message: 'Are you sure you want to submit your exam?',
    type: 'confirm',
    onConfirm: submitExam,
    onCancel: () => {}
  });
  };
  // Timer in sidebar
  function updateSidebarTimer(timeStr) {
    document.getElementById('sidebarTimer').textContent = timeStr;
  }
  showQuestion(0);
  updateProgress();
  renderSidebarNav();
  // Expose timer update for startTimer
  window.updateSidebarTimer = updateSidebarTimer;
  // Save current answer (used for auto-save on navigation)
  async function saveCurrentAnswer() {
    const q = questions[currentIdx];
    let val = '';
    if (q.type === 'fill_blank') {
      val = document.querySelector('input[name="answer"]').value;
    } else {
      val = document.querySelector('input[name="answer"]:checked')?.value;
    }
    if (val) {
      answers[q.id] = val;
      await supabase.from('answers').upsert({ student_id: studentId, question_id: q.id, answer: val });
    }
  }
}

window.showQuestion = function(idx) {
  const q = questions[idx];
  let html = `<div class='mb-4 text-lg font-semibold'>${q.question_text}</div>`;
  if (q.type === 'mcq') {
    const opts = Array.isArray(q.options) ? q.options : JSON.parse(q.options);
    opts.forEach((opt, i) => {
      html += `<label class='block mb-2'><input type='radio' name='answer' value='${opt}' ${answers[q.id]===opt?'checked':''}> <span class='ml-2'>${opt}</span></label>`;
    });
  } else if (q.type === 'true_false') {
    ['True','False'].forEach(opt => {
      html += `<label class='block mb-2'><input type='radio' name='answer' value='${opt}' ${answers[q.id]===opt?'checked':''}> <span class='ml-2'>${opt}</span></label>`;
    });
  } else if (q.type === 'fill_blank') {
    html += `<input type='text' name='answer' class='border px-2 py-1 rounded w-full' value='${answers[q.id]||''}'>`;
  }
  html += `<div class='mt-4'><button class='bg-blue-600 text-white px-4 py-2 rounded' onclick='saveAnswer(${idx})'>Save Answer</button> <button class='bg-yellow-500 text-white px-4 py-2 rounded ml-2' onclick='markForReview(${idx})'>Mark for Review</button></div>`;
  document.getElementById('questionArea').innerHTML = html;
}

window.saveAnswer = async function(idx) {
  // No fullscreen enforcement on save
  const q = questions[idx];
  let val = '';
  if (q.type === 'fill_blank') {
    val = document.querySelector('input[name="answer"]').value;
  } else {
    val = document.querySelector('input[name="answer"]:checked')?.value;
  }
  if (!val) return showPopup('Select or enter an answer.', 'error');
  answers[q.id] = val;
  await supabase.from('answers').upsert({ student_id: studentId, question_id: q.id, answer: val });
  showPopup('Answer saved!');
}

window.markForReview = function(idx) {
  // No fullscreen enforcement on mark for review
  showPopup('Marked for review!');
}

function startTimer() {
  let timeLeft = duration * 60;
  window.updateSidebarTimer(formatTime(timeLeft));
  timer = setInterval(() => {
    timeLeft--;
    window.updateSidebarTimer(formatTime(timeLeft));
    if (timeLeft <= 0) {
      clearInterval(timer);
      submitExam();
    }
  }, 1000);
}

function formatTime(sec) {
  const m = Math.floor(sec/60);
  const s = sec%60;
  return `${m}m ${s}s`;
}

function autoSaveLoop() {
  setInterval(async () => {
    for (const q of questions) {
      if (answers[q.id]) {
        await supabase.from('answers').upsert({ student_id: studentId, question_id: q.id, answer: answers[q.id] });
      }
    }
  }, 2000);
}

export async function submitExam() {
  // Calculate score
  let score = 0;
  for (const q of questions) {
    if (answers[q.id] && answers[q.id] === q.correct_answer) score++;
  }
  // Store in results table (legacy)
  await supabase.from('results').upsert({ student_id: studentId, exam_id: examId, score });
  // Store in submissions table (new)
  const submissionObj = {
    student_id: studentId,
    exam_id: examId,
    answers: JSON.stringify(answers),
    score,
    status: 'submitted'
  };
  const { error } = await supabase.from('submissions').insert(submissionObj);
  if (error) {
    showPopup({ message: 'Submission failed: ' + error.message, type: 'error' });
    return;
  }
  showPopup({ message: 'Exam submitted!', type: 'info' });
  window.location.href = 'student_dashboard.html?fullscreen=1';
}
