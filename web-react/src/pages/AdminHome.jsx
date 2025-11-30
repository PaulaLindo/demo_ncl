import React from 'react'
import { UserGroupIcon, CalendarIcon, ChartBarIcon, CogIcon } from '@heroicons/react/24/outline'

export function AdminHome() {
  return (
    <div>
      <h2 className="text-2xl font-bold text-gray-900 mb-6">Admin Dashboard</h2>
      
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold mb-2">Total Users</h3>
          <p className="text-3xl font-bold text-blue-600">1,247</p>
          <p className="text-gray-600">Registered users</p>
        </div>
        
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold mb-2">Active Staff</h3>
          <p className="text-3xl font-bold text-green-600">42</p>
          <p className="text-gray-600">Currently working</p>
        </div>
        
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold mb-2">Today's Jobs</h3>
          <p className="text-3xl font-bold text-purple-600">156</p>
          <p className="text-gray-600">Services scheduled</p>
        </div>
        
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold mb-2">Revenue This Month</h3>
          <p className="text-3xl font-bold text-orange-600">$24,580</p>
          <p className="text-gray-600">Total revenue</p>
        </div>
      </div>
      
      <div className="mt-8 grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div>
          <h3 className="text-lg font-semibold mb-4">Recent User Activity</h3>
          <div className="bg-white shadow rounded-lg">
            <div className="p-4 border-b">
              <div className="flex justify-between items-start">
                <div>
                  <p className="font-medium">John Doe - Customer Registration</p>
                  <p className="text-sm text-gray-600">2 minutes ago</p>
                </div>
                <span className="px-2 py-1 text-xs font-medium bg-blue-100 text-blue-800 rounded">New User</span>
              </div>
            </div>
            <div className="p-4 border-b">
              <div className="flex justify-between items-start">
                <div>
                  <p className="font-medium">Jane Smith - Booked Home Cleaning</p>
                  <p className="text-sm text-gray-600">15 minutes ago</p>
                </div>
                <span className="px-2 py-1 text-xs font-medium bg-green-100 text-green-800 rounded">Booking</span>
              </div>
            </div>
            <div className="p-4">
              <div className="flex justify-between items-start">
                <div>
                  <p className="font-medium">Mike Johnson - Staff Clock In</p>
                  <p className="text-sm text-gray-600">1 hour ago</p>
                </div>
                <span className="px-2 py-1 text-xs font-medium bg-purple-100 text-purple-800 rounded">Staff Activity</span>
              </div>
            </div>
          </div>
        </div>
        
        <div>
          <h3 className="text-lg font-semibold mb-4">System Status</h3>
          <div className="bg-white shadow rounded-lg p-6">
            <div className="space-y-4">
              <div className="flex justify-between items-center">
                <span className="text-gray-600">Database Status</span>
                <span className="px-2 py-1 text-xs font-medium bg-green-100 text-green-800 rounded">Operational</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-gray-600">API Response Time</span>
                <span className="text-gray-900 font-medium">142ms</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-gray-600">Active Sessions</span>
                <span className="text-gray-900 font-medium">234</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-gray-600">Server Load</span>
                <span className="text-gray-900 font-medium">32%</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-gray-600">Last Backup</span>
                <span className="text-gray-900 font-medium">2 hours ago</span>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <div className="mt-8">
        <h3 className="text-lg font-semibold mb-4">Quick Actions</h3>
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <button className="bg-blue-600 text-white p-4 rounded-lg hover:bg-blue-700 transition-colors">
            <UserGroupIcon className="h-6 w-6 mb-2" />
            <p>Manage Users</p>
          </button>
          <button className="bg-green-600 text-white p-4 rounded-lg hover:bg-green-700 transition-colors">
            <CalendarIcon className="h-6 w-6 mb-2" />
            <p>View Schedule</p>
          </button>
          <button className="bg-purple-600 text-white p-4 rounded-lg hover:bg-purple-700 transition-colors">
            <ChartBarIcon className="h-6 w-6 mb-2" />
            <p>View Reports</p>
          </button>
          <button className="bg-orange-600 text-white p-4 rounded-lg hover:bg-orange-700 transition-colors">
            <CogIcon className="h-6 w-6 mb-2" />
            <p>System Settings</p>
          </button>
        </div>
      </div>
    </div>
  )
}
