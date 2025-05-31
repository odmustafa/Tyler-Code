import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import './App.css';
import Login from './components/Login';
import Register from './components/Register';
import Dashboard from './components/Dashboard';
import Profile from './components/Profile';
import Navbar from './components/Navbar';
import LoadingSpinner from './components/LoadingSpinner';

function App() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [darkMode, setDarkMode] = useState(true);

  useEffect(() => {
    // Check for stored user session
    const storedUser = localStorage.getItem('tributeUser');
    if (storedUser) {
      setUser(JSON.parse(storedUser));
    }
    setLoading(false);
  }, []);

  const handleLogin = (userData) => {
    setUser(userData);
    localStorage.setItem('tributeUser', JSON.stringify(userData));
  };

  const handleLogout = () => {
    setUser(null);
    localStorage.removeItem('tributeUser');
  };

  const toggleDarkMode = () => {
    setDarkMode(!darkMode);
  };

  if (loading) {
    return (
      <div className="app-loading">
        <LoadingSpinner />
      </div>
    );
  }

  return (
    <div className={`app ${darkMode ? 'dark-theme' : 'light-theme'}`}>
      <Router>
        {user && (
          <Navbar 
            user={user} 
            onLogout={handleLogout}
            darkMode={darkMode}
            onToggleDarkMode={toggleDarkMode}
          />
        )}
        
        <main className="main-content">
          <Routes>
            <Route 
              path="/login" 
              element={
                user ? <Navigate to="/dashboard" /> : 
                <Login onLogin={handleLogin} darkMode={darkMode} />
              } 
            />
            <Route 
              path="/register" 
              element={
                user ? <Navigate to="/dashboard" /> : 
                <Register onRegister={handleLogin} darkMode={darkMode} />
              } 
            />
            <Route 
              path="/dashboard" 
              element={
                user ? <Dashboard user={user} darkMode={darkMode} /> : 
                <Navigate to="/login" />
              } 
            />
            <Route 
              path="/profile" 
              element={
                user ? <Profile user={user} setUser={setUser} darkMode={darkMode} /> : 
                <Navigate to="/login" />
              } 
            />
            <Route 
              path="/" 
              element={<Navigate to={user ? "/dashboard" : "/login"} />} 
            />
          </Routes>
        </main>
      </Router>
    </div>
  );
}

export default App;
