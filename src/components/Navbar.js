import React, { useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { 
  FaFingerprint, 
  FaTachometerAlt, 
  FaUser, 
  FaSignOutAlt, 
  FaMoon, 
  FaSun,
  FaBars,
  FaTimes
} from 'react-icons/fa';
import './Navbar.css';

const Navbar = ({ user, onLogout, darkMode, onToggleDarkMode }) => {
  const location = useLocation();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  const navItems = [
    { path: '/dashboard', icon: FaTachometerAlt, label: 'Dashboard' },
    { path: '/profile', icon: FaUser, label: 'Profile' }
  ];

  const isActive = (path) => location.pathname === path;

  const handleLogout = () => {
    onLogout();
    setMobileMenuOpen(false);
  };

  const toggleMobileMenu = () => {
    setMobileMenuOpen(!mobileMenuOpen);
  };

  return (
    <nav className="navbar">
      <div className="navbar-container">
        <Link to="/dashboard" className="navbar-brand">
          <FaFingerprint className="brand-icon" />
          <span className="brand-text">Tribute</span>
        </Link>

        <div className={`navbar-menu ${mobileMenuOpen ? 'active' : ''}`}>
          <div className="navbar-nav">
            {navItems.map((item) => (
              <Link
                key={item.path}
                to={item.path}
                className={`nav-link ${isActive(item.path) ? 'active' : ''}`}
                onClick={() => setMobileMenuOpen(false)}
              >
                <item.icon className="nav-icon" />
                <span>{item.label}</span>
              </Link>
            ))}
          </div>

          <div className="navbar-actions">
            <button
              onClick={onToggleDarkMode}
              className="theme-toggle"
              title={darkMode ? 'Switch to light mode' : 'Switch to dark mode'}
            >
              {darkMode ? <FaSun /> : <FaMoon />}
            </button>

            <div className="user-menu">
              <div className="user-info">
                <div className="user-avatar">
                  {user.name.charAt(0).toUpperCase()}
                </div>
                <div className="user-details">
                  <span className="user-name">{user.name}</span>
                  <span className="user-membership">{user.membership}</span>
                </div>
              </div>
              
              <button
                onClick={handleLogout}
                className="logout-btn"
                title="Sign out"
              >
                <FaSignOutAlt />
              </button>
            </div>
          </div>
        </div>

        <button
          className="mobile-menu-toggle"
          onClick={toggleMobileMenu}
          aria-label="Toggle mobile menu"
        >
          {mobileMenuOpen ? <FaTimes /> : <FaBars />}
        </button>
      </div>
    </nav>
  );
};

export default Navbar;
