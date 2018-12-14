describe MediaController::Audio do

  describe "#new" do
    let(:page) { double('page', execute_script: nil) }

    it "works with an ID" do
      expect(page).to receive(:execute_script).with("window['media-my-id'] = document.getElementById('my-id')")
      MediaController::Audio.new(page, id: 'my-id')
    end

    it "does not work without an ID" do
      expect {
        require 'media_controller'
        MediaController::Audio.new(page, {})
      }.to raise_error(RuntimeError, "Please supply an ID")
    end

    it "remembers the page reference" do
      audio = MediaController::Audio.new(page, id: 'my-id')
      expect(audio.page).to eq(page)
    end

    it "stores the id" do
      audio = MediaController::Audio.new(page, id: 'my-id')
      expect(audio.id).to eq('my-id')
    end
  end

  describe "#play" do
    let(:page)  { double('page', execute_script: nil) }
    let(:audio) { MediaController::Audio.new(page, id: 'my-id') }

    it "plays audio" do
      expect(page).to receive(:execute_script).with("window['media-my-id'].play();")
      audio.play
    end
  end

  describe "#pause" do
    let(:page)  { double('page', execute_script: nil) }
    let(:audio) { MediaController::Audio.new(page, id: 'my-id') }

    it "pauses audio" do
      expect(page).to receive(:execute_script).with("window['media-my-id'].pause();")
      audio.pause
    end
  end

  describe "#seek_to" do
    let(:page)  { double('page', execute_script: nil) }
    let(:audio) { MediaController::Audio.new(page, id: 'my-id') }

    it "seeks to a timestamp" do
      expect(page).to receive(:execute_script).with("window['media-my-id'].currentTime = 120;")
      audio.seek_to(120)
    end

    it "seeks to the nearest integer timestamp" do
      expect(page).to receive(:execute_script).with("window['media-my-id'].currentTime = 120;")
      audio.seek_to(120.3)
    end

    it "converts to integer before seeking" do
      expect(page).to receive(:execute_script).with("window['media-my-id'].currentTime = 120;")
      audio.seek_to('120')
    end
  end

  describe "#current_time" do
    let(:page)  { double('page', execute_script: nil) }
    let(:audio) { MediaController::Audio.new(page, id: 'my-id') }

    it "reports the current time" do
      allow(page).to receive(:evaluate_script).with("window['media-my-id'].currentTime;").and_return(100)
      expect(audio.current_time).to eq 100
    end
  end

  describe "#duration" do
    let(:page)  { double('page', execute_script: nil) }
    let(:audio) { MediaController::Audio.new(page, id: 'my-id') }

    it "reports the audio duration" do
      allow(page).to receive(:evaluate_script).with("window['media-my-id'].duration;").and_return(600)
      expect(audio.duration).to eq 600
    end
  end

  describe "#event_count" do
    let(:page)  { double('page', execute_script: nil) }
    let(:audio) { MediaController::Audio.new(page, id: 'my-id') }

    it "reports the number of times an event has occurred" do
      allow(page).to receive(:evaluate_script).with("window['media-my-id-timeupdate-count'];").and_return(10)
      expect(audio.event_count('timeupdate')).to eq 10
    end
  end

  describe "#add_event_listener" do
    let(:page)  { double('page', execute_script: nil) }
    let(:audio) { MediaController::Audio.new(page, id: 'my-id') }

    it "sets up an event count and initializes it to 0" do
      expect(page).to receive(:execute_script).with("window['media-my-id-timeupdate-count'] = 0;")
      audio.add_event_listener('timeupdate')
    end

    it "creates a function that increments the event count" do
      expect(page).to receive(:execute_script).with("window['media-my-id-timeupdate-count-function'] = function() { window['media-my-id-timeupdate-count'] += 1; };")
      audio.add_event_listener('timeupdate')
    end

    it "attaches the function to the event coming from the audio" do
      expect(page).to receive(:execute_script).with("window['media-my-id'].addEventListener('timeupdate', window['media-my-id-timeupdate-count-function']);")
      audio.add_event_listener('timeupdate')
    end
  end

  describe "#remove_event_listener" do
    let(:page)  { double('page', execute_script: nil) }
    let(:audio) { MediaController::Audio.new(page, id: 'my-id') }

    it "removes the event listener function from the audio" do
      expect(page).to receive(:execute_script).with("window['media-my-id'].removeEventListener('timeupdate', window['media-my-id-timeupdate-count-function']);")
      audio.remove_event_listener('timeupdate')
    end

    it "removes the increment count function" do
      expect(page).to receive(:execute_script).with("window['media-my-id-timeupdate-count-function'] = null;")
      audio.remove_event_listener('timeupdate')
    end

    it "removes the event count" do
      expect(page).to receive(:execute_script).with("window['media-my-id-timeupdate-count'] = null;")
      audio.remove_event_listener('timeupdate')
    end
  end

  describe "#playing?" do
    let(:page)  { double('page', execute_script: nil) }
    let(:audio) { MediaController::Audio.new(page, id: 'my-id') }

    it "returns true when more than 3 timeupdate messages come within 3 seconds" do
      expect(audio).to receive(:sleep).with(3)
      allow(audio).to receive(:event_count).with('timeupdate').and_return(4)
      expect(audio.playing?).to be true
    end

    it "returns false when fewer than 3 timeupdate messages come within 3 seconds" do
      expect(audio).to receive(:sleep).with(3)
      allow(audio).to receive(:event_count).with('timeupdate').and_return(0)
      expect(audio.playing?).to be false
    end
  end
end
