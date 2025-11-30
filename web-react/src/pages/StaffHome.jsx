import React from 'react'
import { ClockIcon, CalendarIcon, UserIcon } from '@heroicons/react/24/outline'

export function StaffHome() {
  return (
    <div>
      <h2 className="text-2xl font-bold text-gray-900 mb-6">Staff Dashboard</h2>
      
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold mb-2">Today's Jobs</h3>
          <p className="text-3xl font-bold text-blue-600">4</p>
          <p className="text-gray-600">Scheduled for today</p>
        </div>
        
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold mb-2">Hours This Week</h3>
          <p className="text-3xl font-bold text-green-600">32.5</p>
          <p className="text-gray-600">Hours worked</p>
        </div>
        
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold mb-2">Next Job</h3>
          <p className="text-lg font-bold text-purple-600">2:00 PM</p>
          <p className="text-gray-600">Home cleaning - Downtown</p>
        </div>
        
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold mb-2">Status</h3>
          <p className="text-lg font-bold text-orange-600">Available</p>
          <p className="text-gray-600">Ready for work</p>
        </div>
      </div>
      
      <div className="mt-8">
        <h3 className="text-lg font-semibold mb-4">Today's Schedule</h3>
        <div className="bg-white shadow rounded-lg">
          <div className="p-4 border-b">
            <div className="flex justify-between items-start">
              <div>
                <p className="font-medium">Home Cleaning - Smith Residence</p>
                <p className="text-sm text-gray-600">9:00 AM - 11:00 AM</p>
                <p className="text-sm text-gray-600">123 Main St, Downtown</p>
              </div>
              <span className="px-2 py-1 text-xs font-medium bg-green-100 text-green-800 rounded">Completed</span>
            </div>
          </div>
          <div className="p-4 border-b">
            <div className="flex justify-between items-start">
              <div>
                <p className="font-medium">Plumbing Repair - Johnson Apartment</p>
                <p className="text-sm text-gray-600">2:00 PM - 4:00 PM</p>
                <p className="text-sm text-gray-600">456 Oak Ave, Apt 3B</p>
              </div>
              <span className="px-2 py-1 text-xs font-medium bg-blue-100 text-blue-800 rounded">Upcoming</span>
            </div>
          </div>
          <div className="p-4">
            <div className="flex justify-between items-start">
              <div>
                <p className="font-medium">Electrical Work - Wilson Home</p>
                <p className="text-sm text-gray-600">5:00 PM - 7:00 PM</p>
                <p className="text-sm text-gray-600">789 Pine St, Suburbs</p>
              </div>
              <span className="px-2 py-1 text-xs font-medium bg-gray-100 text-gray-800 rounded">Scheduled</span>
            </div>
          </div>
        </div>
      </div>
      
      <div className="mt-8">
        <h3 className="text-lg font-semibold mb-4">Quick Actions</h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <button className="bg-blue-600 text-white p-4 rounded-lg hover:bg-blue-700 transition-colors">
            <ClockIcon className="h-6 w-6 mb-2" />
            <p>Clock In</p>
          </button>
          <button className="bg-green-600 text-white p-4 rounded-lg hover:bg-green-700 transition-colors">
            <CalendarIcon className="h-6 w-6 mb-2" />
            <p>View Schedule</p>
          </button>
          <button className="bg-purple-600 text-white p-4 rounded-lg hover:bg-purple-700 transition-colors">
            <UserIcon className="h-6 w-6 mb-2" />
            <p>Update Availability</p>
          </button>
        </div>
      </div>
    </div>
  )
}
