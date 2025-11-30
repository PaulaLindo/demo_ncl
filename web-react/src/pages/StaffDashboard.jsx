import React from 'react'
import { Link, Outlet, useNavigate } from 'react-router-dom'
import { useTestAuth } from '../contexts/TestAuthContext.jsx'
import { 
  HomeIcon, 
  ClockIcon, 
  CalendarIcon, 
  UserIcon, 
  CogIcon,
  ArrowRightOnRectangleIcon 
} from '@heroicons/react/24/outline'
import { StaffHome } from './StaffHome.jsx'

export function StaffDashboard() {
  const { user, signOut } = useTestAuth()
  const navigate = useNavigate()

  const handleSignOut = async () => {
    const result = await signOut()
    if (result.success) {
      // Navigate to home page after sign out
      navigate('/')
    }
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-4">
            <div className="flex items-center">
              <h1 className="text-2xl font-bold text-gray-900">NCL Staff Portal</h1>
            </div>
            
            <div className="flex items-center space-x-4">
              <span className="text-sm text-gray-600">
                Welcome, {user.displayName || user.email}
              </span>
              <button
                onClick={handleSignOut}
                className="flex items-center text-gray-500 hover:text-gray-700"
              >
                <ArrowRightOnRectangleIcon className="h-5 w-5" />
                <span className="ml-1">Sign out</span>
              </button>
            </div>
          </div>
        </div>
      </header>

      <div className="flex">
        {/* Sidebar */}
        <aside className="w-64 bg-white shadow-md min-h-screen">
          <nav className="mt-5 px-2">
            <div className="space-y-1">
              <Link
                to="/staff/home"
                className="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-gray-600 hover:text-gray-900 hover:bg-gray-50"
              >
                <HomeIcon className="mr-3 h-5 w-5" />
                Dashboard
              </Link>
              
              <Link
                to="/staff/timekeeping"
                className="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-gray-600 hover:text-gray-900 hover:bg-gray-50"
              >
                <ClockIcon className="mr-3 h-5 w-5" />
                Timekeeping
              </Link>
              
              <Link
                to="/staff/schedule"
                className="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-gray-600 hover:text-gray-900 hover:bg-gray-50"
              >
                <CalendarIcon className="mr-3 h-5 w-5" />
                Schedule
              </Link>
              
              <Link
                to="/staff/profile"
                className="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-gray-600 hover:text-gray-900 hover:bg-gray-50"
              >
                <UserIcon className="mr-3 h-5 w-5" />
                Profile
              </Link>
              
              <Link
                to="/staff/settings"
                className="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-gray-600 hover:text-gray-900 hover:bg-gray-50"
              >
                <CogIcon className="mr-3 h-5 w-5" />
                Settings
              </Link>
            </div>
          </nav>
        </aside>

        {/* Main content */}
        <main className="flex-1 p-6">
          <Outlet />
        </main>
      </div>
    </div>
  )
}
