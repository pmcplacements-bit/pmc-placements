// Custom authentication using users table (email, password, role)
import { supabase } from './database.js';

export async function login(email, password, role) {
  if (role === 'student') {
    // Query students table for matching email and password
    const { data, error } = await supabase
      .from('students')
      .select('*')
      .eq('email', email)
      .eq('password', password)
      .single();
    if (error || !data) {
      return { error: { message: 'Invalid student credentials.' } };
    }
    // Store session info
    localStorage.setItem('user_id', data.id);
    localStorage.setItem('role', 'student');
    localStorage.setItem('email', data.email);
    localStorage.setItem('name', data.name);
    return { data };
  } else {
    // Query users table for admin login
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('email', email)
      .eq('password', password)
      .eq('role', role)
      .single();
    if (error || !data) {
      return { error: { message: 'Invalid admin credentials or role.' } };
    }
    localStorage.setItem('user_id', data.id);
    localStorage.setItem('role', data.role);
    localStorage.setItem('email', data.email);
    localStorage.setItem('name', data.name);
    return { data };
  }
}

export function logout() {
  localStorage.clear();
}

export function getRole() {
  return localStorage.getItem('role');
}

export function isLoggedIn() {
  return !!localStorage.getItem('user_id');
}
