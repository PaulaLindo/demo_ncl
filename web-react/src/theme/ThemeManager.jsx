// src/theme/ThemeManager.jsx - React Theme Management System
import React, { createContext, useContext, useState, useEffect } from 'react';

// Theme definitions
export const themes = {
  purpleGold: {
    name: 'Purple & Gold',
    colors: {
      primary: '#5D3F6A',
      primaryLight: '#8B6B9F',
      primaryDark: '#3E2A4A',
      secondary: '#2C2C2C',
      accent: '#EECB05',
      accentLight: '#F5D85E',
      accentDark: '#C9A804',
      background: '#F5F5F5',
      surface: '#FFFFFF',
      border: '#E0E0E0',
      text: '#333333',
      textSecondary: '#666666',
      textMuted: '#868686',
      success: '#4CAF50',
      warning: '#f59e0b',
      error: '#F44336',
      info: '#3b82f6',
    },
    gradients: {
      primary: 'linear-gradient(135deg, #5D3F6A 0%, #8B6B9F 100%)',
      accent: 'linear-gradient(135deg, #EECB05 0%, #F5D85E 100%)',
      hero: 'linear-gradient(135deg, #5D3F6A 0%, #EECB05 100%)',
    },
    shadows: {
      small: '0 1px 3px rgba(0, 0, 0, 0.12), 0 1px 2px rgba(0, 0, 0, 0.24)',
      medium: '0 4px 6px rgba(0, 0, 0, 0.1), 0 2px 4px rgba(0, 0, 0, 0.06)',
      large: '0 10px 25px rgba(0, 0, 0, 0.1), 0 6px 10px rgba(0, 0, 0, 0.08)',
    },
  },
  navyGold: {
    name: 'Navy & Gold',
    colors: {
      primary: '#1E3A8A',
      primaryLight: '#3B5BA8',
      primaryDark: '#1E2F5A',
      secondary: '#1F2937',
      accent: '#EAB308',
      accentLight: '#FCD34D',
      accentDark: '#CA8A04',
      background: '#F8FAFC',
      surface: '#FFFFFF',
      border: '#E5E7EB',
      text: '#1F2937',
      textSecondary: '#4B5563',
      textMuted: '#6B7280',
      success: '#10B981',
      warning: '#F59E0B',
      error: '#EF4444',
      info: '#3B82F6',
    },
    gradients: {
      primary: 'linear-gradient(135deg, #1E3A8A 0%, #3B5BA8 100%)',
      accent: 'linear-gradient(135deg, #EAB308 0%, #FCD34D 100%)',
      hero: 'linear-gradient(135deg, #1E3A8A 0%, #EAB308 100%)',
    },
    shadows: {
      small: '0 1px 3px rgba(0, 0, 0, 0.12), 0 1px 2px rgba(0, 0, 0, 0.24)',
      medium: '0 4px 6px rgba(0, 0, 0, 0.1), 0 2px 4px rgba(0, 0, 0, 0.06)',
      large: '0 10px 25px rgba(0, 0, 0, 0.1), 0 6px 10px rgba(0, 0, 0, 0.08)',
    },
  },
};

// Theme context
const ThemeContext = createContext();

// Theme provider component
export const ThemeProvider = ({ children }) => {
  const [currentTheme, setCurrentTheme] = useState('purpleGold');
  const [theme, setTheme] = useState(themes.purpleGold);

  // Load saved theme from localStorage
  useEffect(() => {
    const savedTheme = localStorage.getItem('ncl-theme');
    if (savedTheme && themes[savedTheme]) {
      setCurrentTheme(savedTheme);
      setTheme(themes[savedTheme]);
    }
  }, []);

  // Update theme and save to localStorage
  const updateTheme = (themeName) => {
    if (themes[themeName]) {
      setCurrentTheme(themeName);
      setTheme(themes[themeName]);
      localStorage.setItem('ncl-theme', themeName);
      
      // Update CSS custom properties
      updateCSSVariables(themes[themeName]);
    }
  };

  // Update CSS custom properties for dynamic theming
  const updateCSSVariables = (themeData) => {
    const root = document.documentElement;
    Object.entries(themeData.colors).forEach(([key, value]) => {
      root.style.setProperty(`--color-${key}`, value);
    });
    
    Object.entries(themeData.gradients).forEach(([key, value]) => {
      root.style.setProperty(`--gradient-${key}`, value);
    });
    
    Object.entries(themeData.shadows).forEach(([key, value]) => {
      root.style.setProperty(`--shadow-${key}`, value);
    });
  };

  // Apply theme on mount and theme change
  useEffect(() => {
    updateCSSVariables(theme);
  }, [theme]);

  const value = {
    currentTheme,
    theme,
    themes,
    updateTheme,
  };

  return (
    <ThemeContext.Provider value={value}>
      {children}
    </ThemeContext.Provider>
  );
};

// Hook to use theme
export const useTheme = () => {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useTheme must be used within a ThemeProvider');
  }
  return context;
};

// Theme utilities
export const getThemeClasses = (theme, type) => {
  const themeClasses = {
    purpleGold: {
      primary: 'bg-purple-800 hover:bg-purple-900 text-white',
      secondary: 'bg-gray-800 hover:bg-gray-900 text-white',
      accent: 'bg-yellow-500 hover:bg-yellow-600 text-gray-900',
      surface: 'bg-white border-gray-200',
      text: 'text-gray-900',
      textSecondary: 'text-gray-600',
      textMuted: 'text-gray-500',
    },
    navyGold: {
      primary: 'bg-blue-800 hover:bg-blue-900 text-white',
      secondary: 'bg-gray-800 hover:bg-gray-900 text-white',
      accent: 'bg-yellow-500 hover:bg-yellow-600 text-gray-900',
      surface: 'bg-white border-gray-200',
      text: 'text-gray-900',
      textSecondary: 'text-gray-600',
      textMuted: 'text-gray-500',
    },
  };

  return themeClasses[theme.currentTheme]?.[type] || themeClasses.purpleGold[type];
};

export default ThemeContext;
