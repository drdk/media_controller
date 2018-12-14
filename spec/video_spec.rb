describe MediaController::Video do

  describe "#new" do
    let(:page) { double('page', execute_script: nil) }

    it "works with an ID" do
      expect(page).to receive(:execute_script).with("window['media-my-id'] = document.getElementById('my-id')")
      MediaController::Video.new(page, id: 'my-id')
    end

    it "does not work without an ID" do
      expect {
        require 'media_controller'
        MediaController::Video.new(page, {})
      }.to raise_error(RuntimeError, "Please supply an ID")
    end

    it "remembers the page reference" do
      video = MediaController::Video.new(page, id: 'my-id')
      expect(video.page).to eq(page)
    end

    it "stores the id" do
      video = MediaController::Video.new(page, id: 'my-id')
      expect(video.id).to eq('my-id')
    end
  end

  describe "#play" do
    let(:page)  { double('page', execute_script: nil) }
    let(:video) { MediaController::Video.new(page, id: 'my-id') }

    it "plays video" do
      expect(page).to receive(:execute_script).with("window['media-my-id'].play();")
      video.play
    end
  end

  describe "#pause" do
    let(:page)  { double('page', execute_script: nil) }
    let(:video) { MediaController::Video.new(page, id: 'my-id') }

    it "pauses video" do
      expect(page).to receive(:execute_script).with("window['media-my-id'].pause();")
      video.pause
    end
  end

  describe "#seek_to" do
    let(:page)  { double('page', execute_script: nil) }
    let(:video) { MediaController::Video.new(page, id: 'my-id') }

    it "seeks to a timestamp" do
      expect(page).to receive(:execute_script).with("window['media-my-id'].currentTime = 120;")
      video.seek_to(120)
    end

    it "seeks to the nearest integer timestamp" do
      expect(page).to receive(:execute_script).with("window['media-my-id'].currentTime = 120;")
      video.seek_to(120.3)
    end

    it "converts to integer before seeking" do
      expect(page).to receive(:execute_script).with("window['media-my-id'].currentTime = 120;")
      video.seek_to('120')
    end
  end

  describe "#current_time" do
    let(:page)  { double('page', execute_script: nil) }
    let(:video) { MediaController::Video.new(page, id: 'my-id') }

    it "reports the current time" do
      allow(page).to receive(:evaluate_script).with("window['media-my-id'].currentTime;").and_return(100)
      expect(video.current_time).to eq 100
    end
  end

  describe "#duration" do
    let(:page)  { double('page', execute_script: nil) }
    let(:video) { MediaController::Video.new(page, id: 'my-id') }

    it "reports the video duration" do
      allow(page).to receive(:evaluate_script).with("window['media-my-id'].duration;").and_return(600)
      expect(video.duration).to eq 600
    end
  end

  describe "#event_count" do
    let(:page)  { double('page', execute_script: nil) }
    let(:video) { MediaController::Video.new(page, id: 'my-id') }

    it "reports the number of times an event has occurred" do
      allow(page).to receive(:evaluate_script).with("window['media-my-id-timeupdate-count'];").and_return(10)
      expect(video.event_count('timeupdate')).to eq 10
    end
  end

  describe "#add_event_listener" do
    let(:page)  { double('page', execute_script: nil) }
    let(:video) { MediaController::Video.new(page, id: 'my-id') }

    it "sets up an event count and initializes it to 0" do
      expect(page).to receive(:execute_script).with("window['media-my-id-timeupdate-count'] = 0;")
      video.add_event_listener('timeupdate')
    end

    it "creates a function that increments the event count" do
      expect(page).to receive(:execute_script).with("window['media-my-id-timeupdate-count-function'] = function() { window['media-my-id-timeupdate-count'] += 1; };")
      video.add_event_listener('timeupdate')
    end

    it "attaches the function to the event coming from the video" do
      expect(page).to receive(:execute_script).with("window['media-my-id'].addEventListener('timeupdate', window['media-my-id-timeupdate-count-function']);")
      video.add_event_listener('timeupdate')
    end
  end

  describe "#remove_event_listener" do
    let(:page)  { double('page', execute_script: nil) }
    let(:video) { MediaController::Video.new(page, id: 'my-id') }

    it "removes the event listener function from the video" do
      expect(page).to receive(:execute_script).with("window['media-my-id'].removeEventListener('timeupdate', window['media-my-id-timeupdate-count-function']);")
      video.remove_event_listener('timeupdate')
    end

    it "removes the increment count function" do
      expect(page).to receive(:execute_script).with("window['media-my-id-timeupdate-count-function'] = null;")
      video.remove_event_listener('timeupdate')
    end

    it "removes the event count" do
      expect(page).to receive(:execute_script).with("window['media-my-id-timeupdate-count'] = null;")
      video.remove_event_listener('timeupdate')
    end
  end

  describe "#playing?" do
    let(:page)  { double('page', execute_script: nil) }
    let(:video) { MediaController::Video.new(page, id: 'my-id') }

    it "returns true when more than 3 timeupdate messages come within 3 seconds" do
      expect(video).to receive(:sleep).with(3)
      allow(video).to receive(:event_count).with('timeupdate').and_return(4)
      expect(video.playing?).to be true
    end

    it "returns false when fewer than 3 timeupdate messages come within 3 seconds" do
      expect(video).to receive(:sleep).with(3)
      allow(video).to receive(:event_count).with('timeupdate').and_return(0)
      expect(video.playing?).to be false
    end
  end
end
