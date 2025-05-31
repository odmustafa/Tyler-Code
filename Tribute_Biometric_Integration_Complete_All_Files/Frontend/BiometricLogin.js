import axios from 'axios';
import React, { useState } from 'react';

function BiometricLogin() {
  const [status, setStatus] = useState("");

  const handleLogin = async () => {
    const scan = prompt("Enter fingerprint scan (test input):");
    try {
      const response = await axios.post('http://localhost:5000/login', { fingerprint_scan: scan });
      setStatus(`${response.data.message} - Membership: ${response.data.membership}`);
    } catch (error) {
      setStatus("Authentication failed");
    }
  };

  return (
    <div>
      <h2>Biometric Login</h2>
      <button onClick={handleLogin}>Scan & Login</button>
      <p>{status}</p>
    </div>
  );
}

export default BiometricLogin;
