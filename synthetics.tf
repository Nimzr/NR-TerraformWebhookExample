resource "newrelic_synthetics_monitor" "myTFBrowserMonitor" {
  status            = "ENABLED"
  type              = "BROWSER"
  uri               = "https://www.one.newrelic.com"
  name              = "myTFBrowser"
  period            = "EVERY_MINUTE"
  locations_public  = ["US_WEST_2"] 

  custom_header {
    name  = "some_name"
    value = "some_value"
  }

  enable_screenshot_on_failure_and_script = true
  validation_string                       = "success"
  verify_ssl                              = true
  runtime_type_version                    = "100"
  runtime_type                            = "CHROME_BROWSER"

  tag {
    key    = "TF"
    values = ["true"]
  }
}