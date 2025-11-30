// flutter_fallback_forms.js - Fallback forms that match original Flutter login design
(function() {
  console.log('🔧 Flutter Fallback Forms loaded');
  
  let overlayContainer;
  
  // Initialize overlay container
  function initOverlay() {
    if (!overlayContainer && document.body) {
      overlayContainer = document.createElement('div');
      overlayContainer.id = 'flutter-fallback-overlay';
      overlayContainer.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        pointer-events: auto;
        z-index: 1001;
      `;
      document.body.appendChild(overlayContainer);
      console.log('✅ Overlay container created and appended to body');
    } else if (!document.body) {
      console.log('⏳ Document body not ready yet');
    }
  }
  
  // Clear any existing fallback UI
  function clearFallback() {
    if (overlayContainer) {
      overlayContainer.innerHTML = '';
      overlayContainer.style.display = 'none';
    }
  }
  
  // Show overlay container
  function showOverlay() {
    if (overlayContainer) {
      overlayContainer.style.display = 'block';
      overlayContainer.style.pointerEvents = 'auto';
      console.log('✅ Overlay shown');
    }
  }
  
  // Initialize and run immediately
  function initAndRun() {
    console.log('🚀 initAndRun called');
    
    if (!document.body) {
      console.log('⏳ Document body not ready, waiting...');
      return;
    }
    
    initOverlay();
    
    // Always create fallback UI for now since Flutter isn't rendering
    const pathname = window.location.pathname;
    console.log('📍 Current pathname:', pathname);
    
    if (pathname.includes('/login/')) {
      const role = pathname.split('/login/')[1] || 'customer';
      console.log('👤 Creating login form for role:', role);
      createLoginForm(role);
    } else {
      console.log('🏠 Creating login chooser');
      createLoginChooser();
    }
  }
  
  // Wait for DOM to be ready
  function waitForDOM() {
    if (document.body) {
      console.log('✅ DOM is ready, starting fallback UI');
      initAndRun();
    } else {
      console.log('⏳ Waiting for DOM...');
      setTimeout(waitForDOM, 100);
    }
  }
  
  // Start waiting for DOM
  waitForDOM();
  
  // Also run on DOMContentLoaded
  document.addEventListener('DOMContentLoaded', initAndRun);
  
  // Run immediately and also check periodically
  setInterval(() => {
    if (document.body) {
      initAndRun();
    }
  }, 3000); // Check every 3 seconds
  
  // Wait for Flutter to potentially load (backup method)
  function checkAndCreateForms() {
    initAndRun();
  }
  
  // Create login chooser that matches original Flutter design exactly
  function createLoginChooser() {
    if (!overlayContainer) return;
    
    overlayContainer.innerHTML = '';
    showOverlay();
    
    const chooserContainer = document.createElement('div');
    chooserContainer.style.cssText = `
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: linear-gradient(to bottom, rgba(93, 63, 106, 0.1), white);
      display: flex;
      align-items: center;
      justify-content: center;
      pointer-events: none;
      z-index: 1001;
      padding: 20px;
      overflow-y: auto;
    `;
    
    chooserContainer.innerHTML = `
      <div style="max-width: 450px; width: 100%; pointer-events: auto;">
        <!-- Logo/Header Section -->
        <div style="text-align: center; margin-bottom: 48px;">
          <div style="display: inline-block; padding: 24px; background: white; border-radius: 24px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); margin-bottom: 48px;">
            <div style="width: 80px; height: 80px; background: rgba(93, 63, 106, 0.1); border-radius: 20px; display: flex; align-items: center; justify-content: center;">
              <span style="font-size: 40px;">🏠</span>
            </div>
          </div>
          
          <h2 style="margin: 0 0 12px 0; color: #333; font-size: 32px; font-weight: 700;">Welcome to NCL</h2>
          <p style="margin: 0; color: #666; font-size: 16px; line-height: 1.5;">Professional home services<br>at your fingertips</p>
        </div>
        
        <!-- Role Buttons -->
        <div style="display: flex; flex-direction: column; gap: 20px;">
          <!-- Customer Login Button -->
          <div style="
            width: 100%;
            height: 90px;
            border-radius: 20px;
            box-shadow: 0 6px 12px rgba(93, 63, 106, 0.3);
            background: #5D3F6A;
            pointer-events: auto;
          ">
            <button onclick="window.location.href='/login/customer'" style="
              width: 100%;
              height: 100%;
              background: #5D3F6A;
              color: white;
              border: none;
              border-radius: 20px;
              padding: 24px;
              display: flex;
              align-items: center;
              cursor: pointer;
              font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
              pointer-events: auto;
            " onmouseover="this.style.filter='brightness(1.05)'" onmouseout="this.style.filter='brightness(1)'">
              <!-- Icon Container -->
              <div style="
                padding: 12px;
                background: rgba(255,255,255,0.2);
                border-radius: 16px;
                display: flex;
                align-items: center;
                justify-content: center;
              ">
                <svg width="28" height="28" viewBox="0 0 24 24" fill="white">
                  <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
                </svg>
              </div>
              
              <!-- Text Content -->
              <div style="flex: 1; margin-left: 20px; text-align: left;">
                <div style="font-size: 18px; font-weight: bold; margin-bottom: 4px;">Customer Login</div>
                <div style="font-size: 13px; color: rgba(255,255,255,0.9);">Book and manage services</div>
              </div>
              
              <!-- Arrow Icon -->
              <div style="
                padding: 8px;
                background: rgba(255,255,255,0.15);
                border-radius: 12px;
                display: flex;
                align-items: center;
                justify-content: center;
              ">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="rgba(255,255,255,0.8)">
                  <path d="M8.59 16.59L13.17 12 8.59 7.41 10 6l6 6-6 6-1.41-1.41z"/>
                </svg>
              </div>
            </button>
          </div>
          
          <!-- Staff Access Button -->
          <div style="
            width: 100%;
            height: 90px;
            border-radius: 20px;
            box-shadow: 0 6px 12px rgba(44, 44, 44, 0.3);
            background: #2C2C2C;
            pointer-events: auto;
          ">
            <button onclick="window.location.href='/login/staff'" style="
              width: 100%;
              height: 100%;
              background: #2C2C2C;
              color: white;
              border: none;
              border-radius: 20px;
              padding: 24px;
              display: flex;
              align-items: center;
              cursor: pointer;
              font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
              pointer-events: auto;
            " onmouseover="this.style.filter='brightness(1.05)'" onmouseout="this.style.filter='brightness(1)'">
              <!-- Icon Container -->
              <div style="
                padding: 12px;
                background: rgba(255,255,255,0.2);
                border-radius: 16px;
                display: flex;
                align-items: center;
                justify-content: center;
              ">
                <svg width="28" height="28" viewBox="0 0 24 24" fill="white">
                  <path d="M20 6h-2.18c.11-.31.18-.65.18-1a2.996 2.996 0 00-5.5-1.65l-.5.67-.5-.68C10.96 2.54 10.05 2 9 2 7.34 2 6 3.34 6 5c0 .35.07.69.18 1H4c-1.11 0-1.99.89-1.99 2L2 19c0 1.11.89 2 2 2h16c1.11 0 2-.89 2-2V8c0-1.11-.89-2-2-2zm-5-2c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zM9 4c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1z"/>
                </svg>
              </div>
              
              <!-- Text Content -->
              <div style="flex: 1; margin-left: 20px; text-align: left;">
                <div style="font-size: 18px; font-weight: bold; margin-bottom: 4px;">Staff Access</div>
                <div style="font-size: 13px; color: rgba(255,255,255,0.9);">Manage jobs and schedule</div>
              </div>
              
              <!-- Arrow Icon -->
              <div style="
                padding: 8px;
                background: rgba(255,255,255,0.15);
                border-radius: 12px;
                display: flex;
                align-items: center;
                justify-content: center;
              ">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="rgba(255,255,255,0.8)">
                  <path d="M8.59 16.59L13.17 12 8.59 7.41 10 6l6 6-6 6-1.41-1.41z"/>
                </svg>
              </div>
            </button>
          </div>
          
          <!-- Admin Portal Button -->
          <div style="
            width: 100%;
            height: 90px;
            border-radius: 20px;
            box-shadow: 0 6px 12px rgba(30, 41, 59, 0.3);
            background: #1E293B;
            pointer-events: auto;
          ">
            <button onclick="window.location.href='/login/admin'" style="
              width: 100%;
              height: 100%;
              background: #1E293B;
              color: white;
              border: none;
              border-radius: 20px;
              padding: 24px;
              display: flex;
              align-items: center;
              cursor: pointer;
              font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
              pointer-events: auto;
            " onmouseover="this.style.filter='brightness(1.05)'" onmouseout="this.style.filter='brightness(1)'">
              <!-- Icon Container -->
              <div style="
                padding: 12px;
                background: rgba(255,255,255,0.2);
                border-radius: 16px;
                display: flex;
                align-items: center;
                justify-content: center;
              ">
                <svg width="28" height="28" viewBox="0 0 24 24" fill="white">
                  <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
                </svg>
              </div>
              
              <!-- Text Content -->
              <div style="flex: 1; margin-left: 20px; text-align: left;">
                <div style="font-size: 18px; font-weight: bold; margin-bottom: 4px;">Admin Portal</div>
                <div style="font-size: 13px; color: rgba(255,255,255,0.9);">Manage platform and users</div>
              </div>
              
              <!-- Arrow Icon -->
              <div style="
                padding: 8px;
                background: rgba(255,255,255,0.15);
                border-radius: 12px;
                display: flex;
                align-items: center;
                justify-content: center;
              ">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="rgba(255,255,255,0.8)">
                  <path d="M8.59 16.59L13.17 12 8.59 7.41 10 6l6 6-6 6-1.41-1.41z"/>
                </svg>
              </div>
            </button>
          </div>
        </div>
        
        <!-- Help Button -->
        <div style="text-align: center; margin-top: 32px; pointer-events: auto;">
          <button onclick="alert('Help: Contact support for login assistance')" style="
            background: none;
            border: none;
            color: #5D3F6A;
            font-size: 16px;
            font-weight: 500;
            cursor: pointer;
            padding: 12px 24px;
            border-radius: 8px;
            transition: background-color 0.2s;
            pointer-events: auto;
          " onmouseover="this.style.backgroundColor='rgba(93, 63, 106, 0.1)'" onmouseout="this.style.backgroundColor='transparent'">
            Need help signing in?
          </button>
        </div>
      </div>
    `;
    
    document.body.appendChild(chooserContainer);
    console.log('✅ Fallback login chooser created with original Flutter design');
  }
  
  // Create login form that matches original Flutter design
  function createLoginForm(role) {
    if (!overlayContainer) return;
    
    overlayContainer.innerHTML = '';
    showOverlay();
    
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
  
  // Start checking with delay to allow Flutter to potentially load
  setTimeout(() => {
    checkAndCreateForms();
  }, 2000);
  
  // Re-check on navigation changes
  let lastUrl = window.location.href;
  setInterval(() => {
    if (window.location.href !== lastUrl) {
      lastUrl = window.location.href;
      setTimeout(checkAndCreateForms, 1000);
    }
  }, 1000);
  
})();
