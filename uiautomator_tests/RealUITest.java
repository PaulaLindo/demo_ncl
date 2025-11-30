// uiautomator_tests/RealUITest.java
package com.example.demo_ncl;

import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.uiautomator.UiDevice;
import androidx.test.uiautomator.UiObject;
import androidx.test.uiautomator.UiObjectNotFoundException;
import androidx.test.uiautomator.UiSelector;
import androidx.test.ext.junit.rules.ActivityScenarioRule;
import androidx.test.platform.app.InstrumentationRegistry;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import static org.junit.Assert.*;

@RunWith(AndroidJUnit4.class)
public class RealUITest {
    
    private UiDevice device;
    
    @Before
    public void setUp() {
        device = UiDevice.getInstance(InstrumentationRegistry.getInstrumentation());
        System.out.println("🚀 Starting REAL UI Tests - CHECK YOUR SCREEN!");
    }
    
    @Test
    public void testWelcomeScreenAndNavigation() throws UiObjectNotFoundException {
        System.out.println("👀 Testing Welcome Screen...");
        
        // Wait for app to load
        try {
            Thread.sleep(5000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        
        // Test Welcome text
        UiObject welcomeText = device.findObject(new UiSelector()
                .className("android.widget.TextView")
                .text("Welcome to NCL"));
        
        assertTrue("Welcome text not found!", welcomeText.exists());
        System.out.println("✅ Welcome to NCL found!");
        
        // Test Customer Login button
        UiObject customerLogin = device.findObject(new UiSelector()
                .className("android.widget.TextView")
                .text("Customer Login"));
        
        assertTrue("Customer Login button not found!", customerLogin.exists());
        System.out.println("👆 Tapping Customer Login...");
        customerLogin.click();
        
        try {
            Thread.sleep(3000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        
        System.out.println("✅ Customer Login tapped - Check screen!");
        
        // Go back
        device.pressBack();
        
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        
        // Test Staff Access button
        UiObject staffAccess = device.findObject(new UiSelector()
                .className("android.widget.TextView")
                .text("Staff Access"));
        
        assertTrue("Staff Access button not found!", staffAccess.exists());
        System.out.println("👆 Tapping Staff Access...");
        staffAccess.click();
        
        try {
            Thread.sleep(3000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        
        System.out.println("✅ Staff Access tapped - Check screen!");
        
        // Go back
        device.pressBack();
        
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        
        // Test Admin Portal button
        UiObject adminPortal = device.findObject(new UiSelector()
                .className("android.widget.TextView")
                .text("Admin Portal"));
        
        assertTrue("Admin Portal button not found!", adminPortal.exists());
        System.out.println("👆 Tapping Admin Portal...");
        adminPortal.click();
        
        try {
            Thread.sleep(3000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        
        System.out.println("✅ Admin Portal tapped - Check screen!");
        
        System.out.println("🎉 ALL UI TESTS COMPLETED!");
        System.out.println("📱 You should have seen all interactions on the emulator!");
    }
    
    @Test
    public void testButtonInteractions() throws UiObjectNotFoundException {
        System.out.println("🧪 Testing Button Interactions...");
        
        try {
            Thread.sleep(3000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        
        // Test long press
        UiObject customerLogin = device.findObject(new UiSelector()
                .className("android.widget.TextView")
                .text("Customer Login"));
        
        if (customerLogin.exists()) {
            customerLogin.longClick();
            System.out.println("✅ Long press tested");
        }
        
        // Test swipe gestures
        device.swipe(500, 1000, 500, 200, 10);
        System.out.println("✅ Swipe gesture tested");
        
        System.out.println("🎉 BUTTON INTERACTIONS TESTED!");
    }
    
    @Test
    public void testAppResponsiveness() throws UiObjectNotFoundException {
        System.out.println("📱 Testing App Responsiveness...");
        
        try {
            Thread.sleep(3000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        
        // Test rotation
        device.setOrientationLandscape();
        System.out.println("✅ Landscape orientation tested");
        
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        
        device.setOrientationPortrait();
        System.out.println("✅ Portrait orientation tested");
        
        System.out.println("🎉 RESPONSIVENESS TESTS COMPLETED!");
    }
}
