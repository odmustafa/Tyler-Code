import React, { useState, useEffect } from 'react';
import {
  FaFingerprint,
  FaUser,
  FaIdCard,
  FaClock,
  FaShieldAlt,
  FaChartLine,
  FaCalendarAlt,
  FaBell
} from 'react-icons/fa';
import './Dashboard.css';

const Dashboard = ({ user, darkMode }) => {
  const [stats, setStats] = useState({
    totalLogins: 0,
    lastLogin: null,
    securityScore: 95,
    memberSince: null
  });

  const [recentActivity, setRecentActivity] = useState([]);

  useEffect(() => {
    // Simulate loading dashboard data
    const loadDashboardData = () => {
      setStats({
        totalLogins: Math.floor(Math.random() * 100) + 50,
        lastLogin: new Date().toISOString(),
        securityScore: Math.floor(Math.random() * 20) + 80,
        memberSince: new Date(Date.now() - Math.random() * 365 * 24 * 60 * 60 * 1000).toISOString()
      });

      setRecentActivity([
        {
          id: 1,
          type: 'login',
          description: 'Biometric login successful',
          timestamp: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString(),
          icon: FaFingerprint,
          status: 'success'
        },
        {
          id: 2,
          type: 'profile',
          description: 'Profile information updated',
          timestamp: new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString(),
          icon: FaUser,
          status: 'info'
        },
        {
          id: 3,
          type: 'security',
          description: 'Security scan completed',
          timestamp: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000).toISOString(),
          icon: FaShieldAlt,
          status: 'success'
        }
      ]);
    };

    loadDashboardData();
  }, []);

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const getTimeAgo = (dateString) => {
    const now = new Date();
    const date = new Date(dateString);
    const diffInHours = Math.floor((now - date) / (1000 * 60 * 60));

    if (diffInHours < 1) return 'Just now';
    if (diffInHours < 24) return `${diffInHours}h ago`;
    const diffInDays = Math.floor(diffInHours / 24);
    if (diffInDays < 30) return `${diffInDays}d ago`;
    const diffInMonths = Math.floor(diffInDays / 30);
    return `${diffInMonths}mo ago`;
  };

  const getSecurityScoreColor = (score) => {
    if (score >= 90) return '#10b981';
    if (score >= 70) return '#f59e0b';
    return '#ef4444';
  };

  return (
    <div className="dashboard-container">
      <div className="dashboard-header">
        <div className="welcome-section">
          <h1>Welcome back, {user.name}!</h1>
          <p>Here's your security overview and recent activity</p>
        </div>
        <div className="header-actions">
          <button className="btn btn-secondary">
            <FaBell />
            Notifications
          </button>
        </div>
      </div>

      <div className="dashboard-grid">
        {/* Stats Cards */}
        <div className="stats-grid">
          <div className="stat-card card">
            <div className="stat-icon">
              <FaFingerprint />
            </div>
            <div className="stat-content">
              <h3>{stats.totalLogins}</h3>
              <p>Total Logins</p>
            </div>
          </div>

          <div className="stat-card card">
            <div className="stat-icon">
              <FaClock />
            </div>
            <div className="stat-content">
              <h3>{stats.lastLogin ? getTimeAgo(stats.lastLogin) : 'Never'}</h3>
              <p>Last Login</p>
            </div>
          </div>

          <div className="stat-card card">
            <div className="stat-icon">
              <FaShieldAlt />
            </div>
            <div className="stat-content">
              <h3 style={{ color: getSecurityScoreColor(stats.securityScore) }}>
                {stats.securityScore}%
              </h3>
              <p>Security Score</p>
            </div>
          </div>

          <div className="stat-card card">
            <div className="stat-icon">
              <FaCalendarAlt />
            </div>
            <div className="stat-content">
              <h3>{stats.memberSince ? getTimeAgo(stats.memberSince) : 'Recently'}</h3>
              <p>Member Since</p>
            </div>
          </div>
        </div>

        {/* User Info Card */}
        <div className="user-info-card card">
          <div className="card-header">
            <h2>Account Information</h2>
            <FaUser className="header-icon" />
          </div>
          <div className="user-info-content">
            <div className="user-avatar-large">
              {user.name.charAt(0).toUpperCase()}
            </div>
            <div className="user-details-large">
              <h3>{user.name}</h3>
              {user.email && <p className="user-email">{user.email}</p>}
              <div className="membership-badge">
                <FaIdCard />
                <span>{user.membership} Member</span>
              </div>
              <div className="login-method">
                <FaFingerprint />
                <span>Biometric Authentication Enabled</span>
              </div>
            </div>
          </div>
        </div>

        {/* Recent Activity */}
        <div className="activity-card card">
          <div className="card-header">
            <h2>Recent Activity</h2>
            <FaChartLine className="header-icon" />
          </div>
          <div className="activity-list">
            {recentActivity.map((activity) => (
              <div key={activity.id} className="activity-item">
                <div className={`activity-icon ${activity.status}`}>
                  <activity.icon />
                </div>
                <div className="activity-content">
                  <p className="activity-description">{activity.description}</p>
                  <span className="activity-time">{getTimeAgo(activity.timestamp)}</span>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Security Overview */}
        <div className="security-card card">
          <div className="card-header">
            <h2>Security Overview</h2>
            <FaShieldAlt className="header-icon" />
          </div>
          <div className="security-content">
            <div className="security-score-circle">
              <div
                className="score-circle"
                style={{
                  background: `conic-gradient(${getSecurityScoreColor(stats.securityScore)} ${stats.securityScore * 3.6}deg, rgba(71, 85, 105, 0.3) 0deg)`
                }}
              >
                <div className="score-inner">
                  <span className="score-value">{stats.securityScore}%</span>
                  <span className="score-label">Secure</span>
                </div>
              </div>
            </div>
            <div className="security-features">
              <div className="security-feature">
                <FaFingerprint className="feature-icon enabled" />
                <span>Biometric Authentication</span>
                <span className="feature-status enabled">Enabled</span>
              </div>
              <div className="security-feature">
                <FaShieldAlt className="feature-icon enabled" />
                <span>Account Protection</span>
                <span className="feature-status enabled">Active</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
