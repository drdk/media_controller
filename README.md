# media_controller

Allows controlling HTML5 video and audio players from Ruby. This means you can test media in browsers using Selenium Webdriver, Capybara and RSpec, using a tidy Ruby DSL.

## Setup

Either install the gem directly:

    gem install media_controller

Or use Bundler:

    gem 'media_controller'

Require the gem:

    require 'media_controller'

## Usage examples

### Initialization

Requires a Capybara page, an ID of the video or audio element, and an initial interaction such as a click on a call to action.

    visit 'https://www.w3schools.com/html/html5_video.asp'
    element = page.first('video')
    video = MediaController::Video.new(page, id: element['id'])
    element.click

### Play, pause, current time

These methods make it easy for you to control the player and verify that it is doing what it should.

    video.play
    expect(video).to be_playing

    video.pause
    expect(video).to_not be_playing

    expect(video.current_time).to be > 0

### Volume and muting

Volume may be a float between 0 and 1, such that 0.5 is 50% volume.

    video.volume = 0.5
    expect(video.volume).to be 0.5

    video.mute!
    expect(video).to be_muted

### Video size

The `size` method allows you to find out the width and height of the player.

    expect(video.size[:width]).to be > video.size[:height]

### Listening to events

Here we set up a listener for the `'ended'` event, seek to 1 second before the end, allow it to play to the end, ensure that the `'ended'` event occurred exactly once, and then tidy up by removing the event listener.

    video.add_event_listener('ended')
    video.seek_to(video.duration - 1)
    video.play
    sleep 2
    expect(video.event_count('ended')).to eq 1
    video.remove_event_listener('ended')

## Methods implemented

### `new(page, options)`
`MediaController::Video.new(page, options)` or `MediaController::Audio.new(page, options)`

Returns a video/audio instance that you can control the media on the page.

Currently, `options` should include an ID of the video or audio element on the page.

### `current_src`
Returns the current source for the audio/video.

### `play`
Starts playing the audio/video.

### `pause`
Pauses the currently playing audio/video.

### `seek_to(int)`
Seeks to a number of seconds into the audio/video.

### `current_time`
Returns the current playback position (in seconds) in the audio/video.

### `duration`
Returns the length (in seconds) of the audio/video.

### `playing?`
Returns whether the audio/video is playing or not.

### `mute!`
Mutes the audio/video.

### `unmute!`
Unmutes the audio/video.

### `muted?`
Returns whether the audio/video is muted or not.

### `volume=(float)`
Sets the volume of the audio/video.

### `volume`
Returns the volume of the audio/video as a float between 0 and 1.

### `size`
Returns a Hash countaining the width and height of the audio/video.

### `add_event_listener(string)`
Listens for an event and sets up an event count.

### `remove_event_listener(string)`
Removes a previously added event listener and removes the event count.

### `event_count(string)`
Reports the number of times that an listened-for event has occurred.
