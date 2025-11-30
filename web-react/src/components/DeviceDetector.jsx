import React, { useEffect } from 'react'
import { useLocation } from 'react-router-dom'

export function DeviceDetector() {
  const location = useLocation()

  useEffect(() => {
    // Enhanced device detection
    const detectDevice = () => {
      const userAgent = navigator.userAgent
      const screenWidth = window.innerWidth
      
      // Mobile detection
      const isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(userAgent)
      const isTablet = /iPad|Android/i.test(userAgent) && screenWidth > 768 && screenWidth < 1024
      const isDesktop = !isMobile && !isTablet
      
      // OS detection
      const isIOS = /iPad|iPhone|iPod/.test(userAgent)
      const isAndroid = /Android/.test(userAgent)
      const isWindows = /Windows/.test(userAgent)
      const isMac = /Mac/.test(userAgent) && !isIOS
      
      // Browser detection
      const isChrome = /Chrome/.test(userAgent) && !/Edge/.test(userAgent)
      const isFirefox = /Firefox/.test(userAgent)
      const isSafari = /Safari/.test(userAgent) && !/Chrome/.test(userAgent)
      const isEdge = /Edge/.test(userAgent)
      
      return {
        isMobile,
        isTablet,
        isDesktop,
        isIOS,
        isAndroid,
        isWindows,
        isMac,
        isChrome,
        isFirefox,
        isSafari,
        isEdge,
        screenWidth,
        screenHeight: window.innerHeight
      }
    }

    const device = detectDevice()
    
    // Add device info to body for CSS targeting
    document.body.className = Object.entries(device)
      .filter(([_, value]) => value)
      .map(([key, value]) => `device-${key}`)
      .join(' ')
    
    // Log device info for debugging
    console.log('Device detected:', device)
    
    // If mobile user tries to access web app, show app download prompt
    if (device.isMobile && !device.isTablet) {
      // You could show a modal or banner here
      console.log('Mobile user detected - should use Flutter app')
    }
    
    // Handle responsive behavior
    const handleResize = () => {
      const newDevice = detectDevice()
      const newClasses = Object.entries(newDevice)
        .filter(([_, value]) => value)
        .map(([key, value]) => `device-${key}`)
        .join(' ')
      
      if (document.body.className !== newClasses) {
        document.body.className = newClasses
      }
    }
    
    window.addEventListener('resize', handleResize)
    
    return () => {
      window.removeEventListener('resize', handleResize)
    }
  }, [location])

  // This component doesn't render anything visible
  // It just handles device detection and adds classes to the body
  return null
}
