import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';
import { FaFingerprint, FaEye, FaEyeSlash, FaUser, FaLock, FaWifi, FaExclamationTriangle } from 'react-icons/fa';
import LoadingSpinner from './LoadingSpinner';
import fingerprintService from '../utils/FingerprintService';
import './Login.css';

const Login = ({ onLogin, darkMode }) => {
  const [loginMethod, setLoginMethod] = useState('biometric'); // 'biometric' or 'password'
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    fingerprintScan: ''
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [scanningFingerprint, setScanningFingerprint] = useState(false);
  const [serviceStatus, setServiceStatus] = useState({
    connected: false,
    checking: true,
    error: null
  });

  // Check fingerprint service status on component mount
  useEffect(() => {
    checkFingerprintService();
  }, []);

  const checkFingerprintService = async () => {
    setServiceStatus({ connected: false, checking: true, error: null });

    try {
      const result = await fingerprintService.checkConnection();
      setServiceStatus({
        connected: result.connected,
        checking: false,
        error: result.connected ? null : result.error
      });
    } catch (error) {
      setServiceStatus({
        connected: false,
        checking: false,
        error: error.message
      });
    }
  };

  const handleInputChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
    setError('');
  };

  const handleFingerprintScan = async () => {
    setScanningFingerprint(true);
    setError('');

    try {
      let result;

      if (serviceStatus.connected) {
        // Use real fingerprint service
        result = await fingerprintService.captureFingerprint();
      } else {
        // Fallback to simulation
        result = await fingerprintService.simulateFingerprint();
      }

      if (result.success) {
        setFormData({
          ...formData,
          fingerprintScan: result.template
        });

        if (result.simulated) {
          setError('Using simulated fingerprint (hardware service not available)');
        }
      } else {
        setError(result.error || 'Failed to capture fingerprint');
        if (result.suggestion) {
          setError(`${result.error}. ${result.suggestion}`);
        }
      }
    } catch (error) {
      setError(`Fingerprint capture failed: ${error.message}`);
    } finally {
      setScanningFingerprint(false);
    }
  };

  const handleBiometricLogin = async (e) => {
    e.preventDefault();

    if (!formData.fingerprintScan) {
      setError('Please scan your fingerprint first');
      return;
    }

    setLoading(true);
    setError('');

    try {
      const response = await axios.post('http://localhost:5000/login', {
        fingerprint_scan: formData.fingerprintScan
      });

      if (response.data.message) {
        onLogin({
          name: response.data.message.replace('Welcome ', ''),
          membership: response.data.membership,
          loginMethod: 'biometric'
        });
      }
    } catch (error) {
      setError(error.response?.data?.error || 'Authentication failed');
    } finally {
      setLoading(false);
    }
  };

  const handlePasswordLogin = async (e) => {
    e.preventDefault();

    if (!formData.email || !formData.password) {
      setError('Please enter both email and password');
      return;
    }

    setLoading(true);
    setError('');

    try {
      // For demo purposes, simulate password login
      // In a real app, you'd have a separate password login endpoint
      setTimeout(() => {
        onLogin({
          name: formData.email.split('@')[0],
          email: formData.email,
          membership: 'Standard',
          loginMethod: 'password'
        });
        setLoading(false);
      }, 1500);
    } catch (error) {
      setError('Login failed');
      setLoading(false);
    }
  };

  return (
    <div className="login-container">
      <div className="login-card card fade-in">
        <div className="login-header">
          <div className="logo">
            <FaFingerprint className="logo-icon" />
            <h1>Tribute Access</h1>
          </div>
          <p className="subtitle">Secure biometric authentication</p>
        </div>

        <div className="login-method-toggle">
          <button
            type="button"
            className={`method-btn ${loginMethod === 'biometric' ? 'active' : ''}`}
            onClick={() => setLoginMethod('biometric')}
          >
            <FaFingerprint />
            Biometric
          </button>
          <button
            type="button"
            className={`method-btn ${loginMethod === 'password' ? 'active' : ''}`}
            onClick={() => setLoginMethod('password')}
          >
            <FaLock />
            Password
          </button>
        </div>

        {loginMethod === 'biometric' ? (
          <form onSubmit={handleBiometricLogin} className="login-form">
            {/* Service Status Indicator */}
            <div className="service-status">
              {serviceStatus.checking ? (
                <div className="status-indicator checking">
                  <LoadingSpinner size="small" />
                  <span>Checking fingerprint service...</span>
                </div>
              ) : serviceStatus.connected ? (
                <div className="status-indicator connected">
                  <FaWifi />
                  <span>Hardware fingerprint scanner connected</span>
                </div>
              ) : (
                <div className="status-indicator disconnected">
                  <FaExclamationTriangle />
                  <span>Using simulation mode (hardware not available)</span>
                  <button
                    type="button"
                    onClick={checkFingerprintService}
                    className="retry-btn"
                  >
                    Retry
                  </button>
                </div>
              )}
            </div>

            <div className="fingerprint-section">
              <div className={`fingerprint-scanner ${scanningFingerprint ? 'scanning' : ''}`}>
                <FaFingerprint
                  className={`fingerprint-icon ${formData.fingerprintScan ? 'scanned' : ''} ${scanningFingerprint ? 'fingerprint-pulse' : ''}`}
                />
                {scanningFingerprint && <div className="scan-overlay">Scanning...</div>}
              </div>

              <button
                type="button"
                onClick={handleFingerprintScan}
                disabled={scanningFingerprint || loading}
                className="btn btn-secondary scan-btn"
              >
                {scanningFingerprint ? 'Scanning...' : 'Scan Fingerprint'}
              </button>

              {formData.fingerprintScan && (
                <div className="scan-success">
                  ✓ Fingerprint captured successfully
                </div>
              )}
            </div>

            {error && <div className="error-message">{error}</div>}

            <button
              type="submit"
              disabled={loading || !formData.fingerprintScan}
              className="btn btn-primary login-btn"
            >
              {loading ? <LoadingSpinner size="small" /> : 'Authenticate'}
            </button>
          </form>
        ) : (
          <form onSubmit={handlePasswordLogin} className="login-form">
            <div className="input-group">
              <div className="input-wrapper">
                <FaUser className="input-icon" />
                <input
                  type="email"
                  name="email"
                  placeholder="Email address"
                  value={formData.email}
                  onChange={handleInputChange}
                  className="input-field"
                  required
                />
              </div>
            </div>

            <div className="input-group">
              <div className="input-wrapper">
                <FaLock className="input-icon" />
                <input
                  type={showPassword ? 'text' : 'password'}
                  name="password"
                  placeholder="Password"
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

            {error && <div className="error-message">{error}</div>}

            <button
              type="submit"
              disabled={loading}
              className="btn btn-primary login-btn"
            >
              {loading ? <LoadingSpinner size="small" /> : 'Sign In'}
            </button>
          </form>
        )}

        <div className="login-footer">
          <p>
            Don't have an account?{' '}
            <Link to="/register" className="link">
              Register here
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
};

export default Login;
