// flutter_fallback_forms_simple.js - Simplified fallback forms
(function() {
  console.log('🔧 Simple Flutter Fallback Forms loaded');
  
  let fallbackActive = false;
  
  // Clear any existing fallback
  function clearFallback() {
    const existing = document.getElementById('flutter-fallback-container');
    if (existing) {
      existing.remove();
    }
    fallbackActive = false;
  }
  
  // Create login chooser
  function createLoginChooser() {
    clearFallback();
    
    const container = document.createElement('div');
    container.id = 'flutter-fallback-container';
    container.style.cssText = `
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: linear-gradient(to bottom, rgba(93, 63, 106, 0.1), white);
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 1001;
      padding: 20px;
    `;
    
    container.innerHTML = `
      <div style="max-width: 450px; width: 100%; background: white; border-radius: 24px; padding: 32px; box-shadow: 0 8px 32px rgba(0,0,0,0.1);">
        <div style="text-align: center; margin-bottom: 32px;">
          <div style="width: 80px; height: 80px; background: linear-gradient(135deg, #5D3F6A, #7B5680); border-radius: 20px; display: flex; align-items: center; justify-content: center; margin: 0 auto 24px;">
            <span style="font-size: 40px;">🏠</span>
          </div>
          <h2 style="margin: 0 0 8px 0; color: #333; font-size: 28px; font-weight: 700;">Welcome to NCL</h2>
          <p style="margin: 0; color: #666; font-size: 16px;">Professional home services at your fingertips</p>
        </div>
        
        <div style="display: flex; flex-direction: column; gap: 16px;">
          <button onclick="window.location.href='/login/customer'" style="
            width: 100%;
            padding: 16px;
            background: #5D3F6A;
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 12px;
          ">
            <span>👤</span>
            <span>Customer Login</span>
          </button>
          
          <button onclick="window.location.href='/login/staff'" style="
            width: 100%;
            padding: 16px;
            background: #2C2C2C;
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 12px;
          ">
            <span>👷</span>
            <span>Staff Access</span>
          </button>
          
          <button onclick="window.location.href='/login/admin'" style="
            width: 100%;
            padding: 16px;
            background: #1E293B;
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 12px;
          ">
            <span>⚙️</span>
            <span>Admin Portal</span>
          </button>
        </div>
        
        <div style="text-align: center; margin-top: 24px;">
          <button onclick="alert('Help: Contact support for login assistance')" style="
            background: none;
            border: none;
            color: #5D3F6A;
            font-size: 14px;
            cursor: pointer;
            text-decoration: underline;
          ">
            Need help?
          </button>
        </div>
      </div>
    `;
    
    document.body.appendChild(container);
    fallbackActive = true;
    console.log('✅ Simple fallback login chooser created');
  }
  
  // Create login form
  function createLoginForm(role) {
    clearFallback();
    
    const themes = {
      customer: { color: '#5D3F6A', icon: '👤', title: 'Welcome Back', email: 'customer@example.com', password: 'customer123' },
      staff: { color: '#2C2C2C', icon: '👷', title: 'Staff Portal', email: 'staff@example.com', password: 'staff123' },
      admin: { color: '#1E293B', icon: '⚙️', title: 'Admin System', email: 'admin@example.com', password: 'admin123' }
    };
    
    const theme = themes[role] || themes.customer;
    
    const container = document.createElement('div');
    container.id = 'flutter-fallback-container';
    container.style.cssText = `
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: linear-gradient(to bottom, ${theme.color}15, white);
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 1001;
      padding: 20px;
    `;
    
    container.innerHTML = `
      <div style="max-width: 400px; width: 100%; background: white; border-radius: 20px; padding: 32px; box-shadow: 0 8px 32px rgba(0,0,0,0.1);">
        <div style="text-align: center; margin-bottom: 32px;">
          <button onclick="window.location.href='/'" style="
            background: white;
            border: 1px solid #ddd;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            cursor: pointer;
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
          ">←</button>
          <div style="width: 60px; height: 60px; background: ${theme.color}; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 16px;">
            <span style="font-size: 30px; color: white;">${theme.icon}</span>
          </div>
          <h2 style="margin: 0 0 8px 0; color: #333; font-size: 24px; font-weight: 700;">${theme.title}</h2>
          <p style="margin: 0; color: #666; font-size: 14px;">Sign in to your account</p>
        </div>
        
        <form id="fallback-form" style="margin-bottom: 24px;">
          <div style="margin-bottom: 16px;">
            <label style="display: block; margin-bottom: 4px; color: #333; font-size: 14px; font-weight: 500;">Email</label>
            <input type="email" id="email" placeholder="Enter your email" required style="
              width: 100%;
              padding: 12px;
              border: 1px solid #ddd;
              border-radius: 8px;
              font-size: 14px;
              box-sizing: border-box;
            ">
          </div>
          
          <div style="margin-bottom: 24px;">
            <label style="display: block; margin-bottom: 4px; color: #333; font-size: 14px; font-weight: 500;">Password</label>
            <input type="password" id="password" placeholder="Enter your password" required style="
              width: 100%;
              padding: 12px;
              border: 1px solid #ddd;
              border-radius: 8px;
              font-size: 14px;
              box-sizing: border-box;
            ">
          </div>
          
          <button type="submit" style="
            width: 100%;
            padding: 14px;
            background: ${theme.color};
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
          ">Sign In</button>
        </form>
        
        <div style="background: ${theme.color}10; border: 1px solid ${theme.color}30; border-radius: 12px; padding: 16px;">
          <div style="font-weight: 600; color: ${theme.color}; font-size: 14px; margin-bottom: 8px;">Demo Credentials</div>
          <div style="font-size: 12px; color: #666; margin-bottom: 4px;">Email: <span onclick="document.getElementById('email').value='${theme.email}'" style="cursor: pointer; color: ${theme.color}; font-weight: 500;">${theme.email}</span></div>
          <div style="font-size: 12px; color: #666;">Password: <span onclick="document.getElementById('password').value='${theme.password}'" style="cursor: pointer; color: ${theme.color}; font-weight: 500;">${theme.password}</span></div>
        </div>
      </div>
    `;
    
    document.body.appendChild(container);
    fallbackActive = true;
    
    // Add form handler
    setTimeout(() => {
      const form = document.getElementById('fallback-form');
      if (form) {
        form.addEventListener('submit', (e) => {
          e.preventDefault();
          console.log('🔄 Login submitted for', role);
          // Simulate login success
          alert(`Login successful! Welcome ${role} user.`);
        });
      }
    }, 100);
    
    console.log('✅ Simple fallback login form created for', role);
  }
  
  // Main function
  function initFallback() {
    if (!document.body) return;
    
    // Only create fallback if Flutter isn't showing content
    const bodyText = document.body.textContent || '';
    if (bodyText.length < 1000) {
      const pathname = window.location.pathname;
      
      if (pathname.includes('/login/')) {
        const role = pathname.split('/login/')[1] || 'customer';
        createLoginForm(role);
      } else {
        createLoginChooser();
      }
    } else {
      console.log('✅ Flutter content detected, no fallback needed');
    }
  }
  
  // Wait for DOM and initialize
  function waitForDOM() {
    if (document.body) {
      initFallback();
    } else {
      setTimeout(waitForDOM, 100);
    }
  }
  
  waitForDOM();
  
  // Re-check on navigation
  let lastUrl = window.location.href;
  setInterval(() => {
    if (window.location.href !== lastUrl) {
      lastUrl = window.location.href;
      setTimeout(initFallback, 500);
    }
  }, 1000);
  
})();
