# Google Analytics Measurement Protocol
The Google Analytics Measurement Protocol extension allows developers to make HTTP requests to send raw user interaction data directly to Google Analytics servers.
This allows developers to measure how users interact with their websites serverside without the need for cookies.

## How it works
Once installed, and configured (_see configuration below_) the extension will automatically prepare and publish page view request data to the configured Google Analytics account using the [GAMP API](https://developers.google.com/analytics/devguides/collection/protocol/v1).

The extension will also set a custom dimension that can be used to segment hits registered using the GAMP API. See the details below on how this works.

## Configuration
You can configure the extension in the System > Settings > Google Analytics Measurement Protocol admin form.

### Analytics Property
This is usually the Google Analytics tracking ID that can be obtained from your Google Ananlytics account.

### Analytics Dimension ID
As mentioned in the opening note, the extension can set a custom dimension by default, that can be used to segment hits registered using the GAMP API.

The dimension is called "Preside GAMP" and only comes into effect if you set this to a value which is greater than zero in the CMS Admin.

If you would like the default dimension to be applied, you can configure the Google Analytics Dimension ID from the Admin > Custom Dimensions property configuration in the Analytics console.
Then, in the extension, you should set the "Analytics Dimension ID" value to be the `Index` value of the dimension in Analytics.

### Preventing GAMP API page view submissions
If you ever wish to prevent the default page tracking e.g. if you're sending an AJAX request for tracking a custom event such as a button click, you can use the below method to remove the default page view tracking.
```java
// Overriding page view tracking via a helper method available in the extension
analytics( method="disableGamp" );
```

## Setting custom dimensions
Custom dimensions are used to collect data that Analytics doesn't automatically track and is a characteristic of an object that can be given different values e.g. a dimension "describes" data

Below is an example of how you can set a custom dimension in your application code.
As above you need to ensure the `index` value corresponds with the `Index` in Analiytics and the value is set to whatever data you wish to record.
```java
// Set a value to describe whether the user is logged in or not
analytics( "setDimension", { index=2, value="#$isWebsiteUserLoggedIn()#" } );
```

## Setting custom metrics
A metric is an individual element of a dimension which can be measured as a sum or ratio e.g. a metric "measures" data
Same as the custom dimensions above, you can set custom metrics in Analytics using the example code below.

```java
// Set a value to measure the depth in which the user scrolled in an article
analytics( "setMetric", { index=3, value="50" } );
```

## Firing custom events
One of the reasons for having to use this extension is to overcome the potential issue of visitors disabling the Analytics tracking scripts via a Cookie Control extension.
Therefore the GAMP API extension has a public handler which allows you to use AJAX or other direct methods in code to fire tracking events directly into Analytics.

### Triggering/registering events - Server side
Below is example code that you can set in your handler or service to trigger an event from the server side.

* Add detail with examples of custom events
```java
analytics( "addEvent", { category="Test Category", action="Download", label="Test Document", value=1 } );
```

### Triggering/registering events - Client side

* Add AJAX proxy handler for making AJAX event requests that get submitted pre-postRender
/?event=analytics.triggerEvent&method=addEvent&category=Test%20Category&action=Trigger%20Event%20Action&label=Custom%20Event%20Triggered%20Label

## Debugging
If you're working on implementing this extension into your application and wish to see the generated JSON, you can enable `debugMode` in the `Config.cfc`

```java
settings.analytics.debugMode = true; // Default is false
```

### Example JSON output
```javascript
// 20201023180007
// http://websitedomain.com/?event=analytics.triggerEvent&method=addEvent&category=Test%20Category&action=Trigger%20Event%20Action&label=Custom%20Event%20Triggered%20Label

{
    "v": "1",
    "tid": "UA-123456789-1",
    "cid": "7e4e8575-32a0-48d8-8bgh3c97a67e8638",
    "uid": "",
    "ds": "web",
    "uip": "127.0.0.1",
    "ua": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36",
    "dr": "",
    "cn": "",
    "cs": "",
    "cm": "",
    "ck": "",
    "cc": "",
    "ci": "",
    "gclid": "",
    "dclid": "",
    "debugMode": true,
    "pageView": {

    },
    "events": [
        {
            "el": "Custom Event Triggered Label",
            "ec": "Test Category",
            "ea": "Trigger Event Action"
        }
    ],
    "dimensions": {
        "1": "Preside GAMP"
    },
    "metrics": {

    }
}
```

## Warning re Cookie Control Frameworks
Please note that if your application is using a Cookie Control extension or framework, please ensure you implement something to prevent the GAMP API calls creating "double-hits" if the user accepts the cookies and the scripts lod.

For example, the Civic Cookie Control plugin/framework sets a cookie called `CookieControl` which contains a serialised JSON object of the users preferences.
This could be checked for existence and if set, the users choices used in a condition to set the `analytics( method="disableGamp" );` which will disable the GAMP API call.

The CookieBot cookie is called `CookieConsent`.

