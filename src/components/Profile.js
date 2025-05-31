import React, { useState } from 'react';
import { 
  FaUser, 
  FaEnvelope, 
  FaIdCard, 
  FaFingerprint, 
  FaEdit, 
  FaSave, 
  FaTimes,
  FaShieldAlt,
  FaKey,
  FaTrash
} from 'react-icons/fa';
import LoadingSpinner from './LoadingSpinner';
import './Profile.css';

const Profile = ({ user, setUser, darkMode }) => {
  const [isEditing, setIsEditing] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [formData, setFormData] = useState({
    name: user.name || '',
    email: user.email || '',
    membershipType: user.membership || 'Standard'
  });

  const membershipTypes = [
    { value: 'Basic', label: 'Basic', description: 'Standard access' },
    { value: 'Standard', label: 'Standard', description: 'Enhanced features' },
    { value: 'Premium', label: 'Premium', description: 'Full access' },
    { value: 'VIP', label: 'VIP', description: 'Exclusive benefits' }
  ];

  const handleInputChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
    setError('');
    setSuccess('');
  };

  const handleSave = async () => {
    if (!formData.name.trim()) {
      setError('Name is required');
      return;
    }

    if (!formData.email.trim()) {
      setError('Email is required');
      return;
    }

    if (!/\S+@\S+\.\S+/.test(formData.email)) {
      setError('Please enter a valid email address');
      return;
    }

    setLoading(true);
    setError('');

    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 1500));
      
      // Update user data
      const updatedUser = {
        ...user,
        name: formData.name,
        email: formData.email,
        membership: formData.membershipType
      };
      
      setUser(updatedUser);
      localStorage.setItem('tributeUser', JSON.stringify(updatedUser));
      
      setSuccess('Profile updated successfully!');
      setIsEditing(false);
    } catch (error) {
      setError('Failed to update profile');
    } finally {
      setLoading(false);
    }
  };

  const handleCancel = () => {
    setFormData({
      name: user.name || '',
      email: user.email || '',
      membershipType: user.membership || 'Standard'
    });
    setIsEditing(false);
    setError('');
    setSuccess('');
  };

  const handleRegenerateFingerprint = async () => {
    setLoading(true);
    try {
      // Simulate fingerprint regeneration
      await new Promise(resolve => setTimeout(resolve, 2000));
      setSuccess('Fingerprint template regenerated successfully!');
    } catch (error) {
      setError('Failed to regenerate fingerprint');
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteAccount = () => {
    if (window.confirm('Are you sure you want to delete your account? This action cannot be undone.')) {
      // In a real app, this would call an API to delete the account
      localStorage.removeItem('tributeUser');
      window.location.reload();
    }
  };

  return (
    <div className="profile-container">
      <div className="profile-header">
        <h1>Profile Settings</h1>
        <p>Manage your account information and security settings</p>
      </div>

      <div className="profile-grid">
        {/* Profile Information Card */}
        <div className="profile-info-card card">
          <div className="card-header">
            <h2>Personal Information</h2>
            {!isEditing ? (
              <button
                onClick={() => setIsEditing(true)}
                className="btn btn-secondary edit-btn"
              >
                <FaEdit />
                Edit
              </button>
            ) : (
              <div className="edit-actions">
                <button
                  onClick={handleSave}
                  disabled={loading}
                  className="btn btn-primary save-btn"
                >
                  {loading ? <LoadingSpinner size="small" /> : <><FaSave /> Save</>}
                </button>
                <button
                  onClick={handleCancel}
                  className="btn btn-secondary cancel-btn"
                >
                  <FaTimes />
                  Cancel
                </button>
              </div>
            )}
          </div>

          <div className="profile-content">
            <div className="profile-avatar-section">
              <div className="profile-avatar">
                {(formData.name || user.name).charAt(0).toUpperCase()}
              </div>
              <div className="avatar-info">
                <h3>{formData.name || user.name}</h3>
                <p className="membership-type">{formData.membershipType} Member</p>
              </div>
            </div>

            <div className="profile-fields">
              <div className="field-group">
                <label>Full Name</label>
                {isEditing ? (
                  <div className="input-wrapper">
                    <FaUser className="input-icon" />
                    <input
                      type="text"
                      name="name"
                      value={formData.name}
                      onChange={handleInputChange}
                      className="input-field"
                      placeholder="Enter your full name"
                    />
                  </div>
                ) : (
                  <div className="field-display">
                    <FaUser className="field-icon" />
                    <span>{user.name}</span>
                  </div>
                )}
              </div>

              <div className="field-group">
                <label>Email Address</label>
                {isEditing ? (
                  <div className="input-wrapper">
                    <FaEnvelope className="input-icon" />
                    <input
                      type="email"
                      name="email"
                      value={formData.email}
                      onChange={handleInputChange}
                      className="input-field"
                      placeholder="Enter your email"
                    />
                  </div>
                ) : (
                  <div className="field-display">
                    <FaEnvelope className="field-icon" />
                    <span>{user.email || 'Not provided'}</span>
                  </div>
                )}
              </div>

              <div className="field-group">
                <label>Membership Type</label>
                {isEditing ? (
                  <div className="membership-select">
                    {membershipTypes.map((type) => (
                      <label key={type.value} className="membership-option">
                        <input
                          type="radio"
                          name="membershipType"
                          value={type.value}
                          checked={formData.membershipType === type.value}
                          onChange={handleInputChange}
                        />
                        <div className="membership-card">
                          <FaIdCard className="membership-icon" />
                          <div className="membership-info">
                            <h4>{type.label}</h4>
                            <p>{type.description}</p>
                          </div>
                        </div>
                      </label>
                    ))}
                  </div>
                ) : (
                  <div className="field-display">
                    <FaIdCard className="field-icon" />
                    <span>{user.membership} Member</span>
                  </div>
                )}
              </div>
            </div>

            {(error || success) && (
              <div className={`message ${error ? 'error' : 'success'}`}>
                {error || success}
              </div>
            )}
          </div>
        </div>

        {/* Security Settings Card */}
        <div className="security-card card">
          <div className="card-header">
            <h2>Security Settings</h2>
            <FaShieldAlt className="header-icon" />
          </div>

          <div className="security-content">
            <div className="security-section">
              <div className="security-item">
                <div className="security-info">
                  <FaFingerprint className="security-icon" />
                  <div>
                    <h4>Biometric Authentication</h4>
                    <p>Your fingerprint is securely stored and encrypted</p>
                  </div>
                </div>
                <button
                  onClick={handleRegenerateFingerprint}
                  disabled={loading}
                  className="btn btn-secondary"
                >
                  {loading ? <LoadingSpinner size="small" /> : 'Regenerate'}
                </button>
              </div>

              <div className="security-item">
                <div className="security-info">
                  <FaKey className="security-icon" />
                  <div>
                    <h4>Password Protection</h4>
                    <p>Change your account password</p>
                  </div>
                </div>
                <button className="btn btn-secondary">
                  Change Password
                </button>
              </div>
            </div>
          </div>
        </div>

        {/* Danger Zone Card */}
        <div className="danger-card card">
          <div className="card-header">
            <h2>Danger Zone</h2>
            <FaTrash className="header-icon danger" />
          </div>

          <div className="danger-content">
            <div className="danger-item">
              <div className="danger-info">
                <h4>Delete Account</h4>
                <p>Permanently delete your account and all associated data. This action cannot be undone.</p>
              </div>
              <button
                onClick={handleDeleteAccount}
                className="btn btn-danger"
              >
                <FaTrash />
                Delete Account
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Profile;
