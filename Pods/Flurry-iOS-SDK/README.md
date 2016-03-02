Flurry SDK
==========


To use FlurrySDK from cocoapods, for Analytics, Ad serving,  Apple Watch Extension, and for Tumblr in-app sharing follow the instructions:


To enable Flurry Analytics:

```
  pod ‘Flurry-iOS-SDK/FlurrySDK’
```


To enable Flurry Ad serving  : 

```
  pod 'Flurry-iOS-SDK/FlurrySDK'
  pod 'Flurry-iOS-SDK/FlurryAds'
```


To use FlurrySDK for Apple Watch Extension:    
```
target :"Your Apple Watch Extension Target" do 
   pod 'Flurry-iOS-SDK/FlurryWatchSDK’
end   
```
Don't forget to read how to track events correctly in Apple Watch Extensions  in FlurryiOSAnalyticsREADMExx.pdf  


To enable Tubmlr in-app sharing: 
```
pod 'Flurry-iOS-SDK/FlurrySDK'
pod 'Flurry-iOS-SDK/FlurryAds'
pod 'Flurry-iOS-SDK/TumblrAPI'
```