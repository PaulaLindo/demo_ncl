// Test authentication without Firebase
export const mockAuth = {
  // Mock user data for testing
  mockUsers: {
    customer: {
      uid: 'customer-123',
      email: 'customer@test.com',
      role: 'customer',
      displayName: 'Test Customer',
      photoURL: null
    },
    staff: {
      uid: 'staff-123',
      email: 'staff@test.com',
      role: 'staff',
      displayName: 'Test Staff',
      photoURL: null
    },
    admin: {
      uid: 'admin-123',
      email: 'admin@test.com',
      role: 'admin',
      displayName: 'Test Admin',
      photoURL: null
    }
  },

  // Mock authentication functions
  signIn: async (email, password, role) => {
    // Simulate network delay
    await new Promise(resolve => setTimeout(resolve, 1000))
    
    const mockUser = mockAuth.mockUsers[role]
    if (mockUser && mockUser.email === email && password === 'password123') {
      return { success: true, user: mockUser }
    } else {
      return { success: false, error: 'Invalid email or password' }
    }
  },

  signOut: async () => {
    await new Promise(resolve => setTimeout(resolve, 500))
    return { success: true }
  }
}
