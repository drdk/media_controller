describe MediaController::Video do
  it "knows video" do
    expect(MediaController::Video.hi).to eq("Video")
  end

  it "is awesome" do
    expect(MediaController::Video.awesome?).to eq("very awesome indeed!")
  end
end

describe MediaController::Audio do
  it "knows Audio" do
    expect(MediaController::Audio.hi).to eq("Audio")
  end

  it "is awesome" do
    expect(MediaController::Audio.awesome?).to eq("very awesome indeed!")
  end
end

describe MediaController::Media do
  it "knows Media" do
    expect(MediaController::Media.hi).to eq("Media")
  end

  it "is awesome" do
    expect(MediaController::Media.awesome?).to eq("very awesome indeed!")
  end
end
