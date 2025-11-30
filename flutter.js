// Force HTML renderer for better compatibility
window.flutter = {
  webRenderer: "html",
  // Additional web configuration
  loader: {
    didCreateEngineInitializer: function(engineInitializer) {
      return engineInitializer.initializeEngine({
        renderer: "html",
      });
    }
  }
};
