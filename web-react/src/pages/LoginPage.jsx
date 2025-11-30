import React, { useState } from 'react'
import { Link, useNavigate, useParams } from 'react-router-dom'
import { useTestAuth } from '../contexts/TestAuthContext.jsx'
import { EyeIcon, EyeSlashIcon } from '@heroicons/react/24/outline'

export function LoginPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  
  const { signIn } = useTestAuth()
  const navigate = useNavigate()
  const { role = 'customer' } = useParams()

  const handleSubmit = async (e) => {
    e.preventDefault()
    setLoading(true)
    setError('')

    const result = await signIn(email, password, role)
    
    if (result.success) {
      navigate(`/${role}/home`)
    } else {
      setError(result.error)
    }
    
    setLoading(false)
  }

  const getRoleConfig = (role) => {
    const configs = {
      customer: {
        title: 'Customer Login',
        description: 'Access your account to book and manage services',
        color: 'blue',
        icon: '👤'
      },
      staff: {
        title: 'Staff Login',
        description: 'Manage your work schedule and time tracking',
        color: 'green',
        icon: '👨‍💼'
      },
      admin: {
        title: 'Admin Login',
        description: 'System administration and management',
        color: 'purple',
        icon: '👑'
      }
    }
    return configs[role] || configs.customer
  }

  const config = getRoleConfig(role)

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        <div>
          <div className="text-center">
            <div className="text-4xl mb-4">{config.icon}</div>
            <h2 className="text-3xl font-bold text-gray-900">
              {config.title}
            </h2>
            <p className="mt-2 text-gray-600">
              {config.description}
            </p>
          </div>
        </div>
        
        <form className="mt-8 space-y-6" onSubmit={handleSubmit}>
          <div className="bg-white shadow-md rounded-lg p-6">
            {error && (
              <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-md">
                <p className="text-red-600 text-sm">{error}</p>
              </div>
            )}
            
            <div className="space-y-4">
              <div>
                <label htmlFor="email" className="block text-sm font-medium text-gray-700">
                  Email address
                </label>
                <input
                  id="email"
                  name="email"
                  type="email"
                  autoComplete="email"
                  required
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="Enter your email"
                />
              </div>
              
              <div>
                <label htmlFor="password" className="block text-sm font-medium text-gray-700">
                  Password
                </label>
                <div className="mt-1 relative">
                  <input
                    id="password"
                    name="password"
                    type={showPassword ? 'text' : 'password'}
                    autoComplete="current-password"
                    required
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    className="block w-full px-3 py-2 pr-10 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    placeholder="Enter your password"
                  />
                  <button
                    type="button"
                    className="absolute inset-y-0 right-0 pr-3 flex items-center"
                    onClick={() => setShowPassword(!showPassword)}
                  >
                    {showPassword ? (
                      <EyeSlashIcon className="h-5 w-5 text-gray-400" />
                    ) : (
                      <EyeIcon className="h-5 w-5 text-gray-400" />
                    )}
                  </button>
                </div>
              </div>
            </div>
            
            <div className="pt-4">
              <button
                type="submit"
                disabled={loading}
                className={`w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white ${
                  loading
                    ? 'bg-gray-400 cursor-not-allowed'
                    : `bg-${config.color}-600 hover:bg-${config.color}-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-${config.color}-500`
                } transition-colors`}
              >
                {loading ? 'Signing in...' : 'Sign in'}
              </button>
            </div>
            
            <div className="text-center pt-4 border-t border-gray-200">
              <Link
                to="/"
                className="text-sm text-gray-600 hover:text-gray-900"
              >
                ← Back to home
              </Link>
            </div>
          </div>
        </form>
        
        <div className="text-center text-sm text-gray-500">
          <p>Test credentials:</p>
          <p>Email: {role}@test.com</p>
          <p>Password: password123</p>
        </div>
      </div>
    </div>
  )
}
