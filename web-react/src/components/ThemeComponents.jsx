// src/components/ThemeComponents.jsx - Theme-aware React components
import React from 'react';
import { useTheme, getThemeClasses } from '../theme/ThemeManager';

// Theme-aware Button component
export const ThemeButton = ({ 
  variant = 'primary', 
  size = 'medium', 
  children, 
  className = '', 
  ...props 
}) => {
  const { theme } = useTheme();
  
  const baseClasses = 'font-medium rounded-lg transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2';
  
  const sizeClasses = {
    small: 'px-3 py-1.5 text-sm',
    medium: 'px-4 py-2 text-base',
    large: 'px-6 py-3 text-lg',
  };
  
  const variantClasses = {
    primary: `bg-primary hover:bg-primaryDark text-white focus:ring-primary`,
    secondary: `bg-secondary hover:bg-secondaryDark text-white focus:ring-secondary`,
    accent: `bg-accent hover:bg-accentDark text-text focus:ring-accent`,
    outline: `border-2 border-primary text-primary hover:bg-primary hover:text-white focus:ring-primary`,
    ghost: `text-primary hover:bg-primary hover:bg-opacity-10 focus:ring-primary`,
  };
  
  const classes = `${baseClasses} ${sizeClasses[size]} ${variantClasses[variant]} ${className}`;
  
  return (
    <button className={classes} {...props}>
      {children}
    </button>
  );
};

// Theme-aware Card component
export const ThemeCard = ({ 
  children, 
  className = '', 
  hover = false, 
  ...props 
}) => {
  const { theme } = useTheme();
  
  const baseClasses = 'bg-surface border border-border rounded-xl shadow-medium';
  const hoverClasses = hover ? 'hover:shadow-large transition-shadow duration-200' : '';
  
  const classes = `${baseClasses} ${hoverClasses} ${className}`;
  
  return (
    <div className={classes} {...props}>
      {children}
    </div>
  );
};

// Theme-aware Input component
export const ThemeInput = ({ 
  className = '', 
  error = false, 
  ...props 
}) => {
  const { theme } = useTheme();
  
  const baseClasses = 'w-full px-4 py-2 border border-border rounded-lg bg-surface text-text placeholder-textMuted focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-colors duration-200';
  const errorClasses = error ? 'border-error focus:ring-error' : '';
  
  const classes = `${baseClasses} ${errorClasses} ${className}`;
  
  return (
    <input className={classes} {...props} />
  );
};

// Theme-aware Badge component
export const ThemeBadge = ({ 
  variant = 'primary', 
  children, 
  className = '', 
  ...props 
}) => {
  const { theme } = useTheme();
  
  const baseClasses = 'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium';
  
  const variantClasses = {
    primary: 'bg-primary bg-opacity-10 text-primary',
    secondary: 'bg-secondary bg-opacity-10 text-secondary',
    accent: 'bg-accent bg-opacity-10 text-accent',
    success: 'bg-success bg-opacity-10 text-success',
    warning: 'bg-warning bg-opacity-10 text-warning',
    error: 'bg-error bg-opacity-10 text-error',
  };
  
  const classes = `${baseClasses} ${variantClasses[variant]} ${className}`;
  
  return (
    <span className={classes} {...props}>
      {children}
    </span>
  );
};

// Theme-aware Alert component
export const ThemeAlert = ({ 
  variant = 'info', 
  children, 
  className = '', 
  ...props 
}) => {
  const { theme } = useTheme();
  
  const baseClasses = 'p-4 rounded-lg border';
  
  const variantClasses = {
    info: 'bg-info bg-opacity-10 border-info text-info',
    success: 'bg-success bg-opacity-10 border-success text-success',
    warning: 'bg-warning bg-opacity-10 border-warning text-warning',
    error: 'bg-error bg-opacity-10 border-error text-error',
  };
  
  const classes = `${baseClasses} ${variantClasses[variant]} ${className}`;
  
  return (
    <div className={classes} {...props}>
      {children}
    </div>
  );
};

// Theme-aware Navigation component
export const ThemeNav = ({ children, className = '', ...props }) => {
  const { theme } = useTheme();
  
  const baseClasses = 'bg-surface border-b border-border shadow-small';
  const classes = `${baseClasses} ${className}`;
  
  return (
    <nav className={classes} {...props}>
      {children}
    </nav>
  );
};

// Theme-aware Container component
export const ThemeContainer = ({ 
  children, 
  size = 'medium', 
  className = '', 
  ...props 
}) => {
  const baseClasses = 'mx-auto px-4';
  
  const sizeClasses = {
    small: 'max-w-2xl',
    medium: 'max-w-4xl',
    large: 'max-w-6xl',
    full: 'max-w-full',
  };
  
  const classes = `${baseClasses} ${sizeClasses[size]} ${className}`;
  
  return (
    <div className={classes} {...props}>
      {children}
    </div>
  );
};

// Theme-aware Hero section component
export const ThemeHero = ({ 
  title, 
  subtitle, 
  backgroundImage, 
  className = '', 
  children, 
  ...props 
}) => {
  const { theme } = useTheme();
  
  const baseClasses = 'relative overflow-hidden rounded-2xl';
  const heroStyle = backgroundImage 
    ? { backgroundImage: `url(${backgroundImage})` }
    : { background: theme.gradients.hero };
  
  const classes = `${baseClasses} ${className}`;
  
  return (
    <div 
      className={classes} 
      style={heroStyle}
      {...props}
    >
      <div className="absolute inset-0 bg-gradient-to-r from-black from-opacity-50 to-transparent" />
      <div className="relative z-10 p-8 text-white">
        <h1 className="text-4xl font-bold mb-4">{title}</h1>
        {subtitle && <p className="text-xl mb-6">{subtitle}</p>}
        {children}
      </div>
    </div>
  );
};

// Theme-aware Stats Grid component
export const ThemeStatsGrid = ({ stats, className = '', ...props }) => {
  const { theme } = useTheme();
  
  const baseClasses = 'grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4';
  const classes = `${baseClasses} ${className}`;
  
  return (
    <div className={classes} {...props}>
      {stats.map((stat, index) => (
        <ThemeCard key={index} className="p-6 text-center">
          <div className="text-3xl font-bold text-primary mb-2">{stat.value}</div>
          <div className="text-textSecondary">{stat.label}</div>
        </ThemeCard>
      ))}
    </div>
  );
};

// Theme-aware Loading Spinner component
export const ThemeSpinner = ({ size = 'medium', className = '', ...props }) => {
  const { theme } = useTheme();
  
  const sizeClasses = {
    small: 'w-4 h-4',
    medium: 'w-8 h-8',
    large: 'w-12 h-12',
  };
  
  const classes = `animate-spin rounded-full border-2 border-border border-t-primary ${sizeClasses[size]} ${className}`;
  
  return (
    <div className={classes} {...props} />
  );
};

export default {
  ThemeButton,
  ThemeCard,
  ThemeInput,
  ThemeBadge,
  ThemeAlert,
  ThemeNav,
  ThemeContainer,
  ThemeHero,
  ThemeStatsGrid,
  ThemeSpinner,
};
