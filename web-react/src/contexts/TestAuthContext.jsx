import React, { createContext, useContext, useState } from 'react'
import { mockAuth } from '../utils/testAuth.js'

const TestAuthContext = createContext()

export function useTestAuth() {
  const context = useContext(TestAuthContext)
  if (!context) {
    throw new Error('useTestAuth must be used within a TestAuthProvider')
  }
  return context
}

export function TestAuthProvider({ children }) {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(false)

  const signIn = async (email, password, role = 'customer') => {
    setLoading(true)
    try {
      const result = await mockAuth.signIn(email, password, role)
      if (result.success) {
        setUser(result.user)
      }
      return result
    } finally {
      setLoading(false)
    }
  }

  const signOut = async () => {
    setLoading(true)
    try {
      const result = await mockAuth.signOut()
      if (result.success) {
        setUser(null)
      }
      return result
    } finally {
      setLoading(false)
    }
  }

  const value = {
    user,
    loading,
    signIn,
    signOut
  }

  return (
    <TestAuthContext.Provider value={value}>
      {children}
    </TestAuthContext.Provider>
  )
}
