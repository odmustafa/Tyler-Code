import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';
import { FaFingerprint, FaUser, FaEnvelope, FaIdCard, FaEye, FaEyeSlash, FaLock } from 'react-icons/fa';
import LoadingSpinner from './LoadingSpinner';
import './Register.css';

const Register = ({ onRegister, darkMode }) => {
  const [step, setStep] = useState(1); // 1: Personal Info, 2: Biometric Setup
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    membershipType: 'Standard',
    password: '',
    confirmPassword: '',
    fingerprintScan: ''
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [scanningFingerprint, setScanningFingerprint] = useState(false);

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
  };

  const validateStep1 = () => {
    if (!formData.name.trim()) {
      setError('Name is required');
      return false;
    }
    if (!formData.email.trim()) {
      setError('Email is required');
      return false;
    }
    if (!/\S+@\S+\.\S+/.test(formData.email)) {
      setError('Please enter a valid email address');
      return false;
    }
    if (formData.password.length < 6) {
      setError('Password must be at least 6 characters');
      return false;
    }
    if (formData.password !== formData.confirmPassword) {
      setError('Passwords do not match');
      return false;
    }
    return true;
  };

  const handleNextStep = () => {
    if (validateStep1()) {
      setStep(2);
      setError('');
    }
  };

  const simulateFingerprintScan = () => {
    setScanningFingerprint(true);
    setError('');

    // Simulate fingerprint scanning process
    setTimeout(() => {
      const mockFingerprint = `fp_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
      setFormData({
        ...formData,
        fingerprintScan: mockFingerprint
      });
      setScanningFingerprint(false);
    }, 2500);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!formData.fingerprintScan) {
      setError('Please scan your fingerprint to complete registration');
      return;
    }

    setLoading(true);
    setError('');

    try {
      const response = await axios.post('http://localhost:5000/register', {
        name: formData.name,
        email: formData.email,
        membership_type: formData.membershipType,
        fingerprint_scan: formData.fingerprintScan
      });

      if (response.data.message) {
        onRegister({
          name: formData.name,
          email: formData.email,
          membership: formData.membershipType,
          loginMethod: 'registration'
        });
      }
    } catch (error) {
      setError(error.response?.data?.error || 'Registration failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="register-container">
      <div className="register-card card fade-in">
        <div className="register-header">
          <div className="logo">
            <FaFingerprint className="logo-icon" />
            <h1>Join Tribute</h1>
          </div>
          <p className="subtitle">Create your secure biometric account</p>
        </div>

        <div className="progress-bar">
          <div className={`progress-step ${step >= 1 ? 'active' : ''}`}>
            <div className="step-number">1</div>
            <span>Personal Info</span>
          </div>
          <div className="progress-line"></div>
          <div className={`progress-step ${step >= 2 ? 'active' : ''}`}>
            <div className="step-number">2</div>
            <span>Biometric Setup</span>
          </div>
        </div>

        {step === 1 ? (
          <form onSubmit={(e) => { e.preventDefault(); handleNextStep(); }} className="register-form">
            <div className="input-group">
              <label>Full Name</label>
              <div className="input-wrapper">
                <FaUser className="input-icon" />
                <input
                  type="text"
                  name="name"
                  placeholder="Enter your full name"
                  value={formData.name}
                  onChange={handleInputChange}
                  className="input-field"
                  required
                />
              </div>
            </div>

            <div className="input-group">
              <label>Email Address</label>
              <div className="input-wrapper">
                <FaEnvelope className="input-icon" />
                <input
                  type="email"
                  name="email"
                  placeholder="Enter your email"
                  value={formData.email}
                  onChange={handleInputChange}
                  className="input-field"
                  required
                />
              </div>
            </div>

            <div className="input-group">
              <label>Membership Type</label>
              <div className="membership-grid">
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
            </div>

            <div className="input-group">
              <label>Password</label>
              <div className="input-wrapper">
                <FaLock className="input-icon" />
                <input
                  type={showPassword ? 'text' : 'password'}
                  name="password"
                  placeholder="Create a password"
                  value={formData.password}
                  onChange={handleInputChange}
                  className="input-field"
                  required
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="password-toggle"
                >
                  {showPassword ? <FaEyeSlash /> : <FaEye />}
                </button>
              </div>
            </div>

            <div className="input-group">
              <label>Confirm Password</label>
              <div className="input-wrapper">
                <FaLock className="input-icon" />
                <input
                  type={showConfirmPassword ? 'text' : 'password'}
                  name="confirmPassword"
                  placeholder="Confirm your password"
                  value={formData.confirmPassword}
                  onChange={handleInputChange}
                  className="input-field"
                  required
                />
                <button
                  type="button"
                  onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                  className="password-toggle"
                >
                  {showConfirmPassword ? <FaEyeSlash /> : <FaEye />}
                </button>
              </div>
            </div>

            {error && <div className="error-message">{error}</div>}

            <button type="submit" className="btn btn-primary next-btn">
              Continue to Biometric Setup
            </button>
          </form>
        ) : (
          <form onSubmit={handleSubmit} className="register-form">
            <div className="biometric-setup">
              <h3>Biometric Authentication Setup</h3>
              <p>Scan your fingerprint to secure your account</p>

              <div className="fingerprint-section">
                <div className={`fingerprint-scanner ${scanningFingerprint ? 'scanning' : ''}`}>
                  <FaFingerprint
                    className={`fingerprint-icon ${formData.fingerprintScan ? 'scanned' : ''} ${scanningFingerprint ? 'fingerprint-pulse' : ''}`}
                  />
                  {scanningFingerprint && <div className="scan-overlay">Scanning...</div>}
                </div>

                <button
                  type="button"
                  onClick={simulateFingerprintScan}
                  disabled={scanningFingerprint || loading}
                  className="btn btn-secondary scan-btn"
                >
                  {scanningFingerprint ? 'Scanning...' : 'Scan Fingerprint'}
                </button>

                {formData.fingerprintScan && (
                  <div className="scan-success">
                    ✓ Fingerprint registered successfully
                  </div>
                )}
              </div>
            </div>

            {error && <div className="error-message">{error}</div>}

            <div className="form-actions">
              <button
                type="button"
                onClick={() => setStep(1)}
                className="btn btn-secondary back-btn"
              >
                Back
              </button>
              <button
                type="submit"
                disabled={loading || !formData.fingerprintScan}
                className="btn btn-primary register-btn"
              >
                {loading ? <LoadingSpinner size="small" /> : 'Complete Registration'}
              </button>
            </div>
          </form>
        )}

        <div className="register-footer">
          <p>
            Already have an account?{' '}
            <Link to="/login" className="link">
              Sign in here
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
};

export default Register;
