import React, { createContext, useContext, useEffect, useState } from 'react'
import { auth } from '../services/firebase.js'
import { 
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  signOut as firebaseSignOut,
  onAuthStateChanged
} from 'firebase/auth'

const AuthContext = createContext()

export function useAuth() {
  const context = useContext(AuthContext)
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider')
  }
  return context
}

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (firebaseUser) => {
      if (firebaseUser) {
        // Get user role from custom claims or a separate users collection
        firebaseUser.getIdTokenResult(true)
          .then((idTokenResult) => {
            const role = idTokenResult.claims.role || 'customer'
            setUser({
              uid: firebaseUser.uid,
              email: firebaseUser.email,
              role: role,
              displayName: firebaseUser.displayName,
              photoURL: firebaseUser.photoURL
            })
          })
          .catch((error) => {
            console.error('Error getting user role:', error)
            setUser({
              uid: firebaseUser.uid,
              email: firebaseUser.email,
              role: 'customer', // Default role
              displayName: firebaseUser.displayName,
              photoURL: firebaseUser.photoURL
            })
          })
      } else {
        setUser(null)
      }
      setLoading(false)
    })

    return unsubscribe
  }, [])

  const signIn = async (email, password, role = 'customer') => {
    try {
      const result = await signInWithEmailAndPassword(auth, email, password)
      
      // In a real app, you'd verify the user's role matches the expected role
      // For now, we'll assume the role is correct
      
      return { success: true, user: result.user }
    } catch (error) {
      console.error('Sign in error:', error)
      return { 
        success: false, 
        error: mapFirebaseError(error.code) 
      }
    }
  }

  const signUp = async (email, password, role = 'customer', displayName) => {
    try {
      const result = await createUserWithEmailAndPassword(auth, email, password)
      
      // In a real app, you'd set the user's role in Firestore or custom claims
      // For now, we'll just create the user
      
      return { success: true, user: result.user }
    } catch (error) {
      console.error('Sign up error:', error)
      return { 
        success: false, 
        error: mapFirebaseError(error.code) 
      }
    }
  }

  const signOut = async () => {
    try {
      await firebaseSignOut(auth)
      return { success: true }
    } catch (error) {
      console.error('Sign out error:', error)
      return { 
        success: false, 
        error: 'Failed to sign out' 
      }
    }
  }

  const value = {
    user,
    loading,
    signIn,
    signUp,
    signOut
  }

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  )
}

function mapFirebaseError(errorCode) {
  const errorMap = {
    'auth/user-not-found': 'User not found. Please check your email.',
    'auth/wrong-password': 'Incorrect password. Please try again.',
    'auth/email-already-in-use': 'Email already in use. Please use a different email.',
    'auth/weak-password': 'Password is too weak. Please use a stronger password.',
    'auth/invalid-email': 'Invalid email address.',
    'auth/user-disabled': 'This account has been disabled.',
    'auth/too-many-requests': 'Too many failed attempts. Please try again later.',
    'auth/network-request-failed': 'Network error. Please check your connection.'
  }
  
  return errorMap[errorCode] || 'An error occurred. Please try again.'
}
