module MediaController

  class Media

    attr :page, :id

    def initialize(capybara_page, options)
      raise "Please supply an ID" unless options[:id]
      @id = options[:id]
      @page = capybara_page
      @ref = "window['media-#{@id}']"
      @page.execute_script("#{@ref} = document.getElementById('#{@id}')")
    end

    def play
      @page.execute_script "#{@ref}.play();"
    end

    def pause
      @page.execute_script "#{@ref}.pause();"
    end

    def seek_to(seconds)
      @page.execute_script "#{@ref}.currentTime = #{seconds.to_i};"
    end

    def current_time
      @page.evaluate_script "#{@ref}.currentTime;"
    end

    def duration
      @page.evaluate_script "#{@ref}.duration;"
    end

    def playing?
      add_event_listener('timeupdate')
      sleep 3
      playing = event_count('timeupdate') > 3
      remove_event_listener('timeupdate')
      return playing
    end

    def mute!
      @page.execute_script "#{@ref}.muted = true;"
    end

    def unmute!
      @page.execute_script "#{@ref}.muted = false;"
    end

    def muted?
      @page.evaluate_script "#{@ref}.muted;"
    end

    def volume=(new_volume)
      @page.execute_script "#{@ref}.volume = #{new_volume};"
    end

    def volume
      @page.evaluate_script "#{@ref}.volume;"
    end

    def size
      width = @page.evaluate_script "#{@ref}.clientWidth;"
      height = @page.evaluate_script "#{@ref}.clientHeight;"
      {width: width, height: height}
    end

    def event_count(event_name)
      @page.evaluate_script "window['media-#{@id}-#{event_name}-count'];"
    end

    def add_event_listener(event_name)
      @page.execute_script "window['media-#{@id}-#{event_name}-count'] = 0;"
      @page.execute_script "window['media-#{@id}-#{event_name}-count-function'] = function() { window['media-#{@id}-#{event_name}-count'] += 1; };"
      @page.execute_script "#{@ref}.addEventListener('#{event_name}', window['media-#{@id}-#{event_name}-count-function']);"
    end

    def remove_event_listener(event_name)
      @page.execute_script "#{@ref}.removeEventListener('#{event_name}', window['media-#{@id}-#{event_name}-count-function']);"
      @page.execute_script "window['media-#{@id}-#{event_name}-count-function'] = null;"
      @page.execute_script "window['media-#{@id}-#{event_name}-count'] = null;"
    end
  end

end
