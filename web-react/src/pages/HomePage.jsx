import React from 'react'
import { Link } from 'react-router-dom'
import { useTestAuth } from '../contexts/TestAuthContext.jsx'
import { useTheme } from '../theme/ThemeManager.jsx'
import { ThemeButton, ThemeCard, ThemeHero, ThemeStatsGrid } from '../components/ThemeComponents.jsx'
import { ThemeSelector } from '../components/ThemeSelector.jsx'

export function HomePage() {
  const { user } = useTestAuth()
  const { theme } = useTheme()

  const stats = [
    { value: '500+', label: 'Happy Customers' },
    { value: '1000+', label: 'Services Completed' },
    { value: '50+', label: 'Professional Staff' },
    { value: '4.9', label: 'Average Rating' },
  ]

  return (
    <div className="min-h-screen bg-background">
      {/* Header with Theme Selector */}
      <header className="bg-surface border-b border-border shadow-small">
        <div className="container mx-auto px-4 py-4">
          <div className="flex justify-between items-center">
            {/* Logo */}
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-gradient-to-r from-primary to-accent rounded-lg flex items-center justify-center">
                <span className="text-white font-bold text-xl">N</span>
              </div>
              <span className="text-xl font-bold text-text">NCL Professional Home Services</span>
            </div>
            
            {/* Theme Selector */}
            <ThemeSelector />
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <ThemeHero
        title="NCL Professional Home Services"
        subtitle="Quality home services at your fingertips"
        className="mx-4 mt-8"
      >
        <div className="flex gap-4">
          {user ? (
            <Link to={`/${user.role}/home`}>
              <ThemeButton size="large">
                Go to Dashboard
              </ThemeButton>
            </Link>
          ) : (
            <>
              <Link to="/login/customer">
                <ThemeButton variant="primary" size="large">
                  Get Started
                </ThemeButton>
              </Link>
              <Link to="/login/staff">
                <ThemeButton variant="outline" size="large">
                  Staff Portal
                </ThemeButton>
              </Link>
            </>
          )}
        </div>
      </ThemeHero>

      {/* Stats Section */}
      <div className="container mx-auto px-4 py-12">
        <ThemeStatsGrid stats={stats} />
      </div>

      {/* Main Content */}
      <div className="container mx-auto px-4 py-12">
        {user ? (
          <ThemeCard className="p-8 max-w-md mx-auto text-center">
            <h2 className="text-2xl font-semibold text-text mb-4">Welcome back!</h2>
            <p className="text-textSecondary mb-2">Logged in as {user.email}</p>
            <p className="text-textMuted mb-6">Role: {user.role}</p>
            
            <Link to={`/${user.role}/home`}>
              <ThemeButton className="w-full">
                Go to Dashboard
              </ThemeButton>
            </Link>
          </ThemeCard>
        ) : (
          <div>
            <h2 className="text-3xl font-bold text-text text-center mb-8">Choose your login type</h2>
            
            <div className="grid md:grid-cols-3 gap-6 max-w-4xl mx-auto">
              <Link to="/login/customer">
                <ThemeCard hover className="p-6 text-center group">
                  <div className="text-4xl mb-4 group-hover:scale-110 transition-transform">
                    👤
                  </div>
                  <h3 className="font-semibold text-xl text-text mb-2">Customer</h3>
                  <p className="text-textSecondary">Book and manage services</p>
                </ThemeCard>
              </Link>
              
              <Link to="/login/staff">
                <ThemeCard hover className="p-6 text-center group">
                  <div className="text-4xl mb-4 group-hover:scale-110 transition-transform">
                    👨‍💼
                  </div>
                  <h3 className="font-semibold text-xl text-text mb-2">Staff</h3>
                  <p className="text-textSecondary">Manage your schedule and timekeeping</p>
                </ThemeCard>
              </Link>
              
              <Link to="/login/admin">
                <ThemeCard hover className="p-6 text-center group">
                  <div className="text-4xl mb-4 group-hover:scale-110 transition-transform">
                    🛡️
                  </div>
                  <h3 className="font-semibold text-xl text-text mb-2">Admin</h3>
                  <p className="text-textSecondary">Manage users and operations</p>
                </ThemeCard>
              </Link>
            </div>
          </div>
        )}
      </div>

      {/* Features Section */}
      <div className="bg-surface border-t border-border py-16">
        <div className="container mx-auto px-4">
          <h2 className="text-3xl font-bold text-text text-center mb-12">Why Choose NCL?</h2>
          
          <div className="grid md:grid-cols-3 gap-8">
            <ThemeCard className="p-6 text-center">
              <div className="w-16 h-16 bg-primary bg-opacity-10 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-2xl">✨</span>
              </div>
              <h3 className="font-semibold text-xl text-text mb-2">Quality Service</h3>
              <p className="text-textSecondary">Professional and reliable home cleaning services</p>
            </ThemeCard>
            
            <ThemeCard className="p-6 text-center">
              <div className="w-16 h-16 bg-accent bg-opacity-10 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-2xl">⏰</span>
              </div>
              <h3 className="font-semibold text-xl text-text mb-2">Flexible Scheduling</h3>
              <p className="text-textSecondary">Book services at your convenience</p>
            </ThemeCard>
            
            <ThemeCard className="p-6 text-center">
              <div className="w-16 h-16 bg-success bg-opacity-10 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-2xl">💰</span>
              </div>
              <h3 className="font-semibold text-xl text-text mb-2">Affordable Pricing</h3>
              <p className="text-textSecondary">Competitive rates with no hidden fees</p>
            </ThemeCard>
          </div>
        </div>
      </div>

      {/* Footer */}
      <footer className="bg-secondary text-white py-8">
        <div className="container mx-auto px-4 text-center">
          <div className="flex items-center justify-center gap-2 mb-4">
            <div className="w-8 h-8 bg-accent rounded-lg flex items-center justify-center">
              <span className="text-secondary font-bold">N</span>
            </div>
            <span className="text-lg font-semibold">NCL Professional Home Services</span>
          </div>
          <p className="text-white text-opacity-80">
            © 2024 NCL Professional Home Services. All rights reserved.
          </p>
        </div>
      </footer>
    </div>
  )
}

export default HomePage
