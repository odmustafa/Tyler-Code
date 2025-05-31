import React from 'react';
import './LoadingSpinner.css';

const LoadingSpinner = ({ size = 'medium', color = '#3b82f6' }) => {
  return (
    <div className={`loading-spinner ${size}`}>
      <div 
        className="spinner" 
        style={{ borderTopColor: color }}
      ></div>
    </div>
  );
};

export default LoadingSpinner;
