// src/components/ThemeSelector.jsx - Theme selection component
import React, { useState } from 'react';
import { useTheme } from '../theme/ThemeManager.jsx';
import { ThemeButton, ThemeCard } from './ThemeComponents.jsx';

export const ThemeSelector = ({ className = '', ...props }) => {
  const { currentTheme, themes, updateTheme } = useTheme();
  const [isOpen, setIsOpen] = useState(false);

  const handleThemeChange = (themeName) => {
    updateTheme(themeName);
    setIsOpen(false);
  };

  return (
    <div className={`relative ${className}`} {...props}>
      <ThemeButton
        variant="outline"
        size="small"
        onClick={() => setIsOpen(!isOpen)}
        className="flex items-center gap-2"
      >
        <div className="w-4 h-4 rounded-full bg-gradient-to-r from-primary to-accent" />
        {themes[currentTheme].name}
        <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
        </svg>
      </ThemeButton>

      {isOpen && (
        <div className="absolute right-0 mt-2 w-64 bg-surface border border-border rounded-lg shadow-large z-50">
          <ThemeCard className="p-4">
            <h3 className="text-lg font-semibold text-text mb-4">Select Theme</h3>
            <div className="space-y-2">
              {Object.entries(themes).map(([key, theme]) => (
                <button
                  key={key}
                  onClick={() => handleThemeChange(key)}
                  className={`w-full text-left p-3 rounded-lg border transition-colors duration-200 ${
                    currentTheme === key
                      ? 'border-primary bg-primary bg-opacity-10'
                      : 'border-border hover:border-primary hover:bg-primary hover:bg-opacity-5'
                  }`}
                >
                  <div className="flex items-center gap-3">
                    <div className="flex gap-1">
                      <div 
                        className="w-6 h-6 rounded-full border-2 border-border"
                        style={{ backgroundColor: theme.colors.primary }}
                      />
                      <div 
                        className="w-6 h-6 rounded-full border-2 border-border"
                        style={{ backgroundColor: theme.colors.accent }}
                      />
                    </div>
                    <div>
                      <div className="font-medium text-text">{theme.name}</div>
                      <div className="text-sm text-textMuted">
                        {key === 'purpleGold' ? 'Classic NCL theme' : 'Professional corporate theme'}
                      </div>
                    </div>
                    {currentTheme === key && (
                      <div className="ml-auto">
                        <svg className="w-5 h-5 text-primary" fill="currentColor" viewBox="0 0 20 20">
                          <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                        </svg>
                      </div>
                    )}
                  </div>
                </button>
              ))}
            </div>
          </ThemeCard>
        </div>
      )}
    </div>
  );
};

export default ThemeSelector;
