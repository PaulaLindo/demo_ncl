// flutter_fallback_forms.js - Create functional HTML forms when Flutter doesn't render
(function() {
  console.log('🔧 Flutter Fallback Forms loaded');
  
  let overlayContainer = null;
  let isInitialized = false;
  
  // Initialize the fallback system
  function init() {
    if (isInitialized) return;
    
    // Remove existing overlay if any
    const existingOverlay = document.getElementById('flutter-fallback-overlay');
    if (existingOverlay) {
      existingOverlay.remove();
    }
    
    // Create overlay container
    overlayContainer = document.createElement('div');
    overlayContainer.id = 'flutter-fallback-overlay';
    overlayContainer.style.cssText = `
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      pointer-events: none;
      z-index: 1000;
    `;
    document.body.appendChild(overlayContainer);
    
    isInitialized = true;
    console.log('✅ Flutter Fallback Forms initialized');
  }
  
  // Create login chooser
  function createLoginChooser() {
    if (!overlayContainer) return;
    
    // Clear existing overlays
    overlayContainer.innerHTML = '';
    
    // Check if we're on the home page and Flutter isn't showing buttons
    if (window.location.pathname === '/' || window.location.pathname === '/index.html') {
      const flutterButtons = document.querySelectorAll('button, [role="button"]');
      const hasFlutterButtons = Array.from(flutterButtons).some(btn => 
        (btn.innerText || btn.textContent || '').length > 0
      );
      
      if (!hasFlutterButtons) {
        const chooserContainer = document.createElement('div');
        chooserContainer.style.cssText = `
          position: fixed;
          top: 50%;
          left: 50%;
          transform: translate(-50%, -50%);
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          padding: 60px;
          border-radius: 20px;
          box-shadow: 0 25px 80px rgba(0,0,0,0.2);
          pointer-events: auto;
          z-index: 1001;
          min-width: 450px;
          text-align: center;
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
          color: white;
        `;
        
        chooserContainer.innerHTML = `
          <div style="margin-bottom: 50px;">
            <h1 style="margin: 0 0 15px 0; color: white; font-size: 36px; font-weight: 700; text-shadow: 0 2px 4px rgba(0,0,0,0.3);">Welcome to NCL</h1>
            <p style="margin: 0; color: rgba(255,255,255,0.9); font-size: 18px; font-weight: 400; text-shadow: 0 1px 2px rgba(0,0,0,0.2);">Professional Home Services</p>
          </div>
          <div style="display: flex; flex-direction: column; gap: 16px;">
            <button onclick="navigateToLogin('/login/customer')" style="
              display: block;
              width: 100%;
              padding: 18px 24px;
              background: rgba(255,255,255,0.95);
              color: #28a745;
              border: none;
              border-radius: 12px;
              font-size: 16px;
              font-weight: 600;
              cursor: pointer;
              transition: all 0.3s ease;
              box-shadow: 0 8px 25px rgba(0,0,0,0.15);
              backdrop-filter: blur(10px);
            " onmouseover="this.style.background='white'; this.style.transform='translateY(-3px)'; this.style.boxShadow='0 12px 35px rgba(0,0,0,0.2)'" onmouseout="this.style.background='rgba(255,255,255,0.95)'; this.style.transform='translateY(0)'; this.style.boxShadow='0 8px 25px rgba(0,0,0,0.15)'">
              Customer Login
            </button>
            <button onclick="navigateToLogin('/login/staff')" style="
              display: block;
              width: 100%;
              padding: 18px 24px;
              background: rgba(255,255,255,0.95);
              color: #ffc107;
              border: none;
              border-radius: 12px;
              font-size: 16px;
              font-weight: 600;
              cursor: pointer;
              transition: all 0.3s ease;
              box-shadow: 0 8px 25px rgba(0,0,0,0.15);
              backdrop-filter: blur(10px);
            " onmouseover="this.style.background='white'; this.style.transform='translateY(-3px)'; this.style.boxShadow='0 12px 35px rgba(0,0,0,0.2)'" onmouseout="this.style.background='rgba(255,255,255,0.95)'; this.style.transform='translateY(0)'; this.style.boxShadow='0 8px 25px rgba(0,0,0,0.15)'">
              Staff Login
            </button>
            <button onclick="navigateToLogin('/login/admin')" style="
              display: block;
              width: 100%;
              padding: 18px 24px;
              background: rgba(255,255,255,0.95);
              color: #dc3545;
              border: none;
              border-radius: 12px;
              font-size: 16px;
              font-weight: 600;
              cursor: pointer;
              transition: all 0.3s ease;
              box-shadow: 0 8px 25px rgba(0,0,0,0.15);
              backdrop-filter: blur(10px);
            " onmouseover="this.style.background='white'; this.style.transform='translateY(-3px)'; this.style.boxShadow='0 12px 35px rgba(0,0,0,0.2)'" onmouseout="this.style.background='rgba(255,255,255,0.95)'; this.style.transform='translateY(0)'; this.style.boxShadow='0 8px 25px rgba(0,0,0,0.15)'">
              Admin Login
            </button>
          </div>
        `;
        
        overlayContainer.appendChild(chooserContainer);
        console.log('✅ Fallback login chooser created');
      }
    }
  }
  
  // Create login form
  function createLoginForm() {
    if (!overlayContainer) return;
    
    // Clear existing overlays
    overlayContainer.innerHTML = '';
    
    // Check if we're on a login page and Flutter isn't showing forms
    if (window.location.pathname.includes('/login/')) {
      const role = window.location.pathname.split('/login/')[1] || 'customer';
      const flutterInputs = document.querySelectorAll('input[type="email"], input[type="password"]');
      const flutterButtons = document.querySelectorAll('button, [role="button"]');
      
      const hasFlutterForm = flutterInputs.length > 0 && flutterButtons.length > 0;
      
      if (!hasFlutterForm) {
        // Get role-specific styling to match original Flutter design
        let themeColor, icon, title, subtitle, demoEmail, demoPassword;
        
        if (role === 'staff') {
          themeColor = '#2C2C2C'; // AppTheme.secondaryColor
          icon = '👷'; // Badge icon representation
          title = 'Staff Portal';
          subtitle = 'Access your schedule and jobs';
          demoEmail = 'staff@example.com';
          demoPassword = 'staff123';
        } else if (role === 'admin') {
          themeColor = '#1E293B'; // Dark slate for Admin
          icon = '⚙️'; // Admin icon representation
          title = 'Admin System';
          subtitle = 'Manage platform and users';
          demoEmail = 'admin@example.com';
          demoPassword = 'admin123';
        } else {
          themeColor = '#5D3F6A'; // AppTheme.primaryPurple
          icon = '👤'; // Person icon representation
          title = 'Welcome Back';
          subtitle = 'Sign in to manage your bookings';
          demoEmail = 'customer@example.com';
          demoPassword = 'customer123';
        }
        
        const formContainer = document.createElement('div');
        formContainer.style.cssText = `
          position: fixed;
          top: 0;
          left: 0;
          right: 0;
          bottom: 0;
          background: linear-gradient(to bottom, ${themeColor}15, white);
          padding: 20px;
          overflow-y: auto;
          pointer-events: auto;
          z-index: 1001;
        `;
        
        formContainer.innerHTML = `
          <div style="max-width: 400px; margin: 40px auto;">
            <!-- App Bar -->
            <div style="display: flex; align-items: center; padding: 16px; background: white; border-radius: 12px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
              <button onclick="window.location.href='/'" style="background: white; border: none; border-radius: 50%; width: 40px; height: 40px; display: flex; align-items: center; justify-content: center; cursor: pointer; margin-right: 16px;">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M19 12H5M12 19l-7-7 7-7"/>
                </svg>
              </button>
              <h3 style="margin: 0; color: #333; font-weight: bold; font-size: 18px;">${role.charAt(0).toUpperCase() + role.slice(1)} Login</h3>
            </div>
            
            <!-- Header Section -->
            <div style="text-align: center; margin-bottom: 40px;">
              <div style="width: 80px; height: 80px; margin: 0 auto 24px; background: linear-gradient(135deg, ${themeColor}, ${themeColor}B3); border-radius: 50%; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 12px rgba(0,0,0,0.15);">
                <span style="font-size: 40px; color: white;">${icon}</span>
              </div>
              <h2 style="margin: 0 0 8px 0; color: #333; font-size: 28px; font-weight: bold;">${title}</h2>
              <p style="margin: 0; color: #666; font-size: 16px;">${subtitle}</p>
            </div>
            
            <!-- Login Form Card -->
            <div style="background: white; border-radius: 16px; padding: 24px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
              <form id="fallback-login-form" style="margin: 0;">
                <!-- Email Field -->
                <div style="margin-bottom: 16px;">
                  <label style="display: block; margin-bottom: 8px; color: #333; font-weight: 500; font-size: 14px;">Email Address</label>
                  <div style="position: relative;">
                    <span style="position: absolute; left: 12px; top: 50%; transform: translateY(-50%); color: #666;">
                      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
                        <polyline points="22,6 12,13 2,6"/>
                      </svg>
                    </span>
                    <input type="email" id="fallback-email" placeholder="Enter your email" required
                           style="width: 100%; padding: 12px 12px 12px 44px; border: 1px solid #ddd; border-radius: 12px; font-size: 14px; box-sizing: border-box;">
                  </div>
                </div>
                
                <!-- Password Field -->
                <div style="margin-bottom: 24px;">
                  <label style="display: block; margin-bottom: 8px; color: #333; font-weight: 500; font-size: 14px;">Password</label>
                  <div style="position: relative;">
                    <span style="position: absolute; left: 12px; top: 50%; transform: translateY(-50%); color: #666;">
                      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                        <path d="M7 11V7a5 5 0 0110 0v4"/>
                      </svg>
                    </span>
                    <input type="password" id="fallback-password" placeholder="Enter your password" required
                           style="width: 100%; padding: 12px 12px 12px 44px; border: 1px solid #ddd; border-radius: 12px; font-size: 14px; box-sizing: border-box;">
                  </div>
                </div>
                
                <!-- Sign In Button -->
                <button type="submit" style="width: 100%; padding: 16px; background: ${themeColor}; color: white; border: none; border-radius: 12px; font-size: 16px; font-weight: 600; cursor: pointer; margin-bottom: 16px;">
                  Sign In
                </button>
                
                <!-- Customer Links -->
                ${role === 'customer' ? `
                  <div style="text-align: center; padding-top: 16px; border-top: 1px solid #eee;">
                    <a href="#" onclick="window.location.href='/forgot-password'; return false;" style="display: block; margin-bottom: 8px; color: ${themeColor}; text-decoration: none; font-size: 14px; font-weight: 500;">Forgot Password?</a>
                    <a href="#" onclick="window.location.href='/register/customer'; return false;" style="color: #666; text-decoration: none; font-size: 14px;">
                      New to NCL? <span style="color: ${themeColor}; font-weight: bold;">Create Account</span>
                    </a>
                  </div>
                ` : ''}
              </form>
            </div>
            
            <!-- Demo Credentials -->
            <div style="background: ${themeColor}0D; border: 1px solid ${themeColor}33; border-radius: 12px; padding: 16px; margin-top: 24px;">
              <div style="display: flex; align-items: center; margin-bottom: 12px;">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="${themeColor}" stroke-width="2" style="margin-right: 8px;">
                  <circle cx="12" cy="12" r="10"/>
                  <line x1="12" y1="16" x2="12" y2="12"/>
                  <line x1="12" y1="8" x2="12.01" y2="8"/>
                </svg>
                <span style="color: ${themeColor}; font-weight: 600; font-size: 14px;">Demo Credentials</span>
              </div>
              
              <div style="background: white; border-radius: 8px; padding: 12px; margin-bottom: 12px;">
                <div style="display: flex; align-items: center; margin-bottom: 4px;">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="${themeColor}80" stroke-width="2" style="margin-right: 8px;">
                    <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
                    <polyline points="22,6 12,13 2,6"/>
                  </svg>
                  <span style="font-weight: 500; font-size: 11px; color: #666;">Email:</span>
                </div>
                <div onclick="document.getElementById('fallback-email').value='${demoEmail}'; document.getElementById('fallback-email').focus();" style="cursor: pointer; font-family: monospace; font-size: 12px; font-weight: 600; color: #333; padding: 4px 0;">
                  ${demoEmail}
                </div>
              </div>
              
              <div style="background: white; border-radius: 8px; padding: 12px; margin-bottom: 8px;">
                <div style="display: flex; align-items: center; margin-bottom: 4px;">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="${themeColor}80" stroke-width="2" style="margin-right: 8px;">
                    <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                    <path d="M7 11V7a5 5 0 0110 0v4"/>
                  </svg>
                  <span style="font-weight: 500; font-size: 11px; color: #666;">Password:</span>
                </div>
                <div onclick="document.getElementById('fallback-password').value='${demoPassword}'; document.getElementById('fallback-password').focus();" style="cursor: pointer; font-family: monospace; font-size: 12px; font-weight: 600; color: #333; padding: 4px 0;">
                  ${demoPassword}
                </div>
              </div>
              
              <div style="text-align: center; font-size: 10px; color: ${themeColor}80; font-style: italic;">
                Tap on credentials to auto-fill
              </div>
            </div>
          </div>
        `;
            // Add form submission handler
        setTimeout(() => {
          const form = document.getElementById('fallback-login-form');
          if (form) {
            form.addEventListener('submit', function(e) {
              e.preventDefault();
              const email = document.getElementById('fallback-email').value;
              const password = document.getElementById('fallback-password').value;
              
              // Simulate login - redirect based on role
              let redirectUrl;
              if (role === 'staff') {
                redirectUrl = '/staff/home';
              } else if (role === 'admin') {
                redirectUrl = '/admin/home';
              } else {
                redirectUrl = '/customer/home';
              }
              
              console.log('🔄 Simulating login redirect to:', redirectUrl);
              window.location.href = redirectUrl;
            });
          }
        }, 100);
        
        document.body.appendChild(formContainer);
        console.log('✅ Fallback login form created with original design');
      }
    }
  }
              font-size: 16px;
              font-weight: 600;
              cursor: pointer;
              transition: all 0.3s ease;
              box-shadow: 0 8px 25px rgba(0,0,0,0.15);})();
          </div>
        `;
        
        overlayContainer.appendChild(formContainer);
        
        // Add form submission handler
        const form = document.getElementById('fallback-login-form');
        if (form) {
          form.addEventListener('submit', function(e) {
            e.preventDefault();
            
            const email = document.getElementById('fallback-email').value;
            const password = document.getElementById('fallback-password').value;
            
            console.log('🔐 Fallback form submission:', { email, password: '***' });
            
            // Simulate login success - redirect to dashboard
            setTimeout(() => {
              if (role === 'customer') {
                window.location.href = '/customer/dashboard';
              } else if (role === 'staff') {
                window.location.href = '/staff/dashboard';
              } else if (role === 'admin') {
                window.location.href = '/admin/dashboard';
              }
            }, 1000);
          });
        }
        
        console.log('✅ Fallback login form created for role:', role);
      }
    }
  }
  
  // Navigation function
  window.navigateToLogin = function(path) {
    window.location.href = path;
  };
  
  // Wait for page to be ready
  function waitForPageReady() {
    if (document.readyState === 'complete') {
      setTimeout(() => {
        init();
        createLoginChooser();
        createLoginForm();
      }, 2000); // Wait a bit for Flutter to try rendering first
    } else {
      setTimeout(waitForPageReady, 100);
    }
  }
  
  // Handle navigation changes
  function handleNavigation() {
    let currentPath = window.location.pathname;
    
    setInterval(() => {
      if (window.location.pathname !== currentPath) {
        currentPath = window.location.pathname;
        console.log('🔄 Navigation detected:', currentPath);
        setTimeout(() => {
          createLoginChooser();
          createLoginForm();
        }, 2000);
      }
    }, 1000);
  }
  
  // Start the fallback system
  waitForPageReady();
  handleNavigation();
  
  // Expose functions for manual control
  window.flutterFallbackForms = {
    init: init,
    createLoginChooser: createLoginChooser,
    createLoginForm: createLoginForm,
  };
  
})();
