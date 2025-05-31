/**
 * Fingerprint Service Client
 * Communicates with the Windows fingerprint service running on the local network
 */

class FingerprintService {
  constructor() {
    // Default to localhost, but can be configured for network access
    this.baseUrl = this.detectFingerprintServiceUrl();
    this.isConnected = false;
    this.lastError = null;
  }

  /**
   * Detect the fingerprint service URL
   * Tries localhost first, then attempts to detect network service
   */
  detectFingerprintServiceUrl() {
    // Check if we're running on the same machine as the fingerprint service
    const hostname = window.location.hostname;
    
    // If accessing from localhost/127.0.0.1, try localhost first
    if (hostname === 'localhost' || hostname === '127.0.0.1') {
      return 'http://localhost:5001';
    }
    
    // If accessing from network, try to detect Windows PC IP
    // This can be configured based on your network setup
    const possibleIPs = [
      'http://192.168.1.100:5001',  // Common router IP range
      'http://192.168.0.100:5001',  // Alternative router IP range
      'http://10.0.0.100:5001',     // Another common range
      'http://localhost:5001'       // Fallback to localhost
    ];
    
    // For now, return localhost - this can be configured
    return 'http://localhost:5001';
  }

  /**
   * Set the fingerprint service URL manually
   */
  setServiceUrl(url) {
    this.baseUrl = url;
    this.isConnected = false;
  }

  /**
   * Check if the fingerprint service is available
   */
  async checkConnection() {
    try {
      const response = await fetch(`${this.baseUrl}/api/fingerprint/status`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
        },
        // Add timeout
        signal: AbortSignal.timeout(5000)
      });

      if (response.ok) {
        const data = await response.json();
        this.isConnected = true;
        this.lastError = null;
        return {
          connected: true,
          status: data
        };
      } else {
        throw new Error(`Service responded with status: ${response.status}`);
      }
    } catch (error) {
      this.isConnected = false;
      this.lastError = error.message;
      
      return {
        connected: false,
        error: error.message,
        suggestion: this.getConnectionSuggestion(error)
      };
    }
  }

  /**
   * Get connection suggestion based on error type
   */
  getConnectionSuggestion(error) {
    if (error.message.includes('Failed to fetch') || error.message.includes('NetworkError')) {
      return 'Make sure the Windows fingerprint service is running and accessible on the network.';
    }
    if (error.message.includes('timeout')) {
      return 'The fingerprint service is taking too long to respond. Check network connectivity.';
    }
    return 'Unable to connect to the fingerprint service. Please check the service status.';
  }

  /**
   * Initialize the fingerprint device
   */
  async initializeDevice() {
    try {
      const response = await fetch(`${this.baseUrl}/api/fingerprint/initialize`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        signal: AbortSignal.timeout(10000)
      });

      const data = await response.json();

      if (response.ok) {
        return {
          success: true,
          message: data.message
        };
      } else {
        throw new Error(data.error || 'Failed to initialize device');
      }
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  /**
   * Capture a fingerprint
   */
  async captureFingerprint() {
    try {
      // First check connection
      const connectionCheck = await this.checkConnection();
      if (!connectionCheck.connected) {
        throw new Error(`Service not available: ${connectionCheck.error}`);
      }

      const response = await fetch(`${this.baseUrl}/api/fingerprint/capture`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        signal: AbortSignal.timeout(30000) // 30 second timeout for capture
      });

      const data = await response.json();

      if (response.ok) {
        return {
          success: true,
          template: data.template,
          timestamp: data.timestamp
        };
      } else {
        throw new Error(data.error || 'Failed to capture fingerprint');
      }
    } catch (error) {
      return {
        success: false,
        error: error.message,
        suggestion: this.getCaptureSuggestion(error)
      };
    }
  }

  /**
   * Get capture suggestion based on error type
   */
  getCaptureSuggestion(error) {
    if (error.message.includes('timeout')) {
      return 'Fingerprint capture timed out. Please place your finger on the scanner and try again.';
    }
    if (error.message.includes('Device not opened')) {
      return 'The fingerprint device is not properly initialized. Please check the device connection.';
    }
    if (error.message.includes('Failed to capture image')) {
      return 'Unable to capture fingerprint image. Please clean the scanner and try again.';
    }
    return 'Please ensure your finger is properly placed on the scanner and try again.';
  }

  /**
   * Match two fingerprint templates
   */
  async matchTemplates(template1, template2) {
    try {
      const response = await fetch(`${this.baseUrl}/api/fingerprint/match`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          template1: template1,
          template2: template2
        }),
        signal: AbortSignal.timeout(10000)
      });

      const data = await response.json();

      if (response.ok) {
        return {
          success: true,
          matched: data.matched,
          timestamp: data.timestamp
        };
      } else {
        throw new Error(data.error || 'Failed to match templates');
      }
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  /**
   * Simulate fingerprint capture (fallback when service is not available)
   */
  simulateFingerprint() {
    return new Promise((resolve) => {
      setTimeout(() => {
        // Generate a mock template
        const mockTemplate = btoa(`mock_template_${Date.now()}_${Math.random()}`);
        resolve({
          success: true,
          template: mockTemplate,
          timestamp: Date.now(),
          simulated: true
        });
      }, 2000); // Simulate 2-second capture time
    });
  }

  /**
   * Get service information
   */
  getServiceInfo() {
    return {
      baseUrl: this.baseUrl,
      isConnected: this.isConnected,
      lastError: this.lastError
    };
  }

  /**
   * Auto-detect and configure service URL from network
   */
  async autoDetectService() {
    const possibleUrls = [
      'http://localhost:5001',
      'http://127.0.0.1:5001',
      'http://192.168.1.100:5001',
      'http://192.168.1.101:5001',
      'http://192.168.1.102:5001',
      'http://192.168.0.100:5001',
      'http://192.168.0.101:5001',
      'http://192.168.0.102:5001',
      'http://10.0.0.100:5001',
      'http://10.0.0.101:5001',
      'http://10.0.0.102:5001'
    ];

    for (const url of possibleUrls) {
      try {
        this.setServiceUrl(url);
        const result = await this.checkConnection();
        if (result.connected) {
          console.log(`Fingerprint service found at: ${url}`);
          return {
            success: true,
            url: url,
            status: result.status
          };
        }
      } catch (error) {
        // Continue to next URL
        continue;
      }
    }

    return {
      success: false,
      error: 'No fingerprint service found on the network'
    };
  }
}

// Create singleton instance
const fingerprintService = new FingerprintService();

export default fingerprintService;
