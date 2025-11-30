import React from 'react'

export function CustomerHome() {
  return (
    <div>
      <h2 className="text-2xl font-bold text-gray-900 mb-6">Customer Dashboard</h2>
      
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold mb-2">Active Services</h3>
          <p className="text-3xl font-bold text-blue-600">3</p>
          <p className="text-gray-600">Currently active services</p>
        </div>
        
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold mb-2">Completed This Month</h3>
          <p className="text-3xl font-bold text-green-600">12</p>
          <p className="text-gray-600">Services completed</p>
        </div>
        
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold mb-2">Next Appointment</h3>
          <p className="text-lg font-bold text-purple-600">Tomorrow</p>
          <p className="text-gray-600">Home cleaning - 10:00 AM</p>
        </div>
      </div>
      
      <div className="mt-8">
        <h3 className="text-lg font-semibold mb-4">Recent Activity</h3>
        <div className="bg-white shadow rounded-lg">
          <div className="p-4 border-b">
            <div className="flex justify-between items-start">
              <div>
                <p className="font-medium">Home Cleaning Service</p>
                <p className="text-sm text-gray-600">Completed on Nov 25, 2025</p>
              </div>
              <span className="px-2 py-1 text-xs font-medium bg-green-100 text-green-800 rounded">Completed</span>
            </div>
          </div>
          <div className="p-4 border-b">
            <div className="flex justify-between items-start">
              <div>
                <p className="font-medium">Plumbing Repair</p>
                <p className="text-sm text-gray-600">Scheduled for Nov 30, 2025</p>
              </div>
              <span className="px-2 py-1 text-xs font-medium bg-blue-100 text-blue-800 rounded">Upcoming</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
