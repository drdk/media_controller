describe MediaController::Video do
  let(:page) { double('page', execute_script: nil) }

  describe "#new" do

    it "does not work with a blank ID" do
      expect {
        require 'media_controller'
        MediaController::Video.new(page, {id: ""})
      }.to raise_error(RuntimeError, "Please supply a valid ID")
    end

    it "remembers the page reference" do
      video = MediaController::Video.new(page, id: 'my-id')
      expect(video.page).to eq(page)
    end

    context('finding by reference') do
      let(:reference) { double('reference', path: "/HTML/BODY[1]/DIV[8]/VIDEO[1]") }

      it "finds the player" do
        allow(MediaController::Media).to receive(:random_id).and_return('68866')
        expect(page).to receive(:execute_script).with("window['media-68866'] = document.evaluate('/HTML/BODY[1]/DIV[8]/VIDEO[1]', document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue")
        MediaController::Video.new(page, reference: reference)
      end

      it "finds the player reference" do
        expect(reference).to receive(:path)
        video = MediaController::Video.new(page, reference: reference)
      end

      it "makes up an ID and stores it" do
        expect(MediaController::Media).to receive(:random_id).and_return('45987')
        video = MediaController::Video.new(page, reference: reference)
        expect(video.id).to eq '45987'
      end
    end

    context('finding by ID') do
      it "finds the player" do
        expect(page).to receive(:execute_script).with("window['media-my-id'] = document.getElementById('my-id')")
        MediaController::Video.new(page, id: 'my-id')
      end

      it "stores the id" do
        video = MediaController::Video.new(page, id: 'my-id')
        expect(video.id).to eq('my-id')
      end
    end

    context('finding without id or reference') do
      it "finds the player" do
        allow(MediaController::Media).to receive(:random_id).and_return('98248')
        expect(page).to receive(:execute_script).with("window['media-98248'] = document.getElementsByTagName('video')[0]")
        MediaController::Video.new(page)
      end

      it "makes up an ID and stores it" do
        expect(MediaController::Media).to receive(:random_id).and_return('08673')
        video = MediaController::Video.new(page)
        expect(video.id).to eq '08673'
      end
    end
  end

  context "after initialization" do
    let(:video) { MediaController::Video.new(page, id: 'my-id') }

    describe "#play" do
      it "plays video" do
        expect(page).to receive(:execute_script).with("window['media-my-id'].play();")
        video.play
      end
    end

    describe "#pause" do
      it "pauses video" do
        expect(page).to receive(:execute_script).with("window['media-my-id'].pause();")
        video.pause
      end
    end

    describe "#seek_to" do
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
      it "reports the current time" do
        allow(page).to receive(:evaluate_script).with("window['media-my-id'].currentTime;").and_return(100)
        expect(video.current_time).to eq 100
      end
    end

    describe "#duration" do
      it "reports the video duration" do
        allow(page).to receive(:evaluate_script).with("window['media-my-id'].duration;").and_return(600)
        expect(video.duration).to eq 600
      end
    end

    describe "#playing?" do
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

    describe "#mute!" do
      it "mutes the video" do
        expect(page).to receive(:execute_script).with("window['media-my-id'].muted = true;")
        video.mute!
      end
    end

    describe "#unmute!" do
      it "unmutes the video" do
        expect(page).to receive(:execute_script).with("window['media-my-id'].muted = false;")
        video.unmute!
      end
    end

    describe "#muted?" do
      it "returns true the video is muted" do
        allow(page).to receive(:evaluate_script).with("window['media-my-id'].muted;").and_return(true)
        expect(video.muted?).to be true
      end

      it "returns false when the video is not muted" do
        allow(page).to receive(:evaluate_script).with("window['media-my-id'].muted;").and_return(false)
        expect(video.muted?).to be false
      end
    end

    describe "#volume=" do
      it "sets the volume to the value specified" do
        expect(page).to receive(:execute_script).with("window['media-my-id'].volume = 0.6;")
        video.volume = 0.6
      end
    end

    describe "#volume" do
      it "returns the current volume" do
        allow(page).to receive(:evaluate_script).with("window['media-my-id'].volume;").and_return(0.3)
        expect(video.volume).to eq 0.3
      end
    end

    describe "#size" do
      it "returns the width and height" do
        allow(page).to receive(:evaluate_script).with("window['media-my-id'].clientWidth;").and_return(1130)
        allow(page).to receive(:evaluate_script).with("window['media-my-id'].clientHeight;").and_return(636)
        expect(video.size).to eq({width: 1130, height: 636})
      end
    end

    describe "#event_count" do
      it "reports the number of times an event has occurred" do
        allow(page).to receive(:evaluate_script).with("window['media-my-id-timeupdate-count'];").and_return(10)
        expect(video.event_count('timeupdate')).to eq 10
      end
    end

    describe "#add_event_listener" do
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
  end
end
