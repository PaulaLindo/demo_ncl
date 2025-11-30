// flutter_ui_helper.js - JavaScript overlay system that doesn't interfere with Flutter structure
(function() {
  console.log('🎨 Flutter UI Helper loaded');
  
  let overlayContainer = null;
  let isInitialized = false;
  
  // Initialize the UI helper
  function init() {
    if (isInitialized) return;
    
    // Remove existing overlay if any
    const existingOverlay = document.getElementById('flutter-ui-helper');
    if (existingOverlay) {
      existingOverlay.remove();
    }
    
    // Create overlay container
    overlayContainer = document.createElement('div');
    overlayContainer.id = 'flutter-ui-helper';
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
    console.log('✅ Flutter UI Helper initialized');
  }
  
  // Create login chooser buttons
  function createLoginChooser() {
    if (!overlayContainer) return;
    
    // Clear existing overlays
    overlayContainer.innerHTML = '';
    
    // Check if we're on the home page
    if (window.location.pathname === '/' || window.location.pathname === '/index.html') {
      const buttonContainer = document.createElement('div');
      buttonContainer.style.cssText = `
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        background: white;
        padding: 40px;
        border-radius: 12px;
        box-shadow: 0 8px 32px rgba(0,0,0,0.1);
        pointer-events: auto;
        z-index: 1001;
        min-width: 300px;
        text-align: center;
      `;
      
      // Welcome text
      const welcomeText = document.createElement('h2');
      welcomeText.innerText = 'Welcome to NCL';
      welcomeText.style.cssText = `
        font-size: 28px;
        font-weight: bold;
        margin-bottom: 10px;
        color: #333;
        text-align: center;
      `;
      
      const subtitleText = document.createElement('p');
      subtitleText.innerText = 'Professional Home Services';
      subtitleText.style.cssText = `
        font-size: 16px;
        color: #666;
        margin-bottom: 30px;
        text-align: center;
      `;
      
      buttonContainer.appendChild(welcomeText);
      buttonContainer.appendChild(subtitleText);
      
      // Create login buttons
      const createButton = (text, color, textColor, route) => {
        const btn = document.createElement('button');
        btn.innerText = text;
        btn.style.cssText = `
          display: block;
          width: 100%;
          padding: 15px 20px;
          margin: 10px 0;
          background: ${color};
          color: ${textColor};
          border: none;
          border-radius: 8px;
          cursor: pointer;
          font-size: 16px;
          font-weight: 500;
          transition: all 0.2s ease;
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        `;
        
        btn.onmouseover = () => {
          btn.style.transform = 'translateY(-2px)';
          btn.style.boxShadow = '0 4px 12px rgba(0,0,0,0.2)';
        };
        
        btn.onmouseout = () => {
          btn.style.transform = 'translateY(0)';
          btn.style.boxShadow = '0 2px 4px rgba(0,0,0,0.1)';
        };
        
        btn.onclick = () => {
          window.location.href = route;
        };
        
        return btn;
      };
      
      buttonContainer.appendChild(createButton('Customer Login', '#28a745', 'white', '/login/customer'));
      buttonContainer.appendChild(createButton('Staff Login', '#ffc107', '#212529', '/login/staff'));
      buttonContainer.appendChild(createButton('Admin Login', '#dc3545', 'white', '/login/admin'));
      
      overlayContainer.appendChild(buttonContainer);
      console.log('✅ Login chooser created');
    }
  }
  
  // Create login form helper
  function createLoginHelper() {
    if (!overlayContainer) return;
    
    // Clear existing overlays
    overlayContainer.innerHTML = '';
    
    // Check if we're on a login page
    if (window.location.pathname.includes('/login/')) {
      const role = window.location.pathname.split('/login/')[1] || 'customer';
      
      // Create demo credentials helper
      const credentialsHelper = document.createElement('div');
      credentialsHelper.style.cssText = `
        position: fixed;
        bottom: 20px;
        right: 20px;
        background: white;
        padding: 20px;
        border-radius: 12px;
        box-shadow: 0 8px 32px rgba(0,0,0,0.15);
        pointer-events: auto;
        z-index: 1001;
        min-width: 280px;
        border: 1px solid #e0e0e0;
      `;
      
      let email, password;
      switch(role) {
        case 'staff':
          email = 'staff@example.com';
          password = 'staff123';
          break;
        case 'admin':
          email = 'admin@example.com';
          password = 'admin123';
          break;
        default:
          email = 'customer@example.com';
          password = 'customer123';
      }
      
      credentialsHelper.innerHTML = `
        <div style="font-weight: bold; margin-bottom: 15px; color: #333; font-size: 14px;">Demo Credentials</div>
        <div style="margin-bottom: 12px;">
          <small style="color: #666; font-size: 12px;">Email:</small>
          <div id="demo-email" style="background: #f8f9fa; padding: 8px; border-radius: 6px; font-family: monospace; font-size: 13px; cursor: pointer; border: 1px solid #e9ecef;" onclick="fillEmail('${email}')">${email}</div>
        </div>
        <div style="margin-bottom: 12px;">
          <small style="color: #666; font-size: 12px;">Password:</small>
          <div id="demo-password" style="background: #f8f9fa; padding: 8px; border-radius: 6px; font-family: monospace; font-size: 13px; cursor: pointer; border: 1px solid #e9ecef;" onclick="fillPassword('${password}')">${password}</div>
        </div>
        <div style="font-size: 11px; color: #999; text-align: center; font-style: italic; margin-top: 10px;">Click credentials to auto-fill</div>
      `;
      
      overlayContainer.appendChild(credentialsHelper);
      
      // Add auto-fill functions to global scope
      window.fillEmail = function(emailValue) {
        const emailField = document.querySelector('input[type="email"], input[placeholder*="email" i], input[name*="email" i]');
        if (emailField) {
          emailField.value = emailValue;
          emailField.focus();
          emailField.dispatchEvent(new Event('input', { bubbles: true }));
          emailField.dispatchEvent(new Event('change', { bubbles: true }));
          console.log('✅ Email field filled:', emailValue);
        } else {
          console.log('❌ Email field not found');
        }
      };
      
      window.fillPassword = function(passwordValue) {
        const passwordField = document.querySelector('input[type="password"], input[placeholder*="password" i], input[name*="password" i]');
        if (passwordField) {
          passwordField.value = passwordValue;
          passwordField.focus();
          passwordField.dispatchEvent(new Event('input', { bubbles: true }));
          passwordField.dispatchEvent(new Event('change', { bubbles: true }));
          console.log('✅ Password field filled:', passwordValue);
        } else {
          console.log('❌ Password field not found');
        }
      };
      
      console.log('✅ Login helper created for role:', role);
    }
  }
  
  // Wait for page to be ready
  function waitForPageReady() {
    if (document.readyState === 'complete') {
      setTimeout(() => {
        init();
        createLoginChooser();
        createLoginHelper();
      }, 1000); // Wait a bit for Flutter to settle
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
          createLoginHelper();
        }, 1000);
      }
    }, 1000);
  }
  
  // Start the helper
  waitForPageReady();
  handleNavigation();
  
  // Expose functions for manual control
  window.flutterUIHelper = {
    init: init,
    createLoginChooser: createLoginChooser,
    createLoginHelper: createLoginHelper,
  };
  
})();
