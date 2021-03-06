describe MediaController::Audio do
  let(:page) { double('page', execute_script: nil) }

  describe "#new" do

    it "does not work with a blank ID" do
      expect {
        require 'media_controller'
        MediaController::Audio.new(page, {id: ""})
      }.to raise_error(RuntimeError, "Please supply a valid ID")
    end

    it "remembers the page reference" do
      audio = MediaController::Audio.new(page, id: 'my-id')
      expect(audio.page).to eq(page)
    end

    context('finding by reference') do
      let(:reference) { double('reference', path: "/HTML/BODY[1]/DIV[8]/AUDIO[1]") }

      it "finds the player" do
        allow(MediaController::Media).to receive(:random_id).and_return('68866')
        expect(page).to receive(:execute_script).with("window['media-68866'] = document.evaluate('/HTML/BODY[1]/DIV[8]/AUDIO[1]', document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue")
        MediaController::Audio.new(page, reference: reference)
      end

      it "finds the player reference" do
        expect(reference).to receive(:path)
        audio = MediaController::Audio.new(page, reference: reference)
      end

      it "makes up an ID and stores it" do
        expect(MediaController::Media).to receive(:random_id).and_return('45987')
        audio = MediaController::Audio.new(page, reference: reference)
        expect(audio.id).to eq '45987'
      end
    end

    context('finding by ID') do
      it "finds the player" do
        expect(page).to receive(:execute_script).with("window['media-my-id'] = document.getElementById('my-id')")
        MediaController::Audio.new(page, id: 'my-id')
      end

      it "stores the id" do
        audio = MediaController::Audio.new(page, id: 'my-id')
        expect(audio.id).to eq('my-id')
      end
    end

    context('finding without id or reference') do
      it "finds the player" do
        allow(MediaController::Media).to receive(:random_id).and_return('98248')
        expect(page).to receive(:execute_script).with("window['media-98248'] = document.getElementsByTagName('audio')[0]")
        MediaController::Audio.new(page)
      end

      it "makes up an ID and stores it" do
        expect(MediaController::Media).to receive(:random_id).and_return('08673')
        audio = MediaController::Audio.new(page)
        expect(audio.id).to eq '08673'
      end
    end
  end

  context "after initialization" do
    let(:audio) { MediaController::Audio.new(page, id: 'my-id') }

    describe "#current_src" do
      it "reports the current src" do
        allow(page).to receive(:evaluate_script).with("window['media-my-id'].currentSrc;").and_return('blob:example')
        expect(audio.current_src).to eq 'blob:example'
      end
    end

    describe "#play" do
      it "plays audio" do
        expect(page).to receive(:execute_script).with("window['media-my-id'].play();")
        audio.play
      end
    end

    describe "#pause" do
      it "pauses audio" do
        expect(page).to receive(:execute_script).with("window['media-my-id'].pause();")
        audio.pause
      end
    end

    describe "#seek_to" do
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
      it "reports the current time" do
        allow(page).to receive(:evaluate_script).with("window['media-my-id'].currentTime;").and_return(100)
        expect(audio.current_time).to eq 100
      end
    end

    describe "#duration" do
      it "reports the audio duration" do
        allow(page).to receive(:evaluate_script).with("window['media-my-id'].duration;").and_return(600)
        expect(audio.duration).to eq 600
      end
    end

    describe "#playing?" do
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

    describe "#mute!" do
      it "mutes the audio" do
        expect(page).to receive(:execute_script).with("window['media-my-id'].muted = true;")
        audio.mute!
      end
    end

    describe "#unmute!" do
      it "unmutes the audio" do
        expect(page).to receive(:execute_script).with("window['media-my-id'].muted = false;")
        audio.unmute!
      end
    end

    describe "#muted?" do
      it "returns true the audio is muted" do
        allow(page).to receive(:evaluate_script).with("window['media-my-id'].muted;").and_return(true)
        expect(audio.muted?).to be true
      end

      it "returns false when the audio is not muted" do
        allow(page).to receive(:evaluate_script).with("window['media-my-id'].muted;").and_return(false)
        expect(audio.muted?).to be false
      end
    end

    describe "#volume=" do
      it "sets the volume to the value specified" do
        expect(page).to receive(:execute_script).with("window['media-my-id'].volume = 0.6;")
        audio.volume = 0.6
      end
    end

    describe "#volume" do
      it "returns the current volume" do
        allow(page).to receive(:evaluate_script).with("window['media-my-id'].volume;").and_return(0.3)
        expect(audio.volume).to eq 0.3
      end
    end

    describe "#size" do
      it "returns the width and height" do
        allow(page).to receive(:evaluate_script).with("window['media-my-id'].clientWidth;").and_return(930)
        allow(page).to receive(:evaluate_script).with("window['media-my-id'].clientHeight;").and_return(60)
        expect(audio.size).to eq({width: 930, height: 60})
      end
    end

    describe "#event_count" do
      it "reports the number of times an event has occurred" do
        allow(page).to receive(:evaluate_script).with("window['media-my-id-timeupdate-count'];").and_return(10)
        expect(audio.event_count('timeupdate')).to eq 10
      end
    end

    describe "#add_event_listener" do
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
  end
end
