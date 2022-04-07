# Weather

## About

Weather is a simple weather app. You can use it to get to get the weather wherever you're at, or you get weather forecasts for other locations. (Shout out to Tommorrow.io (ClimaCell) and their amazing API for all of the weather data!) To get quick and easy weather forecasts for you and your friends, try out Weather!

Upon opening the app, you will receive a popup requesting access to your general locations. I was able to implement this through the LocationManager class and the Info.plist file. After the popup, you will be select among three tabs—Home, Saved, and Search—hosted by the ContentView:

- The first tab is Home. This view gets your current location (or a location you can manually set in settings) and passes it into another view, WeatherDetails, which fetches the weather data from Tomorrow.io. When the data is loaded, the view displays, showing the current weather.

- The second tab, Saved, lists your saved locations (empty by default) along with their temperatures and weather conditions, all stored in LocationCards. You can add locations to saved locations by searching for them in the Search tab and tapping the star icon on the top right corner, and you can remove them by simply swiping left on them in the Saved tab. You can also tap on these locations to view the weather in those areas.

- Finally, the last tab, Search, allows you to search for new locations and star them to add them to your saved locations. I used Apple's MKLocalSearchCompleter API to show relevant locations as you search. I also created an ObservableObject class to store a list of CLPlacemarks for your saved locations, allowing the app to quickly update its view when a location is added or removed, and preloading placemarks to load views faster and lower usage of Apple's geocoding API.

This app was quite a handful and definitely ended being a lot harder and took much longer than I initially thought it would. However, it was definitely worth it in the end and despite the many setbacks, it was very fun to create! Throughout the process, I redesigned the app, found inspiration from other weather apps (shoutout to [CARROT Weather](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&cad=rja&uact=8&ved=2ahUKEwjvj77Jwo_1AhXwQTABHeLgC2EQFnoECAkQAQ&url=https%3A%2F%2Fapps.apple.com%2Fus%2Fapp%2Fcarrot-weather%2Fid961390574&usg=AOvVaw21mzlIIz8csDdwJOdf1iCQ) and the new [iOS 15 weather app](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&cad=rja&uact=8&ved=2ahUKEwim1eLwwo_1AhXLQTABHeqdAakQFnoECAMQAQ&url=https%3A%2F%2Fwww.macrumors.com%2Fguide%2Fios-15-weather-app%2F&usg=AOvVaw1IXWKT-vRRxQy4-tmERSQM)), and learned about new frameworks, libraries, and even hacky workarounds to implement my app. I’m very proud of how my app turned out and I hope to improve it in the future. Until then, I hope you enjoy Weather! :)

## Demo

Video: https://youtu.be/xHRDuXmyzKs

## Sources

- [Tomorrow.io's (ClimaCell) API](https://www.tomorrow.io/weather-api/)
- Apple's location APIs
- John Sundell's amazing coding blogs on [Swift by Sundell](https://www.swiftbysundell.com)
