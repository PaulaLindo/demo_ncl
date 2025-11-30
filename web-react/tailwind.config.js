/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // Purple & Gold Theme
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
        
        // Semantic colors
        'success-light': '#E8F5E8',
        'warning-light': '#FFF3CD',
        'error-light': '#FDE8E8',
        'info-light': '#E3F2FD',
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
      boxShadow: {
        small: '0 1px 3px rgba(0, 0, 0, 0.12), 0 1px 2px rgba(0, 0, 0, 0.24)',
        medium: '0 4px 6px rgba(0, 0, 0, 0.1), 0 2px 4px rgba(0, 0, 0, 0.06)',
        large: '0 10px 25px rgba(0, 0, 0, 0.1), 0 6px 10px rgba(0, 0, 0, 0.08)',
      },
      backgroundImage: {
        'gradient-primary': 'linear-gradient(135deg, #5D3F6A 0%, #8B6B9F 100%)',
        'gradient-accent': 'linear-gradient(135deg, #EECB05 0%, #F5D85E 100%)',
        'gradient-hero': 'linear-gradient(135deg, #5D3F6A 0%, #EECB05 100%)',
        'gradient-navy': 'linear-gradient(135deg, #1E3A8A 0%, #3B5BA8 100%)',
        'gradient-navy-accent': 'linear-gradient(135deg, #EAB308 0%, #FCD34D 100%)',
        'gradient-navy-hero': 'linear-gradient(135deg, #1E3A8A 0%, #EAB308 100%)',
      },
      animation: {
        'fade-in': 'fadeIn 0.3s ease-out',
        'slide-up': 'slideUp 0.3s ease-out',
        'bounce-gentle': 'bounceGentle 2s infinite',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0', transform: 'translateY(10px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        slideUp: {
          '0%': { transform: 'translateY(20px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
        bounceGentle: {
          '0%, 100%': { transform: 'translateY(0)' },
          '50%': { transform: 'translateY(-5px)' },
        },
      },
    },
  },
  plugins: [],
}
