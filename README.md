# Navty

<img src="https://github.com/C4Q/AC3.2-Navty/blob/master/Final_Navty_Logo.png?raw=true" width="320" />

Navty is an personal safety navigation iOS app that allows users to choose routes based on NYPD incident reports. The crime incidents reports are populated on a mapView powered by Google Maps SDK. The user enters their destination and Navty generates the fastest route. If they choose to change their route a simple long press on the map where they would like to go through is needed. The app gives a User Notification once arriving at their destination allowing the user to send a text message to pre-selected contacts that they have arrived home safely. 

# Built With
- [DZENEmptyDataSet](https://github.com/dzenbot/DZNEmptyDataSet)
- [Paper-onboarding](https://github.com/Ramotion/paper-onboarding)
- [SnapKit](http://snapkit.io/)
- [PubNub](https://www.pubnub.com/)
- GoogleMaps, GooglePlaces
- NYC Open Data: NYPD API 

# Onboarding

Built a custom onboarding experience using "Paper-onboarding", allowing the user to get an overall feel of the app 

<img src="https://github.com/C4Q/AC3.2-Navty/blob/master/Navty/Demo/Navty_Onboarding_Demo.gif?raw=true" width="320" />

# Data Points

We are pulling crime incident reports from the NYPD crime data API, available on NYC Open Data. The points are placed on the map by where the incident occured. Each incident is clickable, displaying an info window showing the description of the incident that occured. Red markers are the most recent incidents. 

<img src="https://github.com/C4Q/AC3.2-Navty/blob/master/Navty/Demo/Screen%20Shot%202017-03-23%20at%205.20.38%20PM.png?raw=true" width="320" />

# Emergency Contacts, Geo-fencing, User Notiifications

Navty gives you the ability to add a maximum of 5 emergency contacts. When you break the geo-fence which is a set radius from your destination an user notification will trigger, reminding you to message your emergency contact you have made it to your destination safely. If you open the app from the notification it will take you to a text message with the message populated, and emergency contacts set as the contacts. 

# Rerouting


<img src="https://github.com/C4Q/AC3.2-Navty/blob/master/Navty/Demo/Navty_Navigating_Demo.gif?raw=true" width="320" />

<img src="https://github.com/C4Q/AC3.2-Navty/blob/master/Navty/Demo/Navty_Tracking_Video.gif?raw=true" width="320" />
