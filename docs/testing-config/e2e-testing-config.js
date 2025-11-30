// docs/testing-config/e2e-testing-config.js
const E2ETestingConfig = {
  // Project Configuration
  projectName: 'NCL Flutter App - E2E Testing Suite',
  version: '1.0.0',
  
  // Test Environment
  environment: {
    baseUrl: 'http://localhost:8080',
    webServer: {
      command: 'npx http-server build/web -p 8080 --cors',
      port: 8080,
      reuseExistingServer: true
    }
  },
  
  // Viewport Configurations
  viewports: {
    desktop: { width: 1280, height: 720, name: 'Desktop' },
    tablet: { width: 768, height: 1024, name: 'Tablet' },
    mobile: { width: 375, height: 667, name: 'Mobile' }
  },
  
  // User Journey Definitions
  userJourneys: {
    customer: {
      name: 'Customer Journey',
      description: 'Complete customer flow from login to booking management',
      entryPoint: 'Customer Login',
      keyFlows: [
        'Login & Authentication',
        'Service Booking',
        'Appointment Management',
        'Profile Management',
        'Logout'
      ],
      testFiles: [
        'e2e-tests/customer/customer-journey.spec.js'
      ]
    },
    
    admin: {
      name: 'Admin Journey', 
      description: 'Complete admin flow from login to system management',
      entryPoint: 'Admin Portal',
      keyFlows: [
        'Admin Authentication',
        'User Management',
        'Booking Management',
        'Reports & Analytics',
        'System Settings',
        'Logout'
      ],
      testFiles: [
        'e2e-tests/admin/admin-journey.spec.js'
      ]
    },
    
    staff: {
      name: 'Staff Journey',
      description: 'Complete staff flow from login to timekeeping',
      entryPoint: 'Staff Access',
      keyFlows: [
        'Staff Authentication',
        'Timekeeping (Clock In/Out)',
        'Availability Management',
        'Job/Gig Management',
        'Shift Swap',
        'Profile Management',
        'Logout'
      ],
      testFiles: [
        'e2e-tests/staff/staff-journey.spec.js'
      ]
    }
  },
  
  // Screenshot Configuration
  screenshots: {
    enabled: true,
    fullPage: true,
    onFailure: true,
    directory: 'screenshots',
    subdirectories: {
      customer: {
        desktop: 'screenshots/customer/desktop',
        mobile: 'screenshots/customer/mobile', 
        tablet: 'screenshots/customer/tablet'
      },
      admin: {
        desktop: 'screenshots/admin/desktop',
        mobile: 'screenshots/admin/mobile',
        tablet: 'screenshots/admin/tablet'
      },
      staff: {
        desktop: 'screenshots/staff/desktop',
        mobile: 'screenshots/staff/mobile',
        tablet: 'screenshots/staff/tablet'
      }
    }
  },
  
  // Test Execution Settings
  execution: {
    timeout: 60000,
    slowMo: 800,
    headless: false, // Show browser for visual verification
    retries: 0,
    workers: 1 // Run tests sequentially for better visibility
  },
  
  // Reporting Configuration
  reporting: {
    html: true,
    json: true,
    screenshots: true,
    videos: false,
    traces: 'on-first-retry',
    outputDir: 'test-results',
    reportDir: 'playwright-report'
  },
  
  // Element Selectors (Common UI Elements)
  selectors: {
    loginButtons: {
      customer: ['text=Customer Login', 'button:has-text("Customer")', 'text=Customer'],
      admin: ['text=Admin Portal', 'button:has-text("Admin")', 'text=Admin'],
      staff: ['text=Staff Access', 'button:has-text("Staff")', 'text=Staff']
    },
    
    navigation: {
      menu: ['☰', '[aria-label="menu"]', '[role="button"]', 'text=Menu'],
      logout: ['text=Logout', 'text=Sign Out', 'text=Log Out'],
      profile: ['text=Profile', 'text=Account', 'text=Settings'],
      back: ['text=Back', '[aria-label="back"]', 'button:has-text("Back")']
    },
    
    customer: {
      booking: ['text=Book', 'text=Services', 'text=Booking', 'text=Schedule'],
      appointments: ['text=Appointments', 'text=My Bookings', 'text=Schedule'],
      profile: ['text=My Profile', 'text=Account Settings', 'text=Profile']
    },
    
    admin: {
      userManagement: ['text=Users', 'text=User Management', 'text=Manage Users'],
      bookingManagement: ['text=Bookings', 'text=Booking Management', 'text=Appointments'],
      reports: ['text=Reports', 'text=Analytics', 'text=Dashboard'],
      settings: ['text=Settings', 'text=System Settings', 'text=Configuration']
    },
    
    staff: {
      timekeeping: ['text=Timekeeping', 'text=Clock In', 'text=Clock Out', 'text=Time Sheet'],
      availability: ['text=Availability', 'text=Schedule', 'text=Calendar'],
      jobs: ['text=Jobs', 'text=Gigs', 'text=Tasks', 'text=Assignments'],
      shiftSwap: ['text=Swap Shift', 'text=Shift Swap', 'text=Trade Shift']
    }
  },
  
  // Test Data and Scenarios
  testScenarios: {
    happyPaths: [
      'Successful login for each user type',
      'Complete booking flow for customer',
      'User management for admin',
      'Timekeeping for staff'
    ],
    
    edgeCases: [
      'Mobile viewport responsiveness',
      'Tablet viewport responsiveness',
      'Navigation menu functionality',
      'Button hover states'
    ],
    
    errorScenarios: [
      'Invalid login attempts',
      'Network error handling',
      'Missing elements handling'
    ]
  },
  
  // Performance Metrics
  performance: {
    pageLoadTimeout: 10000,
    elementVisibilityTimeout: 5000,
    screenshotTimeout: 3000,
    totalTestTimeout: 60000
  },
  
  // Cleanup Configuration
  cleanup: {
    clearCookies: true,
    clearLocalStorage: true,
    clearSessionStorage: true,
    closeBrowser: true,
    closeServer: true
  }
};

// Export configuration
module.exports = E2ETestingConfig;
