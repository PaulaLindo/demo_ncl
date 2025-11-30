import React from 'react'
import { Routes, Route, Navigate } from 'react-router-dom'
import { useTestAuth } from './contexts/TestAuthContext.jsx'
import { DeviceDetector } from './components/DeviceDetector.jsx'
import { LoadingSpinner } from './components/LoadingSpinner.jsx'

// Import pages
import { LoginPage } from './pages/LoginPage.jsx'
import { CustomerDashboard } from './pages/CustomerDashboard.jsx'
import { StaffDashboard } from './pages/StaffDashboard.jsx'
import { AdminDashboard } from './pages/AdminDashboard.jsx'
import { CustomerHome } from './pages/CustomerHome.jsx'
import { StaffHome } from './pages/StaffHome.jsx'
import { AdminHome } from './pages/AdminHome.jsx'
import { HomePage } from './pages/HomePage.jsx'

function TestApp() {
  const { user, loading } = useTestAuth()

  if (loading) {
    return <LoadingSpinner />
  }

  return (
    <div className="min-h-screen bg-gray-50">
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
        >
          <Route path="home" element={<CustomerHome />} />
          <Route path="bookings" element={<div><h2>My Bookings</h2><p>Booking management coming soon...</p></div>} />
          <Route path="profile" element={<div><h2>Profile</h2><p>Profile management coming soon...</p></div>} />
          <Route path="settings" element={<div><h2>Settings</h2><p>Settings coming soon...</p></div>} />
        </Route>
        
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
        >
          <Route path="home" element={<StaffHome />} />
          <Route path="timekeeping" element={<div><h2>Timekeeping</h2><p>Time tracking coming soon...</p></div>} />
          <Route path="schedule" element={<div><h2>Schedule</h2><p>Schedule management coming soon...</p></div>} />
          <Route path="profile" element={<div><h2>Profile</h2><p>Profile management coming soon...</p></div>} />
          <Route path="settings" element={<div><h2>Settings</h2><p>Settings coming soon...</p></div>} />
        </Route>
        
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
        >
          <Route path="home" element={<AdminHome />} />
          <Route path="users" element={<div><h2>Users</h2><p>User management coming soon...</p></div>} />
          <Route path="schedule" element={<div><h2>Schedule</h2><p>Schedule management coming soon...</p></div>} />
          <Route path="analytics" element={<div><h2>Analytics</h2><p>Analytics coming soon...</p></div>} />
          <Route path="settings" element={<div><h2>Settings</h2><p>Settings coming soon...</p></div>} />
        </Route>
        
        {/* Catch all route */}
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </div>
  )
}

export default TestApp
