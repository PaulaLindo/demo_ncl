import React from 'react'
import { Routes, Route, Navigate } from 'react-router-dom'
import { useAuth } from './contexts/AuthContext.jsx'
import { DeviceDetector } from './components/DeviceDetector.jsx'
import { LoadingSpinner } from './components/LoadingSpinner.jsx'
import { ThemeProvider } from './theme/ThemeManager.jsx'

// Import pages
import { LoginPage } from './pages/LoginPage.jsx'
import { CustomerDashboard } from './pages/CustomerDashboard.jsx'
import { StaffDashboard } from './pages/StaffDashboard.jsx'
import { AdminDashboard } from './pages/AdminDashboard.jsx'
import { HomePage } from './pages/HomePage.jsx'

function App() {
  const { user, loading } = useAuth()

  if (loading) {
    return <LoadingSpinner />
  }

  return (
    <ThemeProvider>
      <div className="min-h-screen bg-background">
        <DeviceDetector />
        
        <Routes>
          {/* Public routes */}
          <Route path="/" element={<HomePage />} />
          <Route path="/login" element={<LoginPage />} />
          <Route path="/login/:role" element={<LoginPage />} />
          
          {/* Protected customer routes */}
          <Route
            path="/customer/*"
            element={
              user && user.role === 'customer' ? (
                <CustomerDashboard />
              ) : (
                <Navigate to="/login/customer" replace />
              )
            }
          />
          
          {/* Protected staff routes */}
          <Route
            path="/staff/*"
            element={
              user && user.role === 'staff' ? (
                <StaffDashboard />
              ) : (
                <Navigate to="/login/staff" replace />
            )
          }
        />
        
        {/* Protected admin routes */}
        <Route
          path="/admin/*"
          element={
            user && user.role === 'admin' ? (
              <AdminDashboard />
            ) : (
              <Navigate to="/login/admin" replace />
            )
          }
        />
        
        {/* Catch all route */}
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
      </div>
    </ThemeProvider>
  )
}

export default App
